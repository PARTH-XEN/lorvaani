import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/storage/story_storage_service.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';

void main() {
  group('StoryStorageService Tests', () {
    late StoryStorageService storage;
    late ComicStory storyA;
    late ComicStory storyB;

    setUp(() {
      storage = StoryStorageService(isTestMode: true);

      storyA = ComicStory(
        id: 'story_cell_biology',
        storyTitle: 'Cell Biology Adventure',
        originalTopic: 'Biology',
        learningLevel: 'Intermediate',
        visualStyle: 'Classic Comic',
        language: 'English',
        shortIntroduction: 'Explore the cell organelles.',
        storySetting: 'Inside the cell',
        characters: const [],
        panels: const [],
        keyConcepts: const [],
        analogies: const [],
        summary: 'Cells are the fundamental units of life.',
        quizQuestions: const [],
        createdAt: DateTime(2026, 11, 7, 10, 0),
      );

      storyB = ComicStory(
        id: 'story_quantum_physics',
        storyTitle: 'Quantum Realm Quest',
        originalTopic: 'Physics',
        learningLevel: 'Advanced',
        visualStyle: 'Cinematic Comic',
        language: 'English',
        shortIntroduction: 'Explore quantum particles.',
        storySetting: 'Particle collider',
        characters: const [],
        panels: const [],
        keyConcepts: const [],
        analogies: const [],
        summary: 'Particles exhibit wave-particle duality.',
        quizQuestions: const [],
        createdAt: DateTime(2026, 11, 7, 12, 0), // Newer
      );
    });

    test('saves and retrieves stories ordered by date descending', () async {
      await storage.saveStory(storyA);
      await storage.saveStory(storyB);

      final list = await storage.getSavedStories();
      expect(list.length, equals(2));
      expect(list.first.id, equals('story_quantum_physics')); // Newer first
      expect(list.last.id, equals('story_cell_biology'));
      expect(list.first.isSaved, isTrue);
    });

    test('checks if story is saved correctly', () async {
      expect(await storage.isStorySaved('story_cell_biology'), isFalse);

      await storage.saveStory(storyA);
      expect(await storage.isStorySaved('story_cell_biology'), isTrue);
      expect(await storage.isStorySaved('non_existent'), isFalse);
    });

    test('retrieves story by id', () async {
      await storage.saveStory(storyA);

      final retrieved = await storage.getStoryById('story_cell_biology');
      expect(retrieved, isNotNull);
      expect(retrieved!.storyTitle, equals('Cell Biology Adventure'));

      final nonExistent = await storage.getStoryById('unknown');
      expect(nonExistent, isNull);
    });

    test('deletes story from storage', () async {
      await storage.saveStory(storyA);
      await storage.saveStory(storyB);

      expect((await storage.getSavedStories()).length, equals(2));

      await storage.deleteStory('story_cell_biology');

      final list = await storage.getSavedStories();
      expect(list.length, equals(1));
      expect(list.first.id, equals('story_quantum_physics'));
      expect(await storage.isStorySaved('story_cell_biology'), isFalse);
    });

    test('clears all stories', () async {
      await storage.saveStory(storyA);
      await storage.saveStory(storyB);

      await storage.clearAll();

      final list = await storage.getSavedStories();
      expect(list, isEmpty);
    });
  });
}

