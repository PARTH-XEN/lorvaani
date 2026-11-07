import '../../../core/services/ai/ai_provider_types.dart';
import '../../../data/models/comic_story_model.dart';

enum StoryGenerationStatus {
  idle,
  buildingPrompt,
  generatingWithLlm,
  validatingSchema,
  success,
  error,
}

/// Immutable state tracking the AI Story Generation lifecycle
class StoryGenerationState {
  final StoryGenerationStatus status;
  final double progressPercent;
  final String progressMessage;
  final ComicStory? generatedStory;
  final String? errorMessage;
  final StoryGenerationOptions options;
  final int retryCount;

  const StoryGenerationState({
    this.status = StoryGenerationStatus.idle,
    this.progressPercent = 0.0,
    this.progressMessage = 'Ready to generate',
    this.generatedStory,
    this.errorMessage,
    this.options = const StoryGenerationOptions(),
    this.retryCount = 0,
  });

  bool get isLoading =>
      status == StoryGenerationStatus.buildingPrompt ||
      status == StoryGenerationStatus.generatingWithLlm ||
      status == StoryGenerationStatus.validatingSchema;

  bool get isSuccess => status == StoryGenerationStatus.success && generatedStory != null;
  bool get hasError => status == StoryGenerationStatus.error;

  StoryGenerationState copyWith({
    StoryGenerationStatus? status,
    double? progressPercent,
    String? progressMessage,
    ComicStory? generatedStory,
    String? errorMessage,
    StoryGenerationOptions? options,
    int? retryCount,
    bool clearError = false,
  }) {
    return StoryGenerationState(
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      progressMessage: progressMessage ?? this.progressMessage,
      generatedStory: generatedStory ?? this.generatedStory,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      options: options ?? this.options,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

