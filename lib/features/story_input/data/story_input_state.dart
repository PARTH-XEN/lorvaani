import '../../../core/services/document/document_processing_types.dart';

enum ContentHealthTier {
  empty,
  tooShort,
  goodForShortComic,
  idealForStandardComic,
  richAndDetailed,
}

/// Educational sample notes for 1-tap testing
class SampleNoteTemplate {
  final String title;
  final String subject;
  final String content;

  const SampleNoteTemplate({
    required this.title,
    required this.subject,
    required this.content,
  });
}

/// State representation for the Learning Material Input Screen
class StoryInputState {
  final String topicTitle;
  final String notesText;
  final DocumentSourceType activeInputMethod;
  final bool isExtracting;
  final String? extractionError;
  final ExtractedDocumentResult? lastExtractedResult;
  final String? validationError;

  const StoryInputState({
    this.topicTitle = '',
    this.notesText = '',
    this.activeInputMethod = DocumentSourceType.manual,
    this.isExtracting = false,
    this.extractionError,
    this.lastExtractedResult,
    this.validationError,
  });

  int get characterCount => notesText.length;

  int get wordCount {
    if (notesText.trim().isEmpty) return 0;
    return notesText
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
  }

  ContentHealthTier get contentHealth {
    final words = wordCount;
    if (words == 0) return ContentHealthTier.empty;
    if (words < 15) return ContentHealthTier.tooShort;
    if (words < 60) return ContentHealthTier.goodForShortComic;
    if (words <= 350) return ContentHealthTier.idealForStandardComic;
    return ContentHealthTier.richAndDetailed;
  }

  String get contentHealthLabel {
    switch (contentHealth) {
      case ContentHealthTier.empty:
        return 'No content yet';
      case ContentHealthTier.tooShort:
        return 'Needs more detail (min 15 words recommended)';
      case ContentHealthTier.goodForShortComic:
        return 'Good for a quick 4-panel comic story';
      case ContentHealthTier.idealForStandardComic:
        return 'Ideal length for 6-panel illustrated comic';
      case ContentHealthTier.richAndDetailed:
        return 'Rich notes: AI will distill into an 8-panel epic';
    }
  }

  bool get isValidForGeneration {
    return topicTitle.trim().isNotEmpty && notesText.trim().length >= 25;
  }

  StoryInputState copyWith({
    String? topicTitle,
    String? notesText,
    DocumentSourceType? activeInputMethod,
    bool? isExtracting,
    String? extractionError,
    ExtractedDocumentResult? lastExtractedResult,
    String? validationError,
    bool clearExtractionError = false,
    bool clearExtractedResult = false,
    bool clearValidationError = false,
  }) {
    return StoryInputState(
      topicTitle: topicTitle ?? this.topicTitle,
      notesText: notesText ?? this.notesText,
      activeInputMethod: activeInputMethod ?? this.activeInputMethod,
      isExtracting: isExtracting ?? this.isExtracting,
      extractionError: clearExtractionError
          ? null
          : (extractionError ?? this.extractionError),
      lastExtractedResult: clearExtractedResult
          ? null
          : (lastExtractedResult ?? this.lastExtractedResult),
      validationError: clearValidationError
          ? null
          : (validationError ?? this.validationError),
    );
  }

  static const List<SampleNoteTemplate> sampleTemplates = [
    SampleNoteTemplate(
      title: 'Photosynthesis & Chloroplasts',
      subject: 'Biology',
      content:
          'Photosynthesis is the fundamental biological process by which green plants and certain organisms convert sunlight photons into chemical energy. Chloroplasts contain chlorophyll pigments that absorb blue and red light while reflecting green light. The light-dependent reactions take place inside thylakoid membranes, generating ATP and NADPH. The Calvin Cycle (light-independent) fixes atmospheric carbon dioxide into glucose (sugar) for cellular food. Overall chemical equation: 6CO2 + 6H2O + Light -> C6H12O6 + 6O2.',
    ),
    SampleNoteTemplate(
      title: 'Newton\'s Three Laws of Motion',
      subject: 'Physics',
      content:
          'Sir Isaac Newton formulated three fundamental laws of classical mechanics: 1. Law of Inertia: An object at rest remains at rest, and an object in uniform motion stays in motion unless acted upon by an unbalanced external force. 2. Law of Acceleration: Force equals mass times acceleration (F = m*a). The acceleration of an object is directly proportional to the net force and inversely proportional to its mass. 3. Action and Reaction: For every action, there is an equal and opposite reaction force.',
    ),
    SampleNoteTemplate(
      title: 'The Industrial Revolution',
      subject: 'History',
      content:
          'Originating in Great Britain during the late 18th century, the Industrial Revolution marked a profound shift from agrarian handicraft economies to machine-driven manufacturing. Inventions like James Watt\'s steam engine, the spinning jenny, and smelting iron with coke revolutionized production. Cities expanded rapidly, leading to the rise of factory systems, modern transportation (steam locomotives and steamships), and significant social, economic, and political transformations across the world.',
    ),
  ];
}

