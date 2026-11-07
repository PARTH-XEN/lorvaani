import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/services/audio/comic_tts_service.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/comic_reader/data/comic_reader_state.dart';
import 'package:lorevaani/features/comic_reader/presentation/controllers/comic_reader_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ComicReaderController Tests', () {
    late ProviderContainer container;
    late ComicStory sampleStory;
    late ComicTtsService mockTts;

    setUp(() {
      sampleStory = ComicStory(
        id: 'story_optics',
        storyTitle: 'The Quantum Prism',
        originalTopic: 'Physics: Optics',
        learningLevel: 'Intermediate',
        visualStyle: 'Classic Comic',
        language: 'English',
        shortIntroduction: 'Discover how white light splits into a rainbow.',
        storySetting: 'A high-tech optics laboratory',
        characters: const [
          ComicCharacter(name: 'Newton', role: 'Physicist', visualDescription: 'blue coat'),
        ],
        panels: const [
          ComicPanelModel(
            panelNumber: 1,
            panelTitle: 'Prism Refraction',
            panelDescription: 'White beam enters triangular glass',
            narration: 'Different wavelengths bend at different angles.',
            dialogue: [ComicDialogue(speaker: 'Newton', text: 'Splitting wavelengths!')],
            keyVisualCue: 'Prism with brilliant rainbow spectrum',
          ),
          ComicPanelModel(
            panelNumber: 2,
            panelTitle: 'Color Spectrum',
            panelDescription: 'Rainbow colors fan out onto screen',
            narration: 'Red bends least; violet bends most.',
            dialogue: [ComicDialogue(speaker: 'Newton', text: 'ROYGBIV revealed!')],
            keyVisualCue: 'Projected spectrum on white wall',
          ),
        ],
        keyConcepts: const [
          ComicKeyConcept(term: 'Refraction', definition: 'Bending of light waves across mediums.'),
        ],
        analogies: const [],
        summary: 'Light refraction creates the visible spectrum.',
        quizQuestions: const [],
        createdAt: DateTime.now(),
      );

      mockTts = ComicTtsService(isMockMode: true);

      container = ProviderContainer(
        overrides: [
          comicTtsServiceProvider.overrideWithValue(mockTts),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes story state and panel count', () {
      final controller = container.read(comicReaderControllerProvider.notifier);
      controller.initialize(sampleStory);

      final state = container.read(comicReaderControllerProvider);
      expect(state.totalPanels, equals(2));
      expect(state.currentPanelIndex, equals(0));
      expect(state.isFirstPanel, isTrue);
      expect(state.isLastPanel, isFalse);
      expect(state.currentPanel?.panelTitle, equals('Prism Refraction'));
      expect(state.progressPercentage, equals(0.5));
    });

    test('toggles reading mode between horizontalPage and verticalScroll', () {
      final controller = container.read(comicReaderControllerProvider.notifier);

      expect(container.read(comicReaderControllerProvider).readingMode, ReadingMode.horizontalPage);

      controller.toggleReadingMode();
      expect(container.read(comicReaderControllerProvider).readingMode, ReadingMode.verticalScroll);

      controller.toggleReadingMode();
      expect(container.read(comicReaderControllerProvider).readingMode, ReadingMode.horizontalPage);
    });

    test('navigates forward and backward through panels with bounds clamping', () {
      final controller = container.read(comicReaderControllerProvider.notifier);
      controller.initialize(sampleStory);

      // Advance to panel 2
      controller.nextPanel();
      var state = container.read(comicReaderControllerProvider);
      expect(state.currentPanelIndex, equals(1));
      expect(state.isLastPanel, isTrue);
      expect(state.progressPercentage, equals(1.0));

      // Attempt to advance beyond end (should clamp)
      controller.nextPanel();
      expect(container.read(comicReaderControllerProvider).currentPanelIndex, equals(1));

      // Move back to panel 1
      controller.previousPanel();
      state = container.read(comicReaderControllerProvider);
      expect(state.currentPanelIndex, equals(0));
      expect(state.isFirstPanel, isTrue);

      // Attempt to move back before start (should clamp)
      controller.previousPanel();
      expect(container.read(comicReaderControllerProvider).currentPanelIndex, equals(0));
    });

    test('toggles audio narration on current panel', () async {
      final controller = container.read(comicReaderControllerProvider.notifier);
      controller.initialize(sampleStory);

      expect(container.read(comicReaderControllerProvider).isSpeaking, isFalse);

      await controller.toggleAudioNarration();
      expect(container.read(comicReaderControllerProvider).isSpeaking, isTrue);

      await controller.toggleAudioNarration();
      expect(container.read(comicReaderControllerProvider).isSpeaking, isFalse);
    });

    test('toggles hands-free auto-play narration', () async {
      final controller = container.read(comicReaderControllerProvider.notifier);
      controller.initialize(sampleStory);

      expect(container.read(comicReaderControllerProvider).isAutoPlaying, isFalse);

      await controller.toggleAutoPlayNarration();
      expect(container.read(comicReaderControllerProvider).isAutoPlaying, isTrue);
      expect(container.read(comicReaderControllerProvider).isSpeaking, isTrue);

      await controller.toggleAutoPlayNarration();
      expect(container.read(comicReaderControllerProvider).isAutoPlaying, isFalse);
      expect(container.read(comicReaderControllerProvider).isSpeaking, isFalse);
    });

    test('expands and closes modal panel view', () {
      final controller = container.read(comicReaderControllerProvider.notifier);
      controller.initialize(sampleStory);

      controller.expandPanel(sampleStory.panels.first);
      expect(container.read(comicReaderControllerProvider).expandedPanel, isNotNull);

      controller.closeExpandedPanel();
      expect(container.read(comicReaderControllerProvider).expandedPanel, isNull);
    });
  });
}
