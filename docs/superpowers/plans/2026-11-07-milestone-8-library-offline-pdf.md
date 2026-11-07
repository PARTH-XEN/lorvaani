# Milestone 8: Library, Offline Support and PDF Export Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete offline story library, persistent local storage, search/filtering system, PDF printable comic book generation, and social/export sharing features for Lorvani.

**Architecture:**
- **Local Persistence & Offline Storage:** `StoryStorageService` serializing and persisting `ComicStory` models to local storage via `shared_preferences` with in-memory caching and mock fallback for testing.
- **Library State Management:** `LibraryController` (Riverpod `Notifier`) managing saved stories, keyword search queries, subject category filters, learning level filters, and story deletion.
- **PDF Export Generator:** `ComicPdfExportService` using `syncfusion_flutter_pdf` to generate multi-page printable graphic novel PDFs (Cover page, Panel Grid with dialogue, and Concept/Quiz appendix).
- **Share Service:** `ComicShareService` wrapping `share_plus` to export text summaries, quotes, and PDF comic books.
- **Library UI:** Production-ready `LibraryScreen` replacing the placeholder, complete with search bar, filter chips, saved story cards, and empty states.
- **Reader Integration:** Save/bookmark toggle and Export PDF action integrated into `ComicReaderScreen`.

**Tech Stack:** Dart 3.13.7, Flutter 3.47.9, `shared_preferences`, `syncfusion_flutter_pdf`, `share_plus`, `flutter_riverpod`, `go_router`.

---

### File Structure Map

- `lib/core/services/storage/story_storage_service.dart`:
  - Persistent local storage service for saving, loading, and deleting stories with offline caching.
- `lib/core/services/export/comic_pdf_export_service.dart`:
  - Multi-page graphic novel PDF generator with cover page, panel grids, dialogues, and quiz appendix.
- `lib/core/services/share/comic_share_service.dart`:
  - Story summary, quote, and file sharing via `share_plus`.
- `lib/features/library/data/library_state.dart`:
  - State tracking loaded stories, search text, subject filters, and level filters.
- `lib/features/library/presentation/controllers/library_controller.dart`:
  - Riverpod Notifier orchestrating library load, search, filter, and story removal.
- `lib/features/library/presentation/widgets/saved_story_card.dart`:
  - Tactile comic card displaying story overview, badges, read action, PDF export, and delete options.
- `lib/features/library/presentation/library_screen.dart`:
  - Full production library view with search, filter chips, empty states, and story list.
- `lib/app/router.dart`:
  - Wire `LibraryScreen` into the shell router `/library` route.
- `test/story_storage_service_test.dart`:
  - Unit tests for local storage serialization, saving, loading, and deletion.
- `test/comic_pdf_export_service_test.dart`:
  - Unit tests for printable PDF generation structure and byte integrity.
- `test/library_controller_test.dart`:
  - Unit tests for library search, category filtering, level filtering, and story deletion.
- `test/library_screen_test.dart`:
  - Widget tests for search, chip filtering, story card actions, and empty states.

---

### Tasks

- [x] **Task 1: Story Storage Service (Persistence & Offline Caching)**
  - Create `lib/core/services/storage/story_storage_service.dart`.
  - Implement JSON serialization, persistence, save/delete, and test mode.

- [x] **Task 2: Comic PDF Export & Share Services**
  - Create `lib/core/services/export/comic_pdf_export_service.dart`.
  - Create `lib/core/services/share/comic_share_service.dart`.

- [x] **Task 3: Library State & Riverpod Controller**
  - Create `lib/features/library/data/library_state.dart`.
  - Create `lib/features/library/presentation/controllers/library_controller.dart`.

- [x] **Task 4: Library Screen UI & Reader Screen Integration**
  - Create `lib/features/library/presentation/widgets/saved_story_card.dart`.
  - Create `lib/features/library/presentation/library_screen.dart`.
  - Update `lib/app/router.dart` with `LibraryScreen`.
  - Update `lib/features/comic_reader/presentation/comic_reader_screen.dart` with save bookmark and PDF export actions.

- [x] **Task 5: Unit & Widget Tests and Integration Verification**
  - Write `test/story_storage_service_test.dart`.
  - Write `test/comic_pdf_export_service_test.dart`.
  - Write `test/library_controller_test.dart`.
  - Write `test/library_screen_test.dart`.
  - Run `flutter analyze` and `flutter test`.
