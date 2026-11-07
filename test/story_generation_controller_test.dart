import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/services/ai/ai_provider_types.dart';
import 'package:lorevaani/core/services/ai/mock/mock_text_provider.dart';
import 'package:lorevaani/core/services/ai/orchestrator/ai_orchestrator.dart';
import 'package:lorevaani/features/story_generation/data/story_generation_state.dart';
import 'package:lorevaani/features/story_generation/presentation/controllers/story_generation_controller.dart';

void main() {
  group('StoryGenerationController Lifecycle Tests', () {
    test('generateStory executes full pipeline to success state', () async {
      final container = ProviderContainer(
        overrides: [
          aiOrchestratorProvider.overrideWithValue(
            AiOrchestrator(
              textProviders: [
                const MockTextProvider(simulatedDelayMs: 5),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(storyGenerationControllerProvider.notifier);

      final success = await controller.generateStory(
        topicTitle: 'Thermodynamics',
        notesText: 'Heat flows spontaneously from hotter to colder bodies.',
      );

      expect(success, isTrue);

      final state = container.read(storyGenerationControllerProvider);
      expect(state.status, StoryGenerationStatus.success);
      expect(state.progressPercent, 1.0);
      expect(state.generatedStory, isNotNull);
      expect(state.generatedStory!.storyTitle, contains('Thermodynamics'));
      expect(state.generatedStory!.panels.isNotEmpty, isTrue);
      expect(state.generatedStory!.quizQuestions.isNotEmpty, isTrue);
    });

    test('forceOfflineMock bypasses network orchestrator directly', () async {
      final container = ProviderContainer(
        overrides: [
          aiOrchestratorProvider.overrideWithValue(
            AiOrchestrator(
              textProviders: [
                const MockTextProvider(
                  shouldSimulateFailure: true,
                  simulatedDelayMs: 5,
                ),
              ],
              maxRetriesPerProvider: 0,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(storyGenerationControllerProvider.notifier);

      // Generating with forceOfflineMock = true should succeed even if orchestrator fails
      final success = await controller.generateStory(
        topicTitle: 'Plate Tectonics',
        notesText: 'Earth lithosphere is divided into multiple moving plates.',
        forceOfflineMock: true,
      );

      expect(success, isTrue);
      final state = container.read(storyGenerationControllerProvider);
      expect(state.status, StoryGenerationStatus.success);
      expect(state.generatedStory!.storyTitle, contains('Plate Tectonics'));
    });

    test('updateOptions updates generation options in state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller =
          container.read(storyGenerationControllerProvider.notifier);

      const newOptions = StoryGenerationOptions(
        learningLevel: LearningLevel.advanced,
        visualStyle: ComicVisualStyle.animeInspired,
        panelCount: 8,
        language: 'Spanish',
      );

      controller.updateOptions(newOptions);

      final state = container.read(storyGenerationControllerProvider);
      expect(state.options.learningLevel, LearningLevel.advanced);
      expect(state.options.visualStyle, ComicVisualStyle.animeInspired);
      expect(state.options.panelCount, 8);
      expect(state.options.language, 'Spanish');
    });
  });
}

