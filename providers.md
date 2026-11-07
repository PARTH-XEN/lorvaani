# Lorvani — AI Provider Research & Architecture Specification

## 1. Executive Summary

Lorvani requires two distinct AI capabilities:
1. **Structured Text & Story Generation:** Transforming raw notes, textbook chapters, or OCR text into structured JSON comic scripts (characters, dialogues, scene layouts, educational analogies, quizzes).
2. **Comic Illustration Generation:** Generating visual panels matching selected visual styles (Classic Comic, Anime, Cartoon, Storybook, Cinematic Comic) with character consistency.

To support resilient, zero-cost development and scalable production, Lorvani employs a **modular provider abstraction** with **prioritized fallback chains**, **automatic rate-limit detection**, and **deterministic offline mock providers**.

---

## 2. Text Generation Providers (LLMs)

### 2.1 Google Gemini (Google AI Studio)
- **Status:** Recommended Primary Text Provider
- **Official Documentation:** https://ai.google.dev/docs
- **Authentication:** API Key via `x-goog-api-key` header or query parameter.
- **Recommended Models:**
  - `gemini-1.5-flash`: Fast, high context window (1M tokens), native JSON schema enforcement.
  - `gemini-2.0-flash`: Next-gen speed and reasoning capabilities.
- **Free Tier Limits:**
  - **RPM (Requests Per Minute):** 15 RPM
  - **TPM (Tokens Per Minute):** 250,000 to 1,000,000 TPM
  - **RPD (Requests Per Day):** 500 to 1,500 RPD (resets daily at midnight Pacific Time)
- **Structured Output:** Supported natively via `responseSchema` and `responseMimeType: "application/json"`.
- **Considerations:** Free tier logs may be retained by Google for model training. Production setups should use Cloudflare Worker/proxy or paid tier to maintain privacy.

---

### 2.2 Groq (GroqCloud LPU)
- **Status:** Recommended Secondary Text Provider / Instant Fallback
- **Official Documentation:** https://console.groq.com/docs
- **Authentication:** Bearer token via `Authorization: Bearer $GROQ_API_KEY`.
- **Recommended Models:**
  - `llama-3.3-70b-versatile`: Deep reasoning, nuanced educational analogies.
  - `llama-3.1-8b-instant`: Ultra-fast generation (500+ tokens/sec) for rapid comic generation.
- **Free Tier Limits:**
  - **RPM:** 30 RPM
  - **RPD:** 14,400 RPD (for 8B models), 1,000 RPD (for 70B models)
  - **TPM:** 6,000 to 30,000 TPM (Token per minute wall is the primary constraint)
  - **TPD:** 500,000 tokens/day
- **Structured Output:** Fully OpenAI-compatible `response_format: {"type": "json_object"}`.
- **Considerations:** Very high inference speed makes Groq an ideal fallback when Gemini encounters rate limits or temporary downtime.

---

### 2.3 Cloudflare Workers AI
- **Status:** Supported Edge Provider
- **Official Documentation:** https://developers.cloudflare.com/workers-ai/
- **Authentication:** Cloudflare Account ID + API Token.
- **Recommended Models:** `@cf/meta/llama-3.1-8b-instruct`, `@cf/mistral/mistral-7b-instruct-v0.2`.
- **Free Tier Limits:**
  - **Allocation:** **10,000 Neurons per day** (resets daily).
  - Equivalent to approximately 30,000–50,000 tokens depending on model weight.
- **Considerations:** Can run either via serverless Workers or direct REST API (`https://api.cloudflare.com/client/v4/accounts/{account_id}/ai/run/{model}`).

---

### 2.4 Hugging Face Serverless Inference API
- **Status:** Supported Community Fallback
- **Official Documentation:** https://huggingface.co/docs/api-inference
- **Authentication:** User Access Token (`hf_...`).
- **Free Tier Limits:**
  - Authenticated free tier: ~1,000 requests per 5-minute window across free endpoints.
- **Considerations:** Models may experience **cold starts** returning `503 Service Unavailable (Model is currently loading)`. The client must handle `estimated_time` and retry delays.

---

