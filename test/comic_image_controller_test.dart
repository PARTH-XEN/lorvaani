import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/services/ai/mock/mock_image_provider.dart';
import 'package:lorevaani/core/services/ai/mock/mock_text_provider.dart';
import 'package:lorevaani/core/services/ai/orchestrator/ai_orchestrator.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/image_generation/data/panel_image_state.dart';
import 'package:lorevaani/features/image_generation/presentation/controllers/comic_image_controller.dart';
import 'package:lorevaani/features/image_generation/services/comic_image_cache_service.dart';
import 'package:lorevaani/features/image_generation/services/comic_image_prompt_service.dart';
import 'package:lorevaani/features/story_generation/presentation/controllers/story_generation_controller.dart';

void main() {
  group('ComicImageController Tests', () {
    late ProviderContainer container;
    late ComicStory sampleStory;

    setUp(() {
      sampleStory = ComicStory(
        id: 'story_cell_division',
        storyTitle: 'Cell Division in Action',
        originalTopic: 'Mitosis',
        learningLevel: 'Intermediate',
        visualStyle: 'Cinematic Comic',
        language: 'English',
        shortIntroduction: 'Learn how cells duplicate their genetic blueprint.',
        storySetting: 'Microscopic cellular nucleus',
        characters: const [
          ComicCharacter(
            name: 'Cyto',
            role: 'Cell Biologist Hero',
            visualDescription: 'microscopic explorer in glowing cyan armor',
          ),
        ],
        panels: const [
          ComicPanelModel(
            panelNumber: 1,
            panelTitle: 'Prophase',
            panelDescription: 'Chromosomes condense and become visible inside nucleus',
            narration: 'The nuclear envelope begins to break down.',
            dialogue: [ComicDialogue(speaker: 'Cyto', text: 'DNA is coiling tightly!')],
            keyVisualCue: 'X-shaped condensed chromosomes glowing under UV illumination',
          ),
          ComicPanelModel(
            panelNumber: 2,
            panelTitle: 'Metaphase',
            panelDescription: 'Chromosomes line up along the equator plate',
            narration: 'Spindle fibers attach to the centromeres.',
            dialogue: [ComicDialogue(speaker: 'Cyto', text: 'All lined up in the center!'),],
            keyVisualCue: 'Perfect alignment along the cell equator',
          ),
        ],
        keyConcepts: const [],
        analogies: const [],
        summary: 'Mitosis creates two identical daughter cells.',
        quizQuestions: const [],
        createdAt: DateTime.now(),
      );

      final orchestrator = AiOrchestrator(
        textProviders: [const MockTextProvider()],
        imageProviders: [const MockImageProvider(simulatedDelayMs: 0)],
      );

      container = ProviderContainer(
        overrides: [
          aiOrchestratorProvider.overrideWithValue(orchestrator),
          comicImagePromptServiceProvider.overrideWithValue(const ComicImagePromptService()),
          comicImageCacheServiceProvider.overrideWithValue(ComicImageCacheService()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes story panel states correctly', () {
      final controller = container.read(comicImageControllerProvider.notifier);
      controller.initializeStory(sampleStory);

      final state = container.read(comicImageControllerProvider);
      expect(state.storyId, equals('story_cell_division'));
      expect(state.totalCount, equals(2));
      expect(state.completedCount, equals(0));
      expect(state.panelStates.length, equals(2));
      expect(state.panelStates[1]!.status, equals(PanelImageStatus.idle));
      expect(state.panelStates[2]!.status, equals(PanelImageStatus.idle));
    });

    test('generates single panel image successfully with mock provider', () async {
      final controller = container.read(comicImageControllerProvider.notifier);
      controller.initializeStory(sampleStory);

      final url = await controller.generatePanelImage(
        story: sampleStory,
        panel: sampleStory.panels.first,
        forceOfflineMock: true,
      );

      expect(url, isNotNull);
      expect(url, contains('gen.pollinations.ai/image'));

      final state = container.read(comicImageControllerProvider);
      final panel1State = state.panelStates[1]!;
      expect(panel1State.status, equals(PanelImageStatus.fallback)); // Mock returns isFallback: true
      expect(panel1State.imageUrl, equals(url));
      expect(state.completedCount, equals(1));
    });

    test('retrieves from cache on subsequent calls without re-invoking generation', () async {
      final controller = container.read(comicImageControllerProvider.notifier);
      controller.initializeStory(sampleStory);

      final url1 = await controller.generatePanelImage(
        story: sampleStory,
        panel: sampleStory.panels.first,
        forceOfflineMock: true,
      );

      final url2 = await controller.generatePanelImage(
        story: sampleStory,
        panel: sampleStory.panels.first,
        forceOfflineMock: true,
      );

      expect(url1, equals(url2));
    });

    test('handles failure gracefully without crashing and marks panel as failed', () async {
      // Re-initialize with failing mock image provider
      final failingOrchestrator = AiOrchestrator(
        textProviders: [const MockTextProvider()],
        imageProviders: [
          const MockImageProvider(
            shouldSimulateFailure: true,
            simulatedDelayMs: 0,
          ),
        ],
      );

      final failingContainer = ProviderContainer(
        overrides: [
          aiOrchestratorProvider.overrideWithValue(failingOrchestrator),
        ],
      );

      final controller = failingContainer.read(comicImageControllerProvider.notifier);
      controller.initializeStory(sampleStory);

      final url = await controller.generatePanelImage(
        story: sampleStory,
        panel: sampleStory.panels.first,
      );

      expect(url, isNull);

      final state = failingContainer.read(comicImageControllerProvider);
      final panel1State = state.panelStates[1]!;
      expect(panel1State.status, equals(PanelImageStatus.failed));
      expect(panel1State.errorMessage, contains('simulated generation failure'));
      expect(state.hasAnyErrors, isTrue);

      failingContainer.dispose();
    });

    test('generates all panels across entire story and updates panel imageUrls', () async {
      final controller = container.read(comicImageControllerProvider.notifier);
      controller.initializeStory(sampleStory);

      final updatedStory = await controller.generateAllPanels(
        story: sampleStory,
        forceOfflineMock: true,
      );

      expect(updatedStory.panels.length, equals(2));
      expect(updatedStory.panels[0].imageUrl, isNotNull);
      expect(updatedStory.panels[1].imageUrl, isNotNull);

      final state = container.read(comicImageControllerProvider);
      expect(state.isAllFinished, isTrue);
      expect(state.completedCount, equals(2));
      expect(state.progressRatio, equals(1.0));
    });
  });
}
