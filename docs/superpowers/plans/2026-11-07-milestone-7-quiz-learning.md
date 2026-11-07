# Milestone 7: Quiz and Concept Learning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the interactive educational quiz and concept mastery system for Lorvani, featuring multiple-choice questions with immediate tactile visual feedback, explanation callouts, quiz scoring and mastery tier calculation, concept review flashcards, and comprehensive state tests.

**Architecture:**
- **Quiz State & Logic:** `QuizSessionState` and `QuizController` (Riverpod `Notifier`) managing question progression, selected options, immediate answer verification, score accumulation, and mastery tier classification.
- **Interactive Quiz View:** `QuizQuestionCard` and option buttons with instant animated feedback (Emerald Green for correct, Crimson Red for incorrect, correct answer reveal, and educational explanation callout).
- **Results & Mastery View:** `QuizResultsView` celebrating achievement with score badges, mastery tiers ("Cosmic Scholar", "Comic Mastermind"), and concept mastery summary.
- **Dedicated Concept Study Screen:** `ConceptStudyScreen` presenting key educational definitions and everyday analogies in interactive study cards.
- **Navigation:** Connect reader screen "Take The Quiz ➔" CTA to `/quiz` route.

**Tech Stack:** Dart 3.13.7, Flutter 3.47.9, `flutter_riverpod`, `flutter_animate`, `go_router`.

---

### File Structure Map

- `lib/features/quiz/data/quiz_session_state.dart`:
  - Immutable state tracking quiz progress, answer history, score, and mastery level.
- `lib/features/quiz/presentation/controllers/quiz_controller.dart`:
  - Riverpod Notifier managing quiz lifecycle, option selection, explanation visibility, and retries.
- `lib/features/quiz/presentation/widgets/quiz_option_card.dart`:
  - Interactive option card with tactile comic styling and state-driven colors (neutral, correct, incorrect).
- `lib/features/quiz/presentation/widgets/quiz_results_view.dart`:
  - Score summary card, mastery tier badge, and retake/review action CTAs.
- `lib/features/quiz/presentation/quiz_screen.dart`:
  - Main quiz host screen with question scrubber, active question card, and results transition.
- `lib/features/quiz/presentation/concept_study_screen.dart`:
  - Dedicated full-screen concept & analogy flashcard study experience.
- `lib/app/router.dart`:
  - Register `/quiz` and `/concepts` routes.
- `test/quiz_controller_test.dart`:
  - Unit tests for option selection, scoring, answer locking, and mastery level calculation.
- `test/quiz_screen_test.dart`:
  - Widget tests for question rendering, option selection, immediate feedback, and results summary.

---

### Tasks

- [x] **Task 1: Quiz State Model & Riverpod Controller**
  - Create `lib/features/quiz/data/quiz_session_state.dart`.
  - Create `lib/features/quiz/presentation/controllers/quiz_controller.dart`.

- [x] **Task 2: Interactive Option Card & Quiz Results Widgets**
  - Create `lib/features/quiz/presentation/widgets/quiz_option_card.dart`.
  - Create `lib/features/quiz/presentation/widgets/quiz_results_view.dart`.

- [x] **Task 3: Quiz Screen & Concept Study Screen**
  - Create `lib/features/quiz/presentation/quiz_screen.dart`.
  - Create `lib/features/quiz/presentation/concept_study_screen.dart`.

- [x] **Task 4: Router Integration & Reader Wire-up**
  - Update `lib/app/router.dart` with `/quiz` and `/concepts`.
  - Update `lib/features/comic_reader/presentation/comic_reader_screen.dart` to navigate to `/quiz`.

- [x] **Task 5: Unit & Widget Tests and Integration Verification**
  - Write `test/quiz_controller_test.dart`.
  - Write `test/quiz_screen_test.dart`.
  - Run `flutter analyze` and `flutter test`.
