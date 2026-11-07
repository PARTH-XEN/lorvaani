import 'dart:async';
import 'dart:math';
import '../ai_image_provider.dart';
import '../ai_provider_types.dart';
import '../ai_text_provider.dart';
import '../mock/mock_image_provider.dart';
import '../mock/mock_text_provider.dart';

class _CachedItem<T> {
  final T data;
  final DateTime expiresAt;

  _CachedItem({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Central Orchestrator managing AI Provider Selection, Controlled Fallback Chains,
/// Rate-Limit Failovers, Exponential Backoff Retries, and In-Memory Caching.
class AiOrchestrator {
  final List<AiTextProvider> textProviders;
  final List<AiImageProvider> imageProviders;
  final int maxRetriesPerProvider;
  final Duration baseBackoff;
  final Duration cacheTtl;

  final Map<String, _CachedItem<AiTextResponse>> _textCache = {};
  final List<String> _executionLogs = [];

  AiOrchestrator({
    List<AiTextProvider>? textProviders,
    List<AiImageProvider>? imageProviders,
    this.maxRetriesPerProvider = 2,
    this.baseBackoff = const Duration(milliseconds: 300),
    this.cacheTtl = const Duration(minutes: 60),
  })  : textProviders = textProviders ?? [const MockTextProvider()],
        imageProviders = imageProviders ?? [const MockImageProvider()];

  List<String> get executionLogs => List.unmodifiable(_executionLogs);

  void clearCache() {
    _textCache.clear();
  }

  void _log(String message) {
    _executionLogs.add('[${DateTime.now().toIso8601String()}] $message');
  }

  /// Generates a structured comic story using the prioritized fallback chain
  Future<AiTextResponse> generateStory({
    required String prompt,
    required StoryGenerationOptions options,
    bool bypassCache = false,
  }) async {
    final cacheKey =
        'story:${prompt.trim()}:${options.learningLevel.name}:${options.visualStyle.name}:${options.panelCount}';

    // 1. Check in-memory cache
    if (!bypassCache && _textCache.containsKey(cacheKey)) {
      final cached = _textCache[cacheKey]!;
      if (!cached.isExpired) {
        _log('Cache HIT for prompt: "${prompt.trim()}"');
        final item = cached.data;
        return AiTextResponse(
          rawText: item.rawText,
          json: item.json,
          provider: item.provider,
          modelName: item.modelName,
          latencyMs: 0,
          isFromCache: true,
        );
      } else {
        _textCache.remove(cacheKey);
      }
    }

    _log(
      'Beginning story generation fallback chain across ${textProviders.length} providers.',
    );

    List<String> failureReasons = [];

    // 2. Iterate through prioritized providers
    for (int i = 0; i < textProviders.length; i++) {
      final provider = textProviders[i];

      if (!provider.isConfigured) {
        _log('Provider [${provider.providerType}] is not configured. Skipping.');
        continue;
      }

      _log('Attempting provider [${provider.providerType}] (priority $i)...');

      // Attempt with controlled retry
      try {
        final response = await _executeWithRetry(
          provider: provider,
          operation: () => provider.generateStory(
            prompt: prompt,
            options: options,
          ),
        );

        _log(
          'SUCCESS via [${provider.providerType}] in ${response.latencyMs}ms.',
        );

        // Store in cache
        _textCache[cacheKey] = _CachedItem(
          data: response,
          expiresAt: DateTime.now().add(cacheTtl),
        );

        return response;
      } catch (e) {
        final reason =
            'Provider [${provider.providerType}] failed: ${e.toString()}';
        _log(reason);
        failureReasons.add(reason);

        // If not the last provider, continue immediately to fallback
        if (i < textProviders.length - 1) {
          _log(
            'Failing over to next provider: [${textProviders[i + 1].providerType}].',
          );
        }
      }
    }

    // 3. If all configured providers in chain failed, raise comprehensive error
    throw AiProviderException(
      message:
          'All providers in the fallback chain failed.\nDetails:\n${failureReasons.join('\n')}',
      provider: AiProviderType.mock,
    );
  }

  /// Generates a panel illustration using the prioritized image fallback chain
  Future<AiImageResponse> generatePanelIllustration({
    required String panelDescription,
    required ComicVisualStyle visualStyle,
    required String characterConsistencyPrompt,
    int? seed,
    int width = 1024,
    int height = 1024,
  }) async {
    for (int i = 0; i < imageProviders.length; i++) {
      final provider = imageProviders[i];

      if (!provider.isConfigured) continue;

      try {
        _log('Attempting image provider [${provider.providerType}]...');
        final response = await provider.generatePanelIllustration(
          panelDescription: panelDescription,
          visualStyle: visualStyle,
          characterConsistencyPrompt: characterConsistencyPrompt,
          seed: seed,
          width: width,
          height: height,
        );
        _log('Image generation SUCCESS via [${provider.providerType}].');
        return response;
      } catch (e) {
        _log('Image provider [${provider.providerType}] failed: $e');
        if (i == imageProviders.length - 1) {
          rethrow;
        }
      }
    }

    throw const AiProviderException(
      message: 'All image providers in fallback chain failed.',
      provider: AiProviderType.mock,
    );
  }

  /// Executes an operation with exponential backoff for transient errors.
  /// Immediate failover without retrying occurs on RateLimit (429) or Auth errors.
  Future<AiTextResponse> _executeWithRetry({
    required AiTextProvider provider,
    required Future<AiTextResponse> Function() operation,
  }) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await operation();
      } catch (e) {
        // Immediate failover rules:
        // 1. RateLimit (429) -> don't spam a rate-limited endpoint, fail over immediately
        // 2. Auth error (401/403) -> key is invalid, retrying won't help
        if (e is AiRateLimitException || e is AiAuthException) {
          _log('Immediate failover triggered: $e');
          rethrow;
        }

        // For other transient network errors, retry up to maxRetries
        if (attempt > maxRetriesPerProvider) {
          rethrow;
        }

        final backoffMs =
            baseBackoff.inMilliseconds * pow(2, attempt - 1).toInt();
        _log(
          'Attempt $attempt failed for [${provider.providerType}]. Retrying in ${backoffMs}ms...',
        );
        await Future.delayed(Duration(milliseconds: backoffMs));
      }
    }
  }
}

