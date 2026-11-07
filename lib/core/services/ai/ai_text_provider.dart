import 'ai_provider_types.dart';

/// Abstract contract for LLM Text & Story Generation Providers
abstract class AiTextProvider {
  /// Unique provider identification
  AiProviderType get providerType;

  /// Default model identifier used by this provider
  String get defaultModel;

  /// Checks if the provider has necessary credentials configured
  bool get isConfigured;

  /// Generates a structured educational comic story matching the JSON schema
  Future<AiTextResponse> generateStory({
    required String prompt,
    required StoryGenerationOptions options,
  });

  /// Explains a specific concept with analogies
  Future<AiTextResponse> generateAnalogy({
    required String concept,
    required LearningLevel level,
  });
}

