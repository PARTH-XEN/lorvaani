# Milestone 2: AI Provider Research & Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the complete AI provider architecture, documentation, secure configuration, mock providers, and resilient fallback orchestration for Lorvani's story and comic image pipelines.

**Architecture:** Provider-agnostic strategy pattern with abstract interfaces (`AiTextProvider`, `AiImageProvider`), an `AiOrchestrator` managing prioritized fallback chains, exponential backoff retries, rate-limit (`429`) recovery, in-memory caching, and deterministic offline mock implementations.

**Tech Stack:** Dart 3.13.7, Flutter 3.47.9, `http` client package, Riverpod.

---

### File Structure Map

- `providers.md`: Authoritative research findings covering Gemini, Groq, Cloudflare, Hugging Face, OpenRouter, Together AI, and Pollinations.
- `.env.example`: Secure environment variable template with provider keys and instructions.
- `lib/core/services/ai/ai_provider_types.dart`: Models, exceptions (`RateLimitException`, `QuotaExceededException`, `MalformedResponseException`), and provider enums.
- `lib/core/services/ai/ai_text_provider.dart`: Abstract interface for LLM text and story generation.
- `lib/core/services/ai/ai_image_provider.dart`: Abstract interface for comic panel illustration generation.
- `lib/core/services/ai/mock/mock_text_provider.dart`: Mock LLM returning valid JSON comic stories for offline development and testing.
- `lib/core/services/ai/mock/mock_image_provider.dart`: Mock illustration provider generating fallback comic assets.
- `lib/core/services/ai/providers/gemini_text_provider.dart`: Google Gemini API client implementation.
- `lib/core/services/ai/providers/groq_text_provider.dart`: Groq LPU API client implementation.
- `lib/core/services/ai/providers/pollinations_image_provider.dart`: Pollinations.ai image generator.
- `lib/core/services/ai/orchestrator/ai_orchestrator.dart`: Fallback chain manager with backoff, rate-limit failover, and caching.
- `test/ai_provider_test.dart`: Unit tests verifying provider selection, fallback on 429/500, retry backoff, and mock responses.

---

### Tasks

- [x] **Task 1: AI Provider Documentation & Security Configuration**
  - Create `providers.md` with verified 2026 API quotas, rate limits, models, and security best practices.
  - Create `.env.example` with standard environment keys.

- [x] **Task 2: Provider Interfaces & Models**
  - Create `lib/core/services/ai/ai_provider_types.dart`.
  - Create `lib/core/services/ai/ai_text_provider.dart`.
  - Create `lib/core/services/ai/ai_image_provider.dart`.

- [x] **Task 3: Deterministic Mock Providers**
  - Implement `MockTextProvider` with realistic educational comic JSON outputs.
  - Implement `MockImageProvider` with consistent fallback artwork.

- [x] **Task 4: Real Provider Integrations**
  - Implement `GeminiTextProvider`.
  - Implement `GroqTextProvider`.
  - Implement `PollinationsImageProvider`.

- [x] **Task 5: Resilient Fallback Orchestrator**
  - Implement `AiOrchestrator` with fallback chains, exponential backoff, rate limit handling, and caching.

- [x] **Task 6: Unit Tests & Verification**
  - Write tests for mock generation, fallback chains, rate limit recovery, and caching in `test/ai_provider_test.dart`.
  - Run `flutter analyze` and `flutter test`.
