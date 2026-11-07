import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/services/storage/story_storage_service.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/library/presentation/controllers/library_controller.dart';
import 'package:lorevaani/features/library/presentation/library_screen.dart';

void main() {
  final sampleStory = ComicStory(
    id: 'story_optics_lib',
    storyTitle: 'The Quantum Prism',
    originalTopic: 'Physics',
    learningLevel: 'Intermediate',
    visualStyle: 'Classic Comic',
    language: 'English',
    shortIntroduction: 'Discover how white light splits into a rainbow.',
    storySetting: 'Optics Laboratory',
    characters: const [],
    panels: const [
      ComicPanelModel(
        panelNumber: 1,
        panelTitle: 'Refraction',
        panelDescription: 'Beam hits glass',
        narration: 'Wavelengths bend.',
        dialogue: [],
        keyVisualCue: 'Prism',
      ),
    ],
    keyConcepts: const [],
    analogies: const [],
    summary: 'Light refraction creates colors.',
    quizQuestions: const [],
    createdAt: DateTime(2026, 11, 7),
    isSaved: true,
  );

  Widget createTestWidget({required StoryStorageService storage}) {
    return ProviderScope(
      overrides: [
        storyStorageServiceProvider.overrideWithValue(storage),
      ],
      child: const MaterialApp(
        home: LibraryScreen(),
      ),
    );
  }

  group('LibraryScreen Widget Tests', () {
    testWidgets('renders search bar, filter chips, and saved story cards', (tester) async {
      final storage = StoryStorageService(isTestMode: true);
      storage.setTestStories([sampleStory]);

      await tester.pumpWidget(createTestWidget(storage: storage));
      await tester.pumpAndSettle();

      expect(find.text('COMIC LIBRARY'), findsOneWidget);
      expect(find.text('1 Saved'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('The Quantum Prism'), findsOneWidget);
      expect(find.text('Physics'), findsWidgets);
      expect(find.text('Read Comic ➔'), findsOneWidget);
    });

    testWidgets('renders empty state when library has no saved stories', (tester) async {
      final storage = StoryStorageService(isTestMode: true);

      await tester.pumpWidget(createTestWidget(storage: storage));
      await tester.pumpAndSettle();

      expect(find.text('LIBRARY IS EMPTY'), findsOneWidget);
      expect(find.text('Create Your First Story'), findsOneWidget);
    });

    testWidgets('searching for unmatched query shows no stories matched empty state', (tester) async {
      final storage = StoryStorageService(isTestMode: true);
      storage.setTestStories([sampleStory]);

      await tester.pumpWidget(createTestWidget(storage: storage));
      await tester.pumpAndSettle();

      // Enter search query that doesn't match
      await tester.enterText(find.byType(TextField), 'Photosynthesis');
      await tester.pumpAndSettle();

      expect(find.text('NO STORIES MATCHED'), findsOneWidget);
      expect(find.text('Clear All Filters'), findsOneWidget);
    });
  });
}

