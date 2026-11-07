import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai/ai_config_service.dart';
import '../../../../core/services/ai/ai_provider_types.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/ai/mock/mock_image_provider.dart';
import '../../../../core/services/ai/mock/mock_text_provider.dart';
import '../../../../core/services/ai/orchestrator/ai_orchestrator.dart';
import '../../../../core/services/ai/providers/gemini_text_provider.dart';
import '../../../../core/services/ai/providers/groq_text_provider.dart';
import '../../../../core/services/ai/providers/pollinations_image_provider.dart';
import '../../../../core/utils/story_schema_validator.dart';
import '../../../../data/models/comic_story_model.dart';
import '../../data/story_generation_state.dart';
import '../../services/story_prompt_builder.dart';

final storyPromptBuilderProvider =
    Provider<StoryPromptBuilder>((ref) => const StoryPromptBuilder());

final storySchemaValidatorProvider =
    Provider<StorySchemaValidator>((ref) => const StorySchemaValidator());

/// Default configured AI Orchestrator with Gemini -> Groq -> Mock fallback
final aiOrchestratorProvider = Provider<AiOrchestrator>((ref) {
  final aiConfig = ref.watch(aiConfigServiceProvider);
  final geminiKey = aiConfig.getGeminiApiKey();
  final groqKey = aiConfig.getGroqApiKey();

  return AiOrchestrator(
    textProviders: [
      GroqTextProvider(apiKey: groqKey),
      GeminiTextProvider(apiKey: geminiKey),
      const MockTextProvider(),
    ],
    imageProviders: [
      PollinationsImageProvider(),
      const MockImageProvider(),
    ],
  );
});

final storyGenerationControllerProvider =
    NotifierProvider<StoryGenerationController, StoryGenerationState>(
  StoryGenerationController.new,
);

class StoryGenerationController extends Notifier<StoryGenerationState> {
  late AiOrchestrator _orchestrator;
  late StoryPromptBuilder _promptBuilder;
  late StorySchemaValidator _validator;

  @override
  StoryGenerationState build() {
    _orchestrator = ref.watch(aiOrchestratorProvider);
    _promptBuilder = ref.watch(storyPromptBuilderProvider);
    _validator = ref.watch(storySchemaValidatorProvider);
    return const StoryGenerationState();
  }

  // Dependency injection helper for testing
  void setDependencies({
    AiOrchestrator? orchestrator,
    StoryPromptBuilder? promptBuilder,
    StorySchemaValidator? validator,
  }) {
    if (orchestrator != null) _orchestrator = orchestrator;
    if (promptBuilder != null) _promptBuilder = promptBuilder;
    if (validator != null) _validator = validator;
  }

  void updateOptions(StoryGenerationOptions newOptions) {
    state = state.copyWith(options: newOptions);
  }

  void reset() {
    state = StoryGenerationState(options: state.options);
  }

  /// Generates a structured comic story with schema validation and controlled retries
  Future<bool> generateStory({
    required String topicTitle,
    required String notesText,
    bool forceOfflineMock = false,
  }) async {
    state = state.copyWith(
      status: StoryGenerationStatus.buildingPrompt,
      progressPercent: 0.15,
      progressMessage: 'Constructing comic prompt template...',
      clearError: true,
      retryCount: 0,
    );

    final prompt = _promptBuilder.buildPrompt(
      topicTitle: topicTitle,
      notesText: notesText,
      options: state.options,
    );

    const int maxValidationAttempts = 2;
    int attempt = 0;

    while (attempt < maxValidationAttempts) {
      attempt++;
      try {
        state = state.copyWith(
          status: StoryGenerationStatus.generatingWithLlm,
          progressPercent: 0.40 + (attempt * 0.1),
          progressMessage: attempt == 1
              ? 'Generating comic script with AI...'
              : 'Re-validating story structure (attempt $attempt)...',
        );

        AiTextResponse response;
        if (forceOfflineMock) {
          const mockProvider = MockTextProvider();
          response = await mockProvider.generateStory(
            prompt: prompt,
            options: state.options,
          );
        } else {
          response = await _orchestrator.generateStory(
            prompt: prompt,
            options: state.options,
          );
        }

        // Validate schema
        state = state.copyWith(
          status: StoryGenerationStatus.validatingSchema,
          progressPercent: 0.80,
          progressMessage: 'Validating story narrative & quiz structure...',
        );

        _validator.validate(response.json);

        // Parsing succeeded
        final comicStory = ComicStory.fromJson(
          response.json,
          id: 'story_${DateTime.now().millisecondsSinceEpoch}',
        );

        state = state.copyWith(
          status: StoryGenerationStatus.generatingWithLlm,
          progressPercent: 0.90,
          progressMessage: 'Illustrating comic panels with character continuity...',
        );

        // Attach distinct comic illustration URLs for each panel
        final pollinationsProvider = PollinationsImageProvider();
        final updatedPanels = <ComicPanelModel>[];

        for (final panel in comicStory.panels) {
          if (panel.imageUrl == null || panel.imageUrl!.isEmpty) {
            final imageResp = await pollinationsProvider.generatePanelIllustration(
              panelDescription: '${panel.panelTitle}: ${panel.panelDescription}',
              visualStyle: state.options.visualStyle,
              characterConsistencyPrompt: comicStory.characters
                  .map((c) => '${c.name} (${c.visualDescription})')
                  .join(', '),
              seed: (comicStory.id.hashCode.abs() + panel.panelNumber * 8191) %
                  10000000,
            );
            updatedPanels.add(panel.copyWith(imageUrl: imageResp.imageUrl));
          } else {
            updatedPanels.add(panel);
          }
        }

        final storyWithArt = comicStory.copyWith(panels: updatedPanels);

        state = state.copyWith(
          status: StoryGenerationStatus.success,
          progressPercent: 1.0,
          progressMessage: 'Comic script ready!',
          generatedStory: storyWithArt,
        );

        // Record generation in trial/account tracker
        await ref.read(authServiceProvider).recordStoryGenerated();

        return true;
      } on StorySchemaValidationException catch (e) {
        if (attempt >= maxValidationAttempts) {
          state = state.copyWith(
            status: StoryGenerationStatus.error,
            errorMessage:
                'Generated story failed schema validation: ${e.message}\nField: ${e.missingField}',
            retryCount: attempt,
          );
          return false;
        }
      } catch (e) {
        state = state.copyWith(
          status: StoryGenerationStatus.error,
          errorMessage: 'Story generation error: $e',
          retryCount: attempt,
        );
        return false;
      }
    }

    return false;
  }
}
