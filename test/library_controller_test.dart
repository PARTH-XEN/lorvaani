import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/services/export/comic_pdf_export_service.dart';
import 'package:lorevaani/core/services/share/comic_share_service.dart';
import 'package:lorevaani/core/services/storage/story_storage_service.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/library/presentation/controllers/library_controller.dart';

void main() {
  group('LibraryController Tests', () {
    late ProviderContainer container;
    late StoryStorageService storage;
    late ComicShareService shareService;
    late ComicStory storyBio;
    late ComicStory storyPhysics;

    setUp(() {
      storage = StoryStorageService(isTestMode: true);
      shareService = ComicShareService(isTestMode: true);

      storyBio = ComicStory(
        id: 'bio_1',
        storyTitle: 'Photosynthesis Quest',
        originalTopic: 'Biology',
        learningLevel: 'Beginner',
        visualStyle: 'Classic Comic',
        language: 'English',
        shortIntroduction: 'Chloroplasts at work.',
        storySetting: 'Leaf cell',
        characters: const [],
        panels: const [],
        keyConcepts: const [],
        analogies: const [],
        summary: 'Making plant food.',
        quizQuestions: const [],
        createdAt: DateTime(2026, 11, 7, 8, 0),
      );

      storyPhysics = ComicStory(
        id: 'physics_1',
        storyTitle: 'Quantum Entanglement',
        originalTopic: 'Physics',
        learningLevel: 'Advanced',
        visualStyle: 'Cinematic Comic',
        language: 'English',
        shortIntroduction: 'Spooky action at a distance.',
        storySetting: 'Quantum lab',
        characters: const [],
        panels: const [],
        keyConcepts: const [],
        analogies: const [],
        summary: 'Instantaneous correlation.',
        quizQuestions: const [],
        createdAt: DateTime(2026, 11, 7, 10, 0),
      );

      storage.setTestStories([storyBio, storyPhysics]);

      container = ProviderContainer(
        overrides: [
          storyStorageServiceProvider.overrideWithValue(storage),
          comicPdfExportServiceProvider.overrideWithValue(const ComicPdfExportService()),
          comicShareServiceProvider.overrideWithValue(shareService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads saved stories from storage', () async {
      final controller = container.read(libraryControllerProvider.notifier);
      await controller.loadSavedStories();

      final state = container.read(libraryControllerProvider);
      expect(state.totalCount, equals(2));
      expect(state.filteredCount, equals(2));
      expect(state.isLoading, isFalse);
    });

    test('filters stories by keyword search query', () async {
      final controller = container.read(libraryControllerProvider.notifier);
      await controller.loadSavedStories();

      controller.setSearchQuery('quantum');
      var state = container.read(libraryControllerProvider);
      expect(state.filteredCount, equals(1));
      expect(state.filteredStories.first.storyTitle, equals('Quantum Entanglement'));

      controller.setSearchQuery('photosynthesis');
      state = container.read(libraryControllerProvider);
      expect(state.filteredCount, equals(1));
      expect(state.filteredStories.first.storyTitle, equals('Photosynthesis Quest'));

      controller.setSearchQuery('non_existent');
      state = container.read(libraryControllerProvider);
      expect(state.filteredCount, equals(0));
    });

    test('filters stories by subject category', () async {
      final controller = container.read(libraryControllerProvider.notifier);
      await controller.loadSavedStories();

      controller.setSelectedSubject('Physics');
      var state = container.read(libraryControllerProvider);
      expect(state.filteredCount, equals(1));
      expect(state.filteredStories.first.originalTopic, equals('Physics'));

      controller.setSelectedSubject('Biology');
      state = container.read(libraryControllerProvider);
      expect(state.filteredCount, equals(1));
      expect(state.filteredStories.first.originalTopic, equals('Biology'));

      controller.setSelectedSubject('All');
      state = container.read(libraryControllerProvider);
      expect(state.filteredCount, equals(2));
    });

    test('filters stories by learning level', () async {
      final controller = container.read(libraryControllerProvider.notifier);
      await controller.loadSavedStories();

      controller.setSelectedLevel('Advanced');
      var state = container.read(libraryControllerProvider);
      expect(state.filteredCount, equals(1));
      expect(state.filteredStories.first.learningLevel, equals('Advanced'));

      controller.setSelectedLevel('Beginner');
      state = container.read(libraryControllerProvider);
      expect(state.filteredCount, equals(1));
      expect(state.filteredStories.first.learningLevel, equals('Beginner'));
    });

    test('deletes story and updates library state', () async {
      final controller = container.read(libraryControllerProvider.notifier);
      await controller.loadSavedStories();

      final success = await controller.deleteStory('bio_1');
      expect(success, isTrue);

      final state = container.read(libraryControllerProvider);
      expect(state.totalCount, equals(1));
      expect(state.stories.first.id, equals('physics_1'));
    });

    test('exports and shares story PDF', () async {
      final controller = container.read(libraryControllerProvider.notifier);
      final success = await controller.exportAndSharePdf(storyBio);

      expect(success, isTrue);
      expect(shareService.lastSharedSubject, contains('Photosynthesis'));
    });
  });
}

