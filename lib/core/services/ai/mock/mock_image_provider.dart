import '../ai_image_provider.dart';
import '../ai_provider_types.dart';

/// Offline & Development Mock Image Provider
class MockImageProvider implements AiImageProvider {
  final bool shouldSimulateFailure;
  final int simulatedDelayMs;

  const MockImageProvider({
    this.shouldSimulateFailure = false,
    this.simulatedDelayMs = 200,
  });

  @override
  AiProviderType get providerType => AiProviderType.mock;

  @override
  bool get isConfigured => true;

  @override
  Future<AiImageResponse> generatePanelIllustration({
    required String panelDescription,
    required ComicVisualStyle visualStyle,
    required String characterConsistencyPrompt,
    int? seed,
    int width = 1024,
    int height = 1024,
  }) async {
    if (simulatedDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: simulatedDelayMs));
    }

    if (shouldSimulateFailure) {
      throw const AiProviderException(
        message: 'Mock image provider simulated generation failure',
        provider: AiProviderType.mock,
        statusCode: 500,
      );
    }

    final resolvedSeed = seed ?? (panelDescription.hashCode.abs() % 1000000);
    final encodedPrompt = Uri.encodeComponent(
      '$panelDescription, ${visualStyle.promptStyleModifier}',
    );

    // High reliability mock image url
    final fallbackUrl =
        'https://gen.pollinations.ai/image/$encodedPrompt?width=$width&height=$height&seed=$resolvedSeed&nologo=true';

    return AiImageResponse(
      imageUrl: fallbackUrl,
      prompt: panelDescription,
      visualStyle: visualStyle,
      seed: resolvedSeed,
      provider: providerType,
      isFallback: true,
    );
  }
}

