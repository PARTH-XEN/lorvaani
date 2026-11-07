import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/document/document_processing_types.dart';
import 'package:lorevaani/core/services/document/ocr_service.dart';

void main() {
  group('OcrService Tests', () {
    const ocrService = OcrService();

    test('normalizeOcrText rejoins hyphenated broken lines', () {
      const raw = 'Photo-\n  synthesis converts light into chem-\nical energy.';
      final cleaned = ocrService.normalizeOcrText(raw);
      expect(cleaned, 'Photosynthesis converts light into chemical energy.');
    });

    test('normalizeOcrText removes excessive line breaks and whitespace', () {
      const raw = 'Heading 1\n\n\n\nBody paragraph line 1   \n   line 2';
      final cleaned = ocrService.normalizeOcrText(raw);
      expect(cleaned, 'Heading 1\n\nBody paragraph line 1\nline 2');
    });

    test('extractSuggestedTitle extracts first clean header line', () {
      const notes = '''
# Chapter 5: Newton's Laws of Motion
An object in motion remains in motion.
F = m * a.
''';
      final title = ocrService.extractSuggestedTitle(notes);
      expect(title, "Chapter 5: Newton's Laws of Motion");
    });

    test('processExtractedText calculates word and character metrics', () {
      const raw = 'Mitochondria produce ATP cellular energy through the Krebs cycle.';
      final result = ocrService.processExtractedText(
        rawText: raw,
        sourceType: DocumentSourceType.cameraOcr,
        sourceName: 'page_12.jpg',
      );

      expect(result.sourceType, DocumentSourceType.cameraOcr);
      expect(result.sourceName, 'page_12.jpg');
      expect(result.characterCount, raw.length);
      expect(result.wordCount, 9);
      expect(result.suggestedTitle, isNotNull);
    });

    test('processExtractedText throws EmptyDocumentException on illegible or empty text', () {
      expect(
        () => ocrService.processExtractedText(
          rawText: '   .. ',
          sourceType: DocumentSourceType.cameraOcr,
          sourceName: 'blurry_image.jpg',
        ),
        throwsA(isA<EmptyDocumentException>()),
      );
    });

    test('simulateOcr processes mock textbook scan bytes successfully', () {
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = ocrService.simulateOcr(
        imageBytes: fakeBytes,
        fileName: 'textbook_ch4.jpg',
      );

      expect(result.cleanedText, contains('CELLULAR RESPIRATION'));
      expect(result.wordCount, greaterThan(20));
      expect(result.confidenceScore, 0.95);
    });

    test('simulateOcr throws EmptyDocumentException on empty byte array', () {
      expect(
        () => ocrService.simulateOcr(
          imageBytes: Uint8List(0),
          fileName: 'empty.jpg',
        ),
        throwsA(isA<EmptyDocumentException>()),
      );
    });
  });
}