### 2.5 OpenRouter
- **Status:** Supported Multi-Model Router
- **Official Documentation:** https://openrouter.ai/docs
- **Authentication:** Bearer token via `Authorization: Bearer $OPENROUTER_API_KEY`.
- **Free Models:** Endpoints suffixed with `:free` (e.g. `meta-llama/llama-3.1-8b-instruct:free`, `google/gemini-2.0-flash-exp:free`).
- **Free Tier Limits:**
  - Free accounts: ~50 requests/day, 20 RPM.
- **Considerations:** Subject to public traffic surges; requires graceful error handling on HTTP 429.

---

### 2.6 Together AI
- **Status:** Ineligible for Pure Free Tier
- **Documentation Verification:** Together AI operates on a prepaid usage model with an initial minimum credit deposit ($15). It does not maintain a permanent zero-cost free tier. Kept documented for transparent evaluation.

---

## 3. Image Generation Providers

### 3.1 Pollinations.ai
- **Status:** Recommended Primary Image Provider
- **Official Documentation:** https://pollinations.ai / https://gen.pollinations.ai
- **Endpoint:** `GET https://gen.pollinations.ai/image/{prompt}?model=flux&width=1024&height=1024&seed={seed}&nologo=true`
- **Authentication:** Open access for standard generation; optional API key for elevated tiers.
- **Models:** `flux`, `flux-realism`, `turbo`.
- **Advantages:**
  - Zero-friction REST endpoint returning image binary directly or cacheable URLs.
  - Reproducible character generation via consistent integer `seed` parameters.
  - Ideal for mobile rendering with built-in HTTP image caching.

---

### 3.2 Cloudflare Workers AI (Flux Schnell)
- **Status:** Supported Secondary Image Provider
- **Model:** `@cf/black-forest-labs/flux-1-schnell`
- **Quotas:** Consumes part of the daily 10,000 Neurons allocation.

---

## 4. Provider Architecture & Fallback Chains

Lorvani enforces a resilient multi-tier fallback architecture:

```
[User Request: Generate Story]
               │
               ▼
   ┌───────────────────────┐
   │    AiOrchestrator     │
   └───────────┬───────────┘
               │
      Try Primary Provider (Google Gemini)
               │
      Success? ├───► [Return Structured Story JSON]
               │
          Fail / 429 / Timeout
               │
               ▼
     Try Secondary Provider (Groq LPU)
               │
      Success? ├───► [Return Structured Story JSON]
               │
          Fail / 429 / Timeout
               │
               ▼
      Offline / Dev Mock Provider
               │
               └───► [Return Curated Educational Comic Script]
```

### 4.1 Key Architecture Components

1. **`AiTextProvider` Interface:**
   - Standardized contract: `Future<AiTextResponse> generateStory({required String prompt, required StoryOptions options})`.
   - Returns typed `AiTextResponse` with raw text, parsed JSON, token metrics, and provider signature.

2. **`AiImageProvider` Interface:**
   - Standardized contract: `Future<AiImageResponse> generatePanelIllustration({required String panelDescription, required String visualStyle, int? seed})`.
   - Returns typed `AiImageResponse` with image URL, local cache path, or fallback vector asset.

3. **`AiOrchestrator`:**
   - Manages prioritized list of text and image providers.
   - Enforces exponential backoff: base delay 1.5s, max 3 attempts per provider.
   - Detects `429 (Too Many Requests)` and switches immediately to the next provider in the chain.
   - In-memory LRU cache to avoid duplicate API calls for identical prompts.

4. **Deterministic Mock Providers:**
   - `MockTextProvider`: Emits rich, strictly validated educational comic story JSON across all 8 subjects without network dependence.
   - `MockImageProvider`: Emits themed SVG and styled visual panel fallbacks.

---

## 5. Security & Secret Management

1. **No Embedded Secrets:**
   - Never hardcode API keys in Dart code or commit them to version control.
   - Environment variables are managed via `.env` and loaded at runtime.
2. **Production Recommendation:**
   - For public store releases (Google Play / App Store), route client calls through a thin backend proxy (e.g., Cloudflare Worker, Next.js API route, or Supabase Edge Function).
   - The proxy holds the private API keys, verifies user auth, enforces rate limits per user, and forwards requests to Gemini/Groq.
3. **Graceful Degradation:**
   - If no API key is provided or all network calls fail, Lorvani transitions smoothly to mock data with a visible offline indicator, preventing crashes or blank screens.

