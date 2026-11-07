# Milestone 5: AI Image Generation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete AI Comic Panel Image Generation pipeline, featuring per-panel prompt engineering, character consistency maintenance via seeds and character descriptions, resilient image caching, progress and status updates, rich programmatic fallback artwork for offline/failures, and individual panel retry mechanisms.

**Architecture:**
- **Prompt Engineering & Character Consistency:** `ComicImagePromptService` synthesizes scene descriptions, key visual cues, art style tokens, and character visual attributes into unified prompts with deterministic seed generation per character/story.
- **Image Generation Pipeline & Controller:** `ComicImageController` (Riverpod) and `ComicImageGenerationService` orchestrate multi-panel image generation with progress tracking, concurrency limits, and failure handling.
- **Local & In-Memory Caching:** `ComicImageCacheService` manages cached image URLs, pre-fetched byte streams, and in-memory LRU maps to support offline reading and rapid rendering.
- **Comic Visual UI Components:** `ComicPanelImageView` and `ComicFallbackPanelArtwork` provide stylized comic loading shimmers, high-fidelity graphic novel fallback art, and 1-tap panel retry overlays so readers never experience a broken UI.

**Tech Stack:** Dart 3.13.7, Flutter 3.47.9, `flutter_riverpod`, `flutter_animate`, `http`.

---

### File Structure Map

- `lib/features/image_generation/services/comic_image_prompt_service.dart`:
  - Assembles prompt per panel combining style tokens, setting, character appearances, and visual cues.
  - Calculates deterministic seed for character consistency.
- `lib/features/image_generation/services/comic_image_cache_service.dart`:
  - Caches image URLs, metadata, and handles preloading/offline caching.
- `lib/features/image_generation/data/panel_image_state.dart`:
  - Immutable state models tracking per-panel generation progress, errors, and image URLs.
- `lib/features/image_generation/presentation/controllers/comic_image_controller.dart`:
  - Riverpod Notifier managing story-wide and panel-by-panel image generation lifecycle.
- `lib/features/image_generation/presentation/widgets/comic_fallback_panel_artwork.dart`:
  - Programmatic graphic novel artwork widget with halftone dots, stylized character badges, dynamic scene banners, and narration preview when generation is unavailable or offline.
- `lib/features/image_generation/presentation/widgets/comic_panel_image_view.dart`:
  - Comprehensive comic image display widget supporting loading shimmer, animated transitions, fallback rendering, and retry action.
- `test/comic_image_prompt_service_test.dart`:
  - Unit tests for prompt construction, character visual merging, and seed consistency.
- `test/comic_image_cache_service_test.dart`:
  - Unit tests for cache storage, retrieval, and cache hit/miss behavior.
- `test/comic_image_controller_test.dart`:
  - Unit tests for multi-panel generation orchestration, progress reporting, and error fallback.
- `test/comic_panel_image_view_test.dart`:
  - Widget tests for loading, loaded, and fallback error states.

---

### Tasks

- [x] **Task 1: Comic Image Prompt Service & Consistency Engine**
  - Create `lib/features/image_generation/services/comic_image_prompt_service.dart`.
  - Implement style token mapping, character appearance merging, negative prompts, and deterministic seed generation.

- [x] **Task 2: Image Caching & Local Storage Service**
  - Create `lib/features/image_generation/services/comic_image_cache_service.dart`.
  - Implement cache map, eviction policy, cache key calculation, and optional byte caching.

- [x] **Task 3: Panel Image Generation State & Riverpod Controller**
  - Create `lib/features/image_generation/data/panel_image_state.dart`.
  - Create `lib/features/image_generation/presentation/controllers/comic_image_controller.dart`.
  - Wire to `aiOrchestratorProvider` and `MockImageProvider` fallback.

- [x] **Task 4: Comic Fallback Artwork & Panel Image UI Widgets**
  - Create `lib/features/image_generation/presentation/widgets/comic_fallback_panel_artwork.dart`.
  - Create `lib/features/image_generation/presentation/widgets/comic_panel_image_view.dart`.

- [x] **Task 5: Unit & Widget Tests and Integration Verification**
  - Write `test/comic_image_prompt_service_test.dart`.
  - Write `test/comic_image_cache_service_test.dart`.
  - Write `test/comic_image_controller_test.dart`.
  - Write `test/comic_panel_image_view_test.dart`.
  - Run `flutter analyze` and `flutter test`.
