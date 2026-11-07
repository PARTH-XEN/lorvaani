/// Input method and document origin classification
enum DocumentSourceType {
  manual,
  clipboard,
  cameraOcr,
  galleryOcr,
  pdf,
  sampleTemplate;

  String get label {
    switch (this) {
      case DocumentSourceType.manual:
        return 'Typed Notes';
      case DocumentSourceType.clipboard:
        return 'Pasted Notes';
      case DocumentSourceType.cameraOcr:
        return 'Camera Scan';
      case DocumentSourceType.galleryOcr:
        return 'Image Import';
      case DocumentSourceType.pdf:
        return 'PDF Document';
      case DocumentSourceType.sampleTemplate:
        return 'Sample Template';
    }
  }
}

/// Standardized result of an OCR or PDF extraction process
class ExtractedDocumentResult {
  final String rawText;
  final String cleanedText;
  final DocumentSourceType sourceType;
  final String sourceName;
  final int pageCount;
  final int characterCount;
  final int wordCount;
  final bool isScannedOnly;
  final double confidenceScore;
  final String? suggestedTitle;

  const ExtractedDocumentResult({
    required this.rawText,
    required this.cleanedText,
    required this.sourceType,
    required this.sourceName,
    this.pageCount = 1,
    required this.characterCount,
    required this.wordCount,
    this.isScannedOnly = false,
    this.confidenceScore = 1.0,
    this.suggestedTitle,
  });

  bool get isEmpty => cleanedText.trim().isEmpty;
}

/// Base exception for document processing failures
class DocumentExtractionException implements Exception {
  final String message;
  final DocumentSourceType sourceType;
  final dynamic originalError;

  const DocumentExtractionException({
    required this.message,
    required this.sourceType,
    this.originalError,
  });

  @override
  String toString() => 'DocumentExtractionException [$sourceType]: $message';
}

/// Exception when extracted document contains no usable text
class EmptyDocumentException extends DocumentExtractionException {
  const EmptyDocumentException({
    required super.message,
    required super.sourceType,
    super.originalError,
  });
}

/// Exception when a PDF is detected as image-only scans without text layer
class ScannedPdfWithoutTextException extends DocumentExtractionException {
  final int detectedPages;

  const ScannedPdfWithoutTextException({
    required super.message,
    required this.detectedPages,
    super.sourceType = DocumentSourceType.pdf,
    super.originalError,
  });
}

/// Exception for invalid, corrupt, or password-protected files
class CorruptedFileException extends DocumentExtractionException {
  const CorruptedFileException({
    required super.message,
    required super.sourceType,
    super.originalError,
  });
}

