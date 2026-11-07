# Milestone 6: Interactive Comic Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a digital comic and webtoon reader experience for Lorvani, featuring dual reading modes (horizontal page-turn & vertical webtoon scroll), tap-to-expand zoomable panel view, audio narration (TTS), comic sound effect badges, an educational concept side sheet / drawer, and seamless navigation to quizzes.

**Architecture:**
- **TTS Service Layer:** `ComicTtsService` abstracting `flutter_tts` with headless/test mock fallback, speech queueing, and speaking state tracking.
- **Reader State & Controller:** `ComicReaderController` (Riverpod `Notifier`) managing current panel index, reading mode (`horizontalPage` vs `verticalScroll`), audio playback status, and active expanded panel.
- **Visual Comic Widgets:**
  - `ComicSoundBadge`: Eye-catching visual pop-art stickers ("ZAP!", "POW!", "AHA!", "DISCOVERY!").
  - `ComicPanelCard`: Full-fidelity panel display combining image view, narration box, speech bubbles, and sound badge.
  - `ConceptSideSheet`: Bottom sheet / slide-over inspector displaying key concepts, definitions, analogies, and character bios.
  - `ExpandedPanelDialog`: Fullscreen zoomable inspection view with `InteractiveViewer`.
- **Reader Screen:** `ComicReaderScreen` providing top app bar with mode toggle, TTS speaker button, concept drawer trigger, and bottom panel scrubber.

**Tech Stack:** Dart 3.13.7, Flutter 3.47.9, `flutter_riverpod`, `flutter_tts`, `flutter_animate`, `go_router`.

---

### File Structure Map

- `lib/core/services/audio/comic_tts_service.dart`:
  - TTS speech engine interface and implementation with platform error resilience.
- `lib/features/comic_reader/data/comic_reader_state.dart`:
  - State tracking reading mode (`horizontalPage` vs `verticalScroll`), current panel, TTS playback state, and educational drawer visibility.
- `lib/features/comic_reader/presentation/controllers/comic_reader_controller.dart`:
  - Riverpod Notifier orchestrating panel stepping, mode switching, and narration playback.
- `lib/features/comic_reader/presentation/widgets/comic_sound_badge.dart`:
  - Pop-art comic sound effect word badges ("ZAP!", "BOOM!", "AHA!", "EUREKA!").
- `lib/features/comic_reader/presentation/widgets/expanded_panel_dialog.dart`:
  - Zoomable fullscreen panel inspection modal.
- `lib/features/comic_reader/presentation/widgets/concept_side_sheet.dart`:
  - Educational reference inspector for definitions, analogies, and characters.
- `lib/features/comic_reader/presentation/widgets/comic_panel_card.dart`:
  - Assembles the panel illustration, sound badges, narration box, and interactive speech bubbles.
- `lib/features/comic_reader/presentation/comic_reader_screen.dart`:
  - Main reader view with horizontal PageView and vertical ListView modes, progress scrubber, and quiz prompt.
- `lib/app/router.dart`:
  - Register `/reader` route accepting `ComicStory`.
- `test/comic_tts_service_test.dart`:
  - Unit tests for TTS text generation and state transitions.
- `test/comic_reader_controller_test.dart`:
  - Unit tests for panel stepping, reading mode toggling, and TTS controls.
- `test/comic_reader_screen_test.dart`:
  - Widget tests for dual reading modes, sound badges, concept sheet, and panel expansion.

---

### Tasks

- [x] **Task 1: Audio Narration & TTS Service**
  - Create `lib/core/services/audio/comic_tts_service.dart`.
  - Implement speaking queue, rate/pitch adjustment, stop/pause, and mock mode for tests.

- [x] **Task 2: Comic Reader State & Riverpod Controller**
  - Create `lib/features/comic_reader/data/comic_reader_state.dart`.
  - Create `lib/features/comic_reader/presentation/controllers/comic_reader_controller.dart`.

- [x] **Task 3: Comic Sound Badge, Expanded Panel Dialog & Concept Side Sheet**
  - Create `lib/features/comic_reader/presentation/widgets/comic_sound_badge.dart`.
  - Create `lib/features/comic_reader/presentation/widgets/expanded_panel_dialog.dart`.
  - Create `lib/features/comic_reader/presentation/widgets/concept_side_sheet.dart`.
  - Create `lib/features/comic_reader/presentation/widgets/comic_panel_card.dart`.

- [x] **Task 4: Interactive Comic Reader Screen & Navigation**
  - Create `lib/features/comic_reader/presentation/comic_reader_screen.dart`.
  - Update `lib/app/router.dart` with `/reader` route.
  - Wire story generation preview screen ("Start Reading" button) to navigate to `/reader`.

- [x] **Task 5: Unit & Widget Tests and Verification**
  - Write `test/comic_tts_service_test.dart`.
  - Write `test/comic_reader_controller_test.dart`.
  - Write `test/comic_reader_screen_test.dart`.
  - Run `flutter analyze` and `flutter test`.
