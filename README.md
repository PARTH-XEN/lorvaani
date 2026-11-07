# LORVANI — AI-Powered Comic Learning Application

> Transform ordinary study notes, textbook scans, and educational PDFs into visually engaging, illustrated comic-book learning adventures.

---

## 🌟 Overview

**Lorvani** is a production-grade Flutter application built with Dart, Material 3, and Riverpod. It bridges the gap between dense academic material and visual storytelling, turning complex concepts into character-driven comic panels with interactive sound effects, definitions, quizzes, and printable graphic novel PDF exports.

---

## 🚀 Key Features

- **Dimension Flip Identity**: Distinctive geometric vector branding with dynamic gradients (#8054E9 Comic Purple, #F46CA8 Comic Pink, #48C9E8 Sky Cyan).
- **Multimodal Learning Input**:
  - Direct note typing and pasting.
  - Camera & gallery document OCR with blur/empty detection.
  - Cross-platform PDF text extraction (pure Dart, zero native symlinks).
  - 1-tap starter templates across Science, Physics, Chemistry, History, and Biology.
- **AI Story Generation Engine**:
  - Resilient `AiOrchestrator` with automated multi-tier failover (`Gemini -> Groq -> Offline Mock`).
  - Exponential backoff with instant 429 RateLimit failover.
  - Strict JSON schema validation ensuring complete story structure (characters, dialogue, narration, visual analogies, and quizzes).
- **Interactive Comic Reader**:
  - Horizontal panel-by-panel flip or vertical continuous reading.
  - Pinch-to-zoom (1.0x to 3.5x) on illustrated panels.
  - Interactive comic sound effects ("ZAP!", "BOOM!", "EUREKA!", "AHA!").
  - Text-to-Speech audio narration for panels and character dialogue.
  - Concept drawer revealing definitions, visual analogies, and character dossiers.
- **Mastery Quizzes**:
  - Interactive multi-choice questions with instant answer reveals (emerald green / crimson red).
  - "Why it works" educational explanations.
  - 4-tier mastery achievement scoring (*Cosmic Scholar, Comic Mastermind, Hero in Training, Comic Novice*).
- **Personal Library & PDF Export**:
  - Offline-first storage with reactive search, subject filtering, and level chips.
  - Multi-page graphic novel vector PDF export with cover page, panel grids, dialogues, and quiz appendix.

---

## 🏗️ Architecture

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp.router with dark ComicTheme
│   └── router.dart                # go_router configuration with full shell navigation
├── core/
│   ├── constants/                 # Story schema keys and defaults
│   ├── errors/                    # Domain exceptions (AiProviderException, etc.)
│   ├── services/
│   │   ├── ai/                    # AiOrchestrator, Gemini, Groq, Pollinations, Mocks
│   │   ├── audio/                 # ComicTtsService (Text-to-speech)
│   │   ├── export/                # ComicPdfExportService (Graphic novel PDF engine)
│   │   ├── ocr/                   # OcrService (Text recognition)
│   │   ├── pdf/                   # PdfExtractorService (syncfusion_flutter_pdf)
│   │   ├── share/                 # ComicShareService
│   │   └── storage/               # StoryStorageService (shared_preferences)
│   ├── theme/
│   │   ├── comic_colors.dart      # Deep Charcoal (#17151F), Comic Purple, etc.
│   │   ├── comic_theme.dart       # Material 3 dark theme
│   │   └── comic_typography.dart  # Bangers, Poppins, Inter styles
│   └── widgets/
│       ├── comic_button.dart      # Tactile comic buttons with drop shadows
│       ├── comic_panel.dart       # Comic borders and styled containers
│       ├── comic_speech_bubble.dart # Speech bubbles with pointer tails
│       ├── dimension_flip_logo.dart # Vector logo painter (5 variations)
│       └── halftone_container.dart# Comic halftone dot matrix effect
├── data/
│   └── models/
│       └── comic_story_model.dart # Strict schema data models with JSON serialization
└── features/
    ├── home/                      # Dashboard, streak cards, subject explorer
    ├── image_generation/          # Dynamic prompts, LRU image cache, controllers
    ├── library/                   # Saved stories, filtering, and PDF generation
    ├── onboarding/                # 3-step animated onboarding carousel
    ├── quiz/                      # Interactive quiz session, scoring, and mastery
    ├── reader/                    # Horizontal & vertical comic reader, audio narration
    ├── splash/                    # Animated Dimension Flip splash screen
    └── story_generation/          # Input screen, review sheet, customization, progress
```

---

## 💻 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24.0 or newer)
- Dart SDK with null-safety

### 1. Clone & Install Dependencies
```powershell
git clone <repo-url>
cd lorevaani
flutter pub get
```

### 2. Run the Application
Lorvani runs immediately out-of-the-box without requiring any API keys:

```powershell
# Run on Windows Desktop
flutter run -d windows

# Run in Chrome / Web
flutter run -d chrome

# Run on a connected Android device or emulator
flutter run -d android
```

### 3. Optional: Live AI Configuration
To connect live Gemini or Groq API endpoints, launch with `--dart-define` flags:
```powershell
flutter run -d windows `
  --dart-define=GEMINI_API_KEY="your-gemini-key" `
  --dart-define=GROQ_API_KEY="your-groq-key"
```

---

## 🧪 Testing & Verification

Lorvani includes an extensive automated test suite covering unit tests, widget tests, provider fallbacks, and full end-to-end user journeys.

```powershell
# Run the entire test suite (98 tests across 18 test suites)
flutter test

# Run static code analysis (0 lint errors)
flutter analyze

# Run End-to-End User Journey test specifically
flutter test test/e2e_user_journey_test.dart
```

---

## 📦 Building for Production

```powershell
# Build Debug APK
flutter build apk --debug

# Build Release APK
flutter build apk --release

# Build Windows Executable
flutter build windows
```

---

## 📄 License
This project is licensed under the MIT License.
