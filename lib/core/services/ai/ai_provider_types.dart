/// Supported AI Providers in the Lorvani Ecosystem
enum AiProviderType {
  gemini,
  groq,
  cloudflare,
  huggingFace,
  pollinations,
  mock,
}

/// Learning difficulty levels
enum LearningLevel {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case LearningLevel.beginner:
        return 'Beginner';
      case LearningLevel.intermediate:
        return 'Intermediate';
      case LearningLevel.advanced:
        return 'Advanced';
    }
  }
}

/// Visual comic art styles
enum ComicVisualStyle {
  classicComic,
  animeInspired,
  cartoon,
  storybook,
  cinematicComic;

  String get label {
    switch (this) {
      case ComicVisualStyle.classicComic:
        return 'Classic Comic';
      case ComicVisualStyle.animeInspired:
        return 'Anime-inspired';
      case ComicVisualStyle.cartoon:
        return 'Cartoon';
      case ComicVisualStyle.storybook:
        return 'Storybook';
      case ComicVisualStyle.cinematicComic:
        return 'Cinematic Comic';
    }
  }

  String get promptStyleModifier {
    switch (this) {
      case ComicVisualStyle.classicComic:
        return 'classic 90s superhero comic book art style, bold ink contours, vibrant half-tone print texture';
      case ComicVisualStyle.animeInspired:
        return 'modern vibrant anime manga illustration style, dynamic expressive shading, cinematic lighting';
      case ComicVisualStyle.cartoon:
        return 'playful modern western cartoon art, clean rounded shapes, bright friendly saturated palette';
      case ComicVisualStyle.storybook:
        return 'whimsical storybook illustration, soft painterly textures, warm atmospheric lighting';
      case ComicVisualStyle.cinematicComic:
        return 'dark graphic novel cinematic comic panel, dramatic chiaroscuro lighting, highly detailed';
    }
  }
}

/// Story length preference
enum StoryLength {
  short,
  medium,
  detailed;

  int get defaultPanelCount {
    switch (this) {
      case StoryLength.short:
        return 4;
      case StoryLength.medium:
        return 6;
      case StoryLength.detailed:
        return 8;
    }
  }
}

/// Request configuration parameters for AI Story Generation
class StoryGenerationOptions {
  final LearningLevel learningLevel;
  final ComicVisualStyle visualStyle;
  final StoryLength storyLength;
  final int panelCount;
  final String language;

  const StoryGenerationOptions({
    this.learningLevel = LearningLevel.intermediate,
    this.visualStyle = ComicVisualStyle.cinematicComic,
    this.storyLength = StoryLength.medium,
    this.panelCount = 6,
    this.language = 'English',
  });
}

/// Standardized response wrapper for text/story generation
class AiTextResponse {
  final String rawText;
  final Map<String, dynamic> json;
  final AiProviderType provider;
  final String modelName;
  final int latencyMs;
  final bool isFromCache;

  const AiTextResponse({
    required this.rawText,
    required this.json,
    required this.provider,
    required this.modelName,
    required this.latencyMs,
    this.isFromCache = false,
  });
}

/// Standardized response wrapper for comic panel illustration generation
class AiImageResponse {
  final String imageUrl;
  final String prompt;
  final ComicVisualStyle visualStyle;
  final int seed;
  final AiProviderType provider;
  final bool isFallback;

  const AiImageResponse({
    required this.imageUrl,
    required this.prompt,
    required this.visualStyle,
    required this.seed,
    required this.provider,
    this.isFallback = false,
  });
}

/// Base Exception for AI Provider failures
class AiProviderException implements Exception {
  final String message;
  final AiProviderType provider;
  final int? statusCode;
  final dynamic originalError;

  const AiProviderException({
    required this.message,
    required this.provider,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'AiProviderException [$provider] (status: $statusCode): $message';
}

/// Specific exception thrown when rate limits (HTTP 429) are encountered
class AiRateLimitException extends AiProviderException {
  final Duration? retryAfter;

  const AiRateLimitException({
    required super.message,
    required super.provider,
    super.statusCode = 429,
    this.retryAfter,
    super.originalError,
  });
}

/// Specific exception thrown when quota is exhausted
class AiQuotaExceededException extends AiProviderException {
  const AiQuotaExceededException({
    required super.message,
    required super.provider,
    super.statusCode = 403,
    super.originalError,
  });
}

/// Specific exception thrown when provider response cannot be parsed into JSON
class AiMalformedResponseException extends AiProviderException {
  final String rawResponse;

  const AiMalformedResponseException({
    required super.message,
    required super.provider,
    required this.rawResponse,
    super.statusCode,
    super.originalError,
  });
}

/// Specific exception for network timeouts and connection errors
class AiNetworkException extends AiProviderException {
  const AiNetworkException({
    required super.message,
    required super.provider,
    super.originalError,
  });
}

/// Specific exception for missing or invalid API keys
class AiAuthException extends AiProviderException {
  const AiAuthException({
    required super.message,
    required super.provider,
    super.statusCode = 401,
    super.originalError,
  });
}

