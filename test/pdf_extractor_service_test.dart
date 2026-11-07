import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:lorevaani/core/services/document/document_processing_types.dart';
import 'package:lorevaani/core/services/document/pdf_extractor_service.dart';

void main() {
  group('PdfExtractorService Tests', () {
    const pdfService = PdfExtractorService();

    test('extractTextFromPdfBytes extracts text from valid PDF bytes', () async {
      // Create a valid PDF in memory
      final document = PdfDocument();
      final page = document.pages.add();
      page.graphics.drawString(
        'Quantum Mechanics: Wave-particle duality of light.\nPhotons exhibit properties of both waves and discrete packets.',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(0, 0, 400, 100),
      );
      final List<int> bytes = document.saveSync();
      document.dispose();

      final result = await pdfService.extractTextFromPdfBytes(
        pdfBytes: Uint8List.fromList(bytes),
        fileName: 'quantum_physics.pdf',
      );

      expect(result.sourceName, 'quantum_physics.pdf');
      expect(result.pageCount, 1);
      expect(result.cleanedText, contains('Quantum Mechanics'));
      expect(result.cleanedText, contains('Wave-particle duality'));
      expect(result.wordCount, greaterThan(10));
      expect(result.suggestedTitle, contains('Quantum Mechanics'));
    });

    test('extractTextFromPdfBytes throws ScannedPdfWithoutTextException for image-only/blank PDF', () async {
      // Create a PDF with a page but no text
      final document = PdfDocument();
      document.pages.add(); // Blank page
      final List<int> bytes = document.saveSync();
      document.dispose();

      expect(
        () => pdfService.extractTextFromPdfBytes(
          pdfBytes: Uint8List.fromList(bytes),
          fileName: 'scanned_scan_only.pdf',
        ),
        throwsA(isA<ScannedPdfWithoutTextException>()),
      );
    });

    test('extractTextFromPdfBytes throws EmptyDocumentException on zero-byte PDF', () async {
      expect(
        () => pdfService.extractTextFromPdfBytes(
          pdfBytes: Uint8List(0),
          fileName: 'zero_byte.pdf',
        ),
        throwsA(isA<EmptyDocumentException>()),
      );
    });

    test('extractTextFromPdfBytes throws CorruptedFileException on invalid bytes', () async {
      final corruptBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      expect(
        () => pdfService.extractTextFromPdfBytes(
          pdfBytes: corruptBytes,
          fileName: 'corrupt.pdf',
        ),
        throwsA(isA<CorruptedFileException>()),
      );
    });
  });
}
