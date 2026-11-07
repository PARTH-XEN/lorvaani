import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'document_processing_types.dart';
import 'ocr_service.dart';

/// Cross-platform PDF text extraction service using Syncfusion Flutter PDF
class PdfExtractorService {
  final OcrService _ocrService;

  const PdfExtractorService({OcrService? ocrService})
      : _ocrService = ocrService ?? const OcrService();

  /// Extracts text content from raw PDF document bytes
  Future<ExtractedDocumentResult> extractTextFromPdfBytes({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    if (pdfBytes.isEmpty) {
      throw const EmptyDocumentException(
        message: 'The selected PDF file is completely empty (0 bytes).',
        sourceType: DocumentSourceType.pdf,
      );
    }

    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: pdfBytes);
      final int pageCount = document.pages.count;

      if (pageCount == 0) {
        throw const EmptyDocumentException(
          message: 'The PDF document contains 0 pages.',
          sourceType: DocumentSourceType.pdf,
        );
      }

      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String extractedRawText = extractor.extractText();

      final String cleaned = _ocrService.normalizeOcrText(extractedRawText);

      // Detection for Scanned/Image-only PDFs (pages exist, but text layer is absent or trivial)
      if (cleaned.length < 25) {
        throw ScannedPdfWithoutTextException(
          message:
              'This PDF appears to be a scanned image or bitmap without an embedded text layer ($pageCount pages detected).\n\nPlease scan individual pages using Camera Scan or convert the PDF with OCR before importing.',
          detectedPages: pageCount,
        );
      }

      final words = cleaned
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;

      final suggestedTitle = _ocrService.extractSuggestedTitle(cleaned);

      return ExtractedDocumentResult(
        rawText: extractedRawText,
        cleanedText: cleaned,
        sourceType: DocumentSourceType.pdf,
        sourceName: fileName,
        pageCount: pageCount,
        characterCount: cleaned.length,
        wordCount: words,
        confidenceScore: 0.98,
        suggestedTitle: suggestedTitle ?? fileName.replaceAll('.pdf', ''),
      );
    } catch (e) {
      if (e is DocumentExtractionException) rethrow;

      // Handle corrupted or encrypted PDFs
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('password') || errorStr.contains('encrypted')) {
        throw CorruptedFileException(
          message:
              'The PDF file "$fileName" is password protected. Please unlock it before importing.',
          sourceType: DocumentSourceType.pdf,
          originalError: e,
        );
      }

      throw CorruptedFileException(
        message:
            'Unable to parse PDF file "$fileName". The file format may be corrupted or unsupported.',
        sourceType: DocumentSourceType.pdf,
        originalError: e,
      );
    } finally {
      document?.dispose();
    }
  }
}

