import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/export/comic_pdf_export_service.dart';
import '../../../../core/services/share/comic_share_service.dart';
import '../../../../core/services/storage/story_storage_service.dart';
import '../../../../data/models/comic_story_model.dart';
import '../../data/library_state.dart';

final storyStorageServiceProvider = Provider<StoryStorageService>((ref) {
  return StoryStorageService();
});

final comicPdfExportServiceProvider = Provider<ComicPdfExportService>((ref) {
  return const ComicPdfExportService();
});

final comicShareServiceProvider = Provider<ComicShareService>((ref) {
  return ComicShareService();
});

final libraryControllerProvider =
    NotifierProvider<LibraryController, LibraryState>(
  LibraryController.new,
);

class LibraryController extends Notifier<LibraryState> {
  late StoryStorageService _storageService;
  late ComicPdfExportService _pdfService;
  late ComicShareService _shareService;

  @override
  LibraryState build() {
    _storageService = ref.watch(storyStorageServiceProvider);
    _pdfService = ref.watch(comicPdfExportServiceProvider);
    _shareService = ref.watch(comicShareServiceProvider);
    return const LibraryState();
  }

  // Dependency injection helper for tests
  void setDependencies({
    StoryStorageService? storageService,
    ComicPdfExportService? pdfService,
    ComicShareService? shareService,
  }) {
    if (storageService != null) _storageService = storageService;
    if (pdfService != null) _pdfService = pdfService;
    if (shareService != null) _shareService = shareService;
  }

  /// Loads all saved stories from local storage
  Future<void> loadSavedStories() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final savedList = await _storageService.getSavedStories();
      state = state.copyWith(
        stories: savedList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load library: $e',
      );
    }
  }

  /// Updates keyword search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Sets subject category filter
  void setSelectedSubject(String subject) {
    state = state.copyWith(selectedSubject: subject);
  }

  /// Sets learning level filter
  void setSelectedLevel(String level) {
    state = state.copyWith(selectedLevel: level);
  }

  /// Saves a story to local offline storage and refreshes library
  Future<bool> saveStory(ComicStory story) async {
    final success = await _storageService.saveStory(story);
    if (success) {
      await loadSavedStories();
    }
    return success;
  }

  /// Deletes a story from local offline storage and updates state
  Future<bool> deleteStory(String storyId) async {
    final success = await _storageService.deleteStory(storyId);
    if (success) {
      final updatedList = state.stories.where((s) => s.id != storyId).toList();
      state = state.copyWith(stories: updatedList);
    }
    return success;
  }

  /// Checks if a story is saved
  Future<bool> isStorySaved(String storyId) async {
    return await _storageService.isStorySaved(storyId);
  }

  /// Generates printable PDF and triggers share dialog
  Future<bool> exportAndSharePdf(ComicStory story) async {
    try {
      final pdfBytes = _pdfService.generateComicPdfBytes(story);
      return await _shareService.sharePdfComicBook(
        story: story,
        pdfBytes: pdfBytes,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'PDF export failed: $e');
      return false;
    }
  }

  /// Shares textual summary of the story
  Future<bool> shareStorySummary(ComicStory story) async {
    return await _shareService.shareStorySummary(story);
  }
}

