# Milestone 3: Input, OCR and PDF Import Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a comprehensive learning material input hub supporting manual typing, clipboard pasting, camera scanning, image import, OCR extraction with review & correction, PDF document text parsing with scanned-document detection, and robust validation.

**Architecture:** Service-oriented document extraction layer (`OcrService`, `PdfExtractorService`), Riverpod-driven input state management (`StoryInputState`, `StoryInputController`), and a tactile comic UI featuring live word counters, content health indicators, sample educational notes picker, and an editable review dialog.

**Tech Stack:** Dart 3.13.7, Flutter 3.47.9, `flutter_riverpod`, `image_picker`, `file_picker`, `syncfusion_flutter_pdf`.

---

### File Structure Map

- `lib/core/services/document/document_processing_types.dart`: Extracted text models, extraction source enums, and document exceptions.
- `lib/core/services/document/ocr_service.dart`: Optical Character Recognition service processing images, normalizing text lines, and detecting quality issues.
- `lib/core/services/document/pdf_extractor_service.dart`: PDF text extraction service with page iteration, scanned PDF detection, and error handling.
- `lib/features/story_input/data/story_input_state.dart`: Immutable state representation for learning material inputs.
- `lib/features/story_input/presentation/controllers/story_input_controller.dart`: Riverpod Notifier for managing input methods, clipboard paste, OCR/PDF workflows, and validation.
- `lib/features/story_input/presentation/widgets/extracted_text_review_sheet.dart`: Comic modal dialog for inspecting, editing, and accepting extracted OCR/PDF text.
- `lib/features/story_input/presentation/widgets/input_action_bar.dart`: Quick-access comic action buttons for Paste, Scan, Gallery, and PDF.
- `lib/features/story_input/presentation/story_input_screen.dart`: Complete interactive input screen replacing the placeholder.
- `test/pdf_extractor_service_test.dart`: Tests for PDF text extraction and scanned document detection.
- `test/ocr_service_test.dart`: Tests for text recognition, cleaning, and error conditions.
- `test/story_input_screen_test.dart`: Widget tests for user input, paste, character count, sample loader, and validation.

---

### Tasks

- [x] **Task 1: Document Processing Services & Types**
  - Create `lib/core/services/document/document_processing_types.dart`.
  - Create `lib/core/services/document/ocr_service.dart`.
  - Create `lib/core/services/document/pdf_extractor_service.dart`.

- [x] **Task 2: Story Input State & Riverpod Controller**
  - Create `lib/features/story_input/data/story_input_state.dart`.
  - Create `lib/features/story_input/presentation/controllers/story_input_controller.dart`.

- [x] **Task 3: Extracted Text Review & Edit Sheet**
  - Implement `ExtractedTextReviewSheet` with comic panel borders, source badge, character metrics, and editable text preview.

- [x] **Task 4: Story Input Screen Implementation**
  - Update `lib/features/story_input/presentation/story_input_screen.dart` with topic title input, sample notes, live word counters, camera/image/PDF/paste actions, and validation.
  - Update `lib/app/router.dart` to use the complete screen.

- [x] **Task 5: Unit & Widget Tests**
  - Write `test/ocr_service_test.dart`.
  - Write `test/pdf_extractor_service_test.dart`.
  - Write `test/story_input_screen_test.dart`.
  - Run `flutter analyze` and `flutter test`.
