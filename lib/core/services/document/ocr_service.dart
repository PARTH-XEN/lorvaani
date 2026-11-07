import 'dart:typed_data';
import 'document_processing_types.dart';

/// Optical Character Recognition Service for scanning textbooks & study notes
class OcrService {
  const OcrService();

  /// Cleans, normalizes, and reconstructs paragraphs from raw OCR lines
  String normalizeOcrText(String raw) {
    if (raw.isEmpty) return '';

    // 1. Re-join hyphenated line breaks (e.g. "mito- \n chondria" -> "mitochondria")
    String text = raw.replaceAllMapped(
      RegExp(r'(\w+)-\s*\n\s*(\w+)'),
      (match) => '${match[1]}${match[2]}',
    );

    // 2. Normalize carriage returns
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // 3. Compress 3+ consecutive newlines into 2
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // 4. Remove excessive horizontal whitespace
    final lines = text.split('\n').map((line) => line.trim());
    return lines.join('\n').trim();
  }

  /// Extracts title candidate from the first prominent line of text
  String? extractSuggestedTitle(String text) {
    if (text.trim().isEmpty) return null;
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && l.length > 3)
        .toList();

    if (lines.isEmpty) return null;

    final firstLine = lines.first;
    // If first line is reasonably short (< 60 chars), use it as title
    if (firstLine.length <= 60) {
      return firstLine.replaceAll(RegExp(r'^[#*\-•\d.]+\s*'), '');
    }

    // Otherwise grab first 5-8 words
    final words = firstLine.split(' ');
    if (words.length > 6) {
      return '${words.take(6).join(' ')}...';
    }
    return firstLine;
  }

  /// Processes text recognized from an image
  ExtractedDocumentResult processExtractedText({
    required String rawText,
    required DocumentSourceType sourceType,
    required String sourceName,
    double confidence = 0.92,
  }) {
    final cleaned = normalizeOcrText(rawText);

    if (cleaned.length < 5) {
      throw EmptyDocumentException(
        message:
            'No legible text recognized in $sourceName. Please ensure the textbook page is well-lit, in focus, and not tilted.',
        sourceType: sourceType,
      );
    }

    final words = cleaned
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;

    return ExtractedDocumentResult(
      rawText: rawText,
      cleanedText: cleaned,
      sourceType: sourceType,
      sourceName: sourceName,
      pageCount: 1,
      characterCount: cleaned.length,
      wordCount: words,
      confidenceScore: confidence,
      suggestedTitle: extractSuggestedTitle(cleaned),
    );
  }

  /// Simulates OCR extraction for testing or platform demonstration
  ExtractedDocumentResult simulateOcr({
    required Uint8List imageBytes,
    required String fileName,
    DocumentSourceType sourceType = DocumentSourceType.cameraOcr,
  }) {
    if (imageBytes.isEmpty) {
      throw EmptyDocumentException(
        message: 'Supplied image contains 0 bytes.',
        sourceType: sourceType,
      );
    }

    // Deterministic simulation based on filename/bytes
    const sampleText = '''
CHAPTER 4: CELLULAR RESPIRATION & ENERGY TRANSFER
All living organisms require a continuous supply of free energy to carry out biological functions.
In eukaryotic cells, the mitochondria acts as the primary organelle responsible for ATP synthesis.
Through glycolysis, the Krebs cycle, and oxidative phosphorylation, glucose molecules are broken down.
Key Chemical Equation:
C6H12O6 + 6 O2 -> 6 CO2 + 6 H2O + ATP (Energy)
Energy is stored in high-energy phosphate bonds, ready for cellular transport.
''';

    return processExtractedText(
      rawText: sampleText,
      sourceType: sourceType,
      sourceName: fileName,
      confidence: 0.95,
    );
  }
}

