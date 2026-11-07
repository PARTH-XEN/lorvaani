import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/services/ai/mock/mock_image_provider.dart';
import 'package:lorevaani/core/services/ai/mock/mock_text_provider.dart';
import 'package:lorevaani/core/services/ai/orchestrator/ai_orchestrator.dart';
import 'package:lorevaani/core/services/audio/comic_tts_service.dart';
import 'package:lorevaani/core/services/export/comic_pdf_export_service.dart';
import 'package:lorevaani/core/services/share/comic_share_service.dart';
import 'package:lorevaani/core/services/storage/story_storage_service.dart';
import 'package:lorevaani/features/comic_reader/presentation/comic_reader_screen.dart';
import 'package:lorevaani/features/comic_reader/presentation/controllers/comic_reader_controller.dart';
import 'package:lorevaani/features/library/presentation/controllers/library_controller.dart';
import 'package:lorevaani/features/library/presentation/library_screen.dart';
import 'package:lorevaani/features/quiz/presentation/quiz_screen.dart';
import 'package:lorevaani/features/story_generation/presentation/controllers/story_generation_controller.dart';
import 'package:lorevaani/features/story_generation/presentation/story_customization_screen.dart';
import 'package:lorevaani/features/story_input/presentation/story_input_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lorvani End-to-End User Journey Tests', () {
    late StoryStorageService testStorage;
    late ComicShareService testShare;
    late AiOrchestrator testOrchestrator;
    late ComicTtsService testTts;

    setUp(() {
      testStorage = StoryStorageService(isTestMode: true);
      testShare = ComicShareService(isTestMode: true);
      testTts = ComicTtsService(isMockMode: true);
      testOrchestrator = AiOrchestrator(
        textProviders: [const MockTextProvider(simulatedDelayMs: 0)],
        imageProviders: [const MockImageProvider(simulatedDelayMs: 0)],
      );
    });

    Widget buildTestHarness(Widget screen) {
      return ProviderScope(
        overrides: [
          aiOrchestratorProvider.overrideWithValue(testOrchestrator),
          comicTtsServiceProvider.overrideWithValue(testTts),
          storyStorageServiceProvider.overrideWithValue(testStorage),
          comicShareServiceProvider.overrideWithValue(testShare),
          comicPdfExportServiceProvider.overrideWithValue(const ComicPdfExportService()),
        ],
        child: MaterialApp(
          home: screen,
        ),
      );
    }

    testWidgets('Full End-to-End: Input -> Customize -> Generate -> Read -> Quiz -> Save & PDF',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // ----------------------------------------------------
      // STEP 1: Story Input Screen
      // ----------------------------------------------------
      await tester.pumpWidget(buildTestHarness(const StoryInputScreen()));
      await tester.pumpAndSettle();

      expect(find.text('INPUT STUDY MATERIAL'), findsOneWidget);
      expect(find.text('Biology: Photosynthesis & Chloroplasts'), findsOneWidget);

      // Tap 1-tap template "Biology: Photosynthesis & Chloroplasts"
      await tester.tap(find.text('Biology: Photosynthesis & Chloroplasts'));
      await tester.pumpAndSettle();

      expect(find.text('Biology: Photosynthesis & Chloroplasts'), findsWidgets);
      expect(find.text('Customize Comic Story'), findsOneWidget);

      // ----------------------------------------------------
      // STEP 2: Story Customization Screen
      // ----------------------------------------------------
      await tester.pumpWidget(buildTestHarness(const StoryCustomizationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('STORY CUSTOMIZER'), findsOneWidget);
      expect(find.text('2. COMIC ART STYLE'), findsOneWidget);
      expect(find.text('1. LEARNING LEVEL'), findsOneWidget);

      // Select 'Anime-inspired' art style
      await tester.tap(find.text('Anime-inspired'));
      await tester.pumpAndSettle();

      expect(find.text('Generate Comic Story'), findsOneWidget);

      // ----------------------------------------------------
      // STEP 3: Generation & Story Creation
      // ----------------------------------------------------
      final container = ProviderContainer(
        overrides: [
          aiOrchestratorProvider.overrideWithValue(testOrchestrator),
        ],
      );

      final generationController = container.read(storyGenerationControllerProvider.notifier);
      bool? genSuccess;
      await tester.runAsync(() async {
        genSuccess = await generationController.generateStory(
          topicTitle: 'Photosynthesis & Sunlight',
          notesText: 'Chloroplasts absorb photons to produce glucose and oxygen.',
        );
      });

      expect(genSuccess, isTrue);
      final generatedStory = container.read(storyGenerationControllerProvider).generatedStory!;
      expect(generatedStory.storyTitle, isNotEmpty);
      expect(generatedStory.panels.length, greaterThanOrEqualTo(2));
      expect(generatedStory.quizQuestions.length, greaterThanOrEqualTo(2));

      // ----------------------------------------------------
      // STEP 4: Story Reader Screen
      // ----------------------------------------------------
      await tester.pumpWidget(buildTestHarness(ComicReaderScreen(story: generatedStory)));
      await tester.pumpAndSettle();

      expect(find.text(generatedStory.storyTitle), findsOneWidget);
      expect(find.text('PANEL 1 OF ${generatedStory.panels.length}'), findsOneWidget);
      expect(find.text('Next Panel ➔'), findsOneWidget);

      // Toggle Reading Mode from page-by-page to continuous scroll
      final modeToggle = find.byTooltip('Switch to Continuous Scroll');
      expect(modeToggle, findsOneWidget);
      await tester.tap(modeToggle);
      await tester.pumpAndSettle();

      // Open Educational Intel drawer
      final intelButton = find.byTooltip('Educational Intel');
      expect(intelButton, findsOneWidget);
      await tester.tap(intelButton);
      await tester.pumpAndSettle();

      expect(find.text('EDUCATIONAL INTEL'), findsOneWidget);
      expect(find.text('KEY CONCEPTS'), findsOneWidget);

      // Close drawer
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // ----------------------------------------------------
      // STEP 5: Interactive Quiz Screen
      // ----------------------------------------------------
      await tester.pumpWidget(buildTestHarness(QuizScreen(story: generatedStory)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Quiz'), findsOneWidget);
      expect(find.text('QUESTION 1 OF ${generatedStory.quizQuestions.length}'), findsOneWidget);

      // Answer Question 1: tap first option
      final q1 = generatedStory.quizQuestions[0];
      await tester.tap(find.text(q1.options[0]));
      await tester.pumpAndSettle();

      expect(find.text('WHY IT WORKS'), findsOneWidget);
      expect(find.text('Next Question ➔'), findsOneWidget);
      await tester.tap(find.text('Next Question ➔'));
      await tester.pumpAndSettle();

      // Answer Question 2: tap second option
      final q2 = generatedStory.quizQuestions[1];
      await tester.tap(find.text(q2.options[0]));
      await tester.pumpAndSettle();

      // Advance to results
      final resultsOrNextButton = find.text(generatedStory.quizQuestions.length == 2
          ? 'See Results ➔'
          : 'Next Question ➔');
      await tester.tap(resultsOrNextButton);
      await tester.pumpAndSettle();

      // If more questions exist, answer them to reach results
      if (generatedStory.quizQuestions.length > 2) {
        for (int i = 2; i < generatedStory.quizQuestions.length; i++) {
          final q = generatedStory.quizQuestions[i];
          await tester.tap(find.text(q.options[0]));
          await tester.pumpAndSettle();
          final nextBtn = find.text(i == generatedStory.quizQuestions.length - 1
              ? 'See Results ➔'
              : 'Next Question ➔');
          await tester.tap(nextBtn);
          await tester.pumpAndSettle();
        }
      }

      expect(find.text('MISSION COMPLETE!'), findsOneWidget);
      expect(find.text('Review Key Concepts'), findsOneWidget);
      expect(find.text('Retake Quiz'), findsOneWidget);

      // ----------------------------------------------------
      // STEP 6: Offline Library & PDF Export
      // ----------------------------------------------------
      // Save story to offline library
      await testStorage.saveStory(generatedStory);
      expect(await testStorage.isStorySaved(generatedStory.id), isTrue);

      // Open Library screen
      await tester.pumpWidget(buildTestHarness(const LibraryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('COMIC LIBRARY'), findsOneWidget);
      expect(find.text('1 Saved'), findsOneWidget);
      expect(find.text(generatedStory.storyTitle), findsOneWidget);
      expect(find.text('Read Comic ➔'), findsOneWidget);

      // Verify PDF Generation
      const pdfExporter = ComicPdfExportService();
      final pdfBytes = pdfExporter.generateComicPdfBytes(generatedStory);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1500));

      container.dispose();
    });
  });
}
