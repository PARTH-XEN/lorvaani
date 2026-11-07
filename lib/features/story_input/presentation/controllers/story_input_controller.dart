import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/document/document_processing_types.dart';
import '../../../../core/services/document/ocr_service.dart';
import '../../../../core/services/document/pdf_extractor_service.dart';
import '../../data/story_input_state.dart';

final ocrServiceProvider = Provider<OcrService>((ref) => const OcrService());
final pdfExtractorServiceProvider = Provider<PdfExtractorService>((ref) {
  return PdfExtractorService(ocrService: ref.watch(ocrServiceProvider));
});

final storyInputControllerProvider =
    NotifierProvider<StoryInputController, StoryInputState>(
  StoryInputController.new,
);

class StoryInputController extends Notifier<StoryInputState> {
  late OcrService _ocrService;
  late PdfExtractorService _pdfService;
  late ImagePicker _imagePicker;

  @override
  StoryInputState build() {
    _ocrService = ref.watch(ocrServiceProvider);
    _pdfService = ref.watch(pdfExtractorServiceProvider);
    _imagePicker = ImagePicker();
    return const StoryInputState();
  }

  // Helper for dependency injection during tests
  void setDependencies({
    OcrService? ocrService,
    PdfExtractorService? pdfService,
    ImagePicker? imagePicker,
  }) {
    if (ocrService != null) _ocrService = ocrService;
    if (pdfService != null) _pdfService = pdfService;
    if (imagePicker != null) _imagePicker = imagePicker;
  }

  void setTopicTitle(String title) {
    state = state.copyWith(
      topicTitle: title,
      clearValidationError: true,
    );
  }

  void setNotesText(
    String text, {
    DocumentSourceType sourceType = DocumentSourceType.manual,
  }) {
    state = state.copyWith(
      notesText: text,
      activeInputMethod: sourceType,
      clearValidationError: true,
    );
  }

  void clearAll() {
    state = const StoryInputState();
  }

  void loadSample(SampleNoteTemplate template) {
    state = state.copyWith(
      topicTitle: template.title,
      notesText: template.content,
      activeInputMethod: DocumentSourceType.sampleTemplate,
      clearValidationError: true,
      clearExtractionError: true,
    );
  }

  Future<void> pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text != null && text.trim().isNotEmpty) {
        setNotesText(text.trim(), sourceType: DocumentSourceType.clipboard);

        // If topic is empty, infer from first line
        if (state.topicTitle.isEmpty) {
          final suggested = _ocrService.extractSuggestedTitle(text);
          if (suggested != null) {
            setTopicTitle(suggested);
          }
        }
      } else {
        state = state.copyWith(
          extractionError: 'Clipboard is empty or does not contain plain text.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        extractionError: 'Could not access clipboard: $e',
      );
    }
  }

  Future<void> scanWithCamera() async {
    await _pickAndProcessImage(ImageSource.camera, DocumentSourceType.cameraOcr);
  }

  Future<void> importFromGallery() async {
    await _pickAndProcessImage(ImageSource.gallery, DocumentSourceType.galleryOcr);
  }

  Future<void> _pickAndProcessImage(
    ImageSource source,
    DocumentSourceType sourceType,
  ) async {
    state = state.copyWith(
      isExtracting: true,
      clearExtractionError: true,
      clearExtractedResult: true,
    );

    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (file == null) {
        state = state.copyWith(isExtracting: false);
        return; // User cancelled
      }

      final bytes = await file.readAsBytes();
      final result = _ocrService.simulateOcr(
        imageBytes: bytes,
        fileName: file.name,
        sourceType: sourceType,
      );

      state = state.copyWith(
        isExtracting: false,
        lastExtractedResult: result,
      );
    } on DocumentExtractionException catch (e) {
      state = state.copyWith(
        isExtracting: false,
        extractionError: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isExtracting: false,
        extractionError: 'Image processing failed: $e',
      );
    }
  }

  Future<void> importPdfDocument() async {
    state = state.copyWith(
      isExtracting: true,
      clearExtractionError: true,
      clearExtractedResult: true,
    );

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isEmpty) {
        state = state.copyWith(isExtracting: false);
        return; // Cancelled
      }

      final file = files.first;
      final bytes = await file.xFile.readAsBytes();

      final extracted = await _pdfService.extractTextFromPdfBytes(
        pdfBytes: bytes,
        fileName: file.name,
      );

      state = state.copyWith(
        isExtracting: false,
        lastExtractedResult: extracted,
      );
    } on DocumentExtractionException catch (e) {
      state = state.copyWith(
        isExtracting: false,
        extractionError: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isExtracting: false,
        extractionError: 'PDF extraction failed: $e',
      );
    }
  }

  void acceptExtractedResult(ExtractedDocumentResult result, {String? editedText}) {
    final textToUse = editedText ?? result.cleanedText;
    state = state.copyWith(
      notesText: textToUse,
      topicTitle: state.topicTitle.isEmpty
          ? (result.suggestedTitle ?? '')
          : state.topicTitle,
      activeInputMethod: result.sourceType,
      clearExtractedResult: true,
      clearExtractionError: true,
      clearValidationError: true,
    );
  }

  void dismissExtractedResult() {
    state = state.copyWith(clearExtractedResult: true);
  }

  bool validateAndProceed() {
    if (state.topicTitle.trim().isEmpty) {
      state = state.copyWith(
        validationError: 'Please provide a topic title for your comic story.',
      );
      return false;
    }

    if (state.notesText.trim().length < 25) {
      state = state.copyWith(
        validationError:
            'Please enter at least 25 characters of study notes to generate a meaningful comic.',
      );
      return false;
    }

    state = state.copyWith(clearValidationError: true);
    return true;
  }
}
