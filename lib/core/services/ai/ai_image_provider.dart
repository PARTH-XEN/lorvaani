import 'ai_provider_types.dart';

/// Abstract contract for AI Comic Image Generation Providers
abstract class AiImageProvider {
  /// Unique provider identification
  AiProviderType get providerType;

  /// Checks if the provider is ready to generate images
  bool get isConfigured;

  /// Generates an illustrated comic panel from a detailed scene prompt
  Future<AiImageResponse> generatePanelIllustration({
    required String panelDescription,
    required ComicVisualStyle visualStyle,
    required String characterConsistencyPrompt,
    int? seed,
    int width = 1024,
    int height = 1024,
  });
}

