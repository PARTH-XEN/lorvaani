import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/services/audio/comic_tts_service.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/comic_reader/presentation/comic_reader_screen.dart';
import 'package:lorevaani/features/comic_reader/presentation/controllers/comic_reader_controller.dart';

void main() {
  final sampleStory = ComicStory(
    id: 'story_optics_ui',
    storyTitle: 'The Quantum Prism',
    originalTopic: 'Physics: Optics',
    learningLevel: 'Intermediate',
    visualStyle: 'Classic Comic',
    language: 'English',
    shortIntroduction: 'Discover how white light splits into a rainbow.',
    storySetting: 'Optics Laboratory',
    characters: const [
      ComicCharacter(
        name: 'Newton',
        role: 'Physicist',
        visualDescription: 'blue velvet lab coat',
      ),
    ],
    panels: const [
      ComicPanelModel(
        panelNumber: 1,
        panelTitle: 'Prism Refraction',
        panelDescription: 'White beam enters triangular glass',
        narration: 'Different wavelengths bend at different angles.',
        dialogue: [
          ComicDialogue(speaker: 'Newton', text: 'Splitting wavelengths!'),
        ],
        keyVisualCue: 'Prism with brilliant rainbow spectrum',
      ),
      ComicPanelModel(
        panelNumber: 2,
        panelTitle: 'Color Spectrum',
        panelDescription: 'Rainbow colors fan out onto screen',
        narration: 'Red bends least; violet bends most.',
        dialogue: [
          ComicDialogue(speaker: 'Newton', text: 'ROYGBIV revealed!'),
        ],
        keyVisualCue: 'Projected spectrum on white wall',
      ),
    ],
    keyConcepts: const [
      ComicKeyConcept(
        term: 'Refraction',
        definition: 'Bending of light waves across mediums.',
      ),
    ],
    analogies: const [
      ComicAnalogy(
        targetConcept: 'Refraction',
        everydayAnalogy: 'Shopping cart wheels hitting grass on one side.',
        whyItWorks: 'One side slows down first, changing direction.',
      ),
    ],
    summary: 'Light refraction creates the visible spectrum.',
    quizQuestions: const [
      ComicQuizQuestion(
        question: 'Which light color bends the most through a prism?',
        options: ['Red', 'Violet', 'Green', 'Yellow'],
        correctAnswerIndex: 1,
        explanation: 'Violet has the shortest wavelength and bends the most.',
      ),
    ],
    createdAt: DateTime.now(),
  );

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        comicTtsServiceProvider.overrideWithValue(ComicTtsService(isMockMode: true)),
      ],
      child: MaterialApp(
        home: ComicReaderScreen(story: sampleStory),
      ),
    );
  }

  group('ComicReaderScreen Widget Tests', () {
    testWidgets('renders top bar, panel title, narration, dialogue, and progress bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('The Quantum Prism'), findsOneWidget);
      expect(find.text('Physics: Optics'), findsOneWidget);
      expect(find.text('PRISM REFRACTION'), findsWidgets);
      expect(find.textContaining('Different wavelengths bend'), findsOneWidget);
      expect(find.textContaining('Splitting wavelengths!'), findsWidgets);
      expect(find.text('PANEL 1 OF 2'), findsOneWidget);
      expect(find.text('Next Panel ➔'), findsOneWidget);
    });

    testWidgets('toggles reading mode from page to continuous scroll', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final modeToggleFinder = find.byTooltip('Switch to Continuous Scroll');
      expect(modeToggleFinder, findsOneWidget);

      await tester.tap(modeToggleFinder);
      await tester.pumpAndSettle();

      // Now both panels are visible in the continuous scroll ListView!
      expect(find.text('COLOR SPECTRUM'), findsWidgets);
    });

    testWidgets('opens concept drawer and displays definitions and analogies', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final conceptButton = find.byTooltip('Educational Intel');
      expect(conceptButton, findsOneWidget);

      await tester.tap(conceptButton);
      await tester.pumpAndSettle();

      expect(find.text('EDUCATIONAL INTEL'), findsOneWidget);
      expect(find.text('KEY CONCEPTS'), findsOneWidget);
      expect(find.text('Refraction'), findsOneWidget);
      expect(find.textContaining('Bending of light waves'), findsOneWidget);
      expect(find.text('EVERYDAY ANALOGIES'), findsOneWidget);
      expect(find.textContaining('Shopping cart wheels'), findsOneWidget);
    });

    testWidgets('advancing to last panel displays Take The Quiz button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final nextButton = find.text('Next Panel ➔');
      expect(nextButton, findsOneWidget);

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('PANEL 2 OF 2'), findsOneWidget);
      expect(find.text('Take The Quiz ➔'), findsOneWidget);
    });
  });
}
