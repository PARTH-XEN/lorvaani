import '../ai_image_provider.dart';
import '../ai_provider_types.dart';

/// Pollinations.ai Image Generation Provider
class PollinationsImageProvider implements AiImageProvider {
  final String? apiKey;
  final String model;

  PollinationsImageProvider({
    this.apiKey,
    this.model = 'flux',
  });

  @override
  AiProviderType get providerType => AiProviderType.pollinations;

  @override
  bool get isConfigured => true; // Open access supported

  @override
  Future<AiImageResponse> generatePanelIllustration({
    required String panelDescription,
    required ComicVisualStyle visualStyle,
    required String characterConsistencyPrompt,
    int? seed,
    int width = 1024,
    int height = 1024,
  }) async {
    final resolvedSeed = seed ?? (panelDescription.hashCode.abs() % 10000000);

    // Build unified comic prompt combining scene, style modifier, and character continuity
    final fullPrompt = StringBuffer()
      ..write(panelDescription.trim())
      ..write(', ')
      ..write(visualStyle.promptStyleModifier);

    if (characterConsistencyPrompt.trim().isNotEmpty) {
      fullPrompt.write(', character appearance: ${characterConsistencyPrompt.trim()}');
    }

    fullPrompt.write(', high resolution graphic novel illustration, comic panel masterpiece');

    final encodedPrompt = Uri.encodeComponent(fullPrompt.toString());

    final queryParams = StringBuffer()
      ..write('width=$width')
      ..write('&height=$height')
      ..write('&seed=$resolvedSeed')
      ..write('&model=$model')
      ..write('&nologo=true');

    if (apiKey != null && apiKey!.trim().isNotEmpty) {
      queryParams.write('&key=${apiKey!.trim()}');
    }

    final imageUrl =
        'https://image.pollinations.ai/prompt/$encodedPrompt?$queryParams';

    return AiImageResponse(
      imageUrl: imageUrl,
      prompt: fullPrompt.toString(),
      visualStyle: visualStyle,
      seed: resolvedSeed,
      provider: providerType,
      isFallback: false,
    );
  }
}

