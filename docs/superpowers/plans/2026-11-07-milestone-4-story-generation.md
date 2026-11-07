# Milestone 4: AI Story Generation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the end-to-end AI educational story generation pipeline, including strict JSON schema modeling, schema validation, prompt template engineering, interactive story customization UI, animated generation progress, and controlled retries.

**Architecture:** Domain model layer (`ComicStory`, `ComicCharacter`, `ComicPanelModel`, `ComicKeyConcept`, `ComicAnalogy`, `ComicQuizQuestion`), schema defense validator (`StorySchemaValidator`), prompt builder (`StoryPromptBuilder`), Riverpod generation controller (`StoryGenerationController`), and comic UI screens (`StoryCustomizationScreen`, `StoryGenerationProgressScreen`).

**Tech Stack:** Dart 3.13.7, Flutter 3.47.9, `flutter_riverpod`, `flutter_animate`, `go_router`.

---

### File Structure Map

- `lib/data/models/comic_story_model.dart`: Complete data models with `fromJson`, `toJson`, and `copyWith`.
- `lib/core/utils/story_schema_validator.dart`: Validation utility verifying all mandatory story keys, panel counts, dialogue speaker structures, and quiz option bounds.
- `lib/features/story_generation/services/story_prompt_builder.dart`: Prompt template builder constructing system instructions and user payloads.
- `lib/features/story_generation/data/story_generation_state.dart`: Immutable state tracking generation status, progress step, error message, and result story.
- `lib/features/story_generation/presentation/controllers/story_generation_controller.dart`: Riverpod Notifier orchestrating LLM calls, validation, and controlled retries.
- `lib/features/story_generation/presentation/story_customization_screen.dart`: Visual customization screen for level, art style, length, and language.
- `lib/features/story_generation/presentation/story_generation_progress_screen.dart`: Animated creation progress screen with comic progress steps, error retry handling, and story preview.
- `lib/app/router.dart`: Router updates for `/customize` and `/generate-progress`.
- `test/comic_story_model_test.dart`: Unit tests for model parsing and schema validation.
- `test/story_prompt_builder_test.dart`: Unit tests for prompt template construction and constraints.
- `test/story_generation_controller_test.dart`: Unit tests for generation lifecycle, retry on malformed JSON, and error handling.
- `test/story_customization_screen_test.dart`: Widget test for option selection and generation navigation.

---

### Tasks

- [x] **Task 1: Comic Story Data Models & Schema Validator**
  - Create `lib/data/models/comic_story_model.dart`.
  - Create `lib/core/utils/story_schema_validator.dart`.

- [x] **Task 2: Story Prompt Template Builder**
  - Create `lib/features/story_generation/services/story_prompt_builder.dart`.

- [x] **Task 3: Story Generation State & Riverpod Controller**
  - Create `lib/features/story_generation/data/story_generation_state.dart`.
  - Create `lib/features/story_generation/presentation/controllers/story_generation_controller.dart`.

- [x] **Task 4: Story Customization & Generation Progress UI**
  - Create `lib/features/story_generation/presentation/story_customization_screen.dart`.
  - Create `lib/features/story_generation/presentation/story_generation_progress_screen.dart`.
  - Update `lib/features/story_input/presentation/story_input_screen.dart` to navigate to customization.
  - Update `lib/app/router.dart`.

- [x] **Task 5: Unit & Widget Tests**
  - Write `test/comic_story_model_test.dart`.
  - Write `test/story_prompt_builder_test.dart`.
  - Write `test/story_generation_controller_test.dart`.
  - Write `test/story_customization_screen_test.dart`.
  - Run `flutter analyze` and `flutter test`.
