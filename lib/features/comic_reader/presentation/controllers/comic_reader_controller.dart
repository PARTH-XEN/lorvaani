import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio/comic_tts_service.dart';
import '../../../../data/models/comic_story_model.dart';
import '../../data/comic_reader_state.dart';

final comicTtsServiceProvider = Provider<ComicTtsService>((ref) {
  return ComicTtsService();
});

final comicReaderControllerProvider =
    NotifierProvider<ComicReaderController, ComicReaderState>(
  ComicReaderController.new,
);

class ComicReaderController extends Notifier<ComicReaderState> {
  late ComicTtsService _ttsService;

  @override
  ComicReaderState build() {
    _ttsService = ref.watch(comicTtsServiceProvider);
    _ttsService.onSpeechCompleted = _handleSpeechCompleted;
    return const ComicReaderState();
  }

  // Helper for dependency injection during testing
  void setTtsService(ComicTtsService ttsService) {
    _ttsService = ttsService;
    _ttsService.onSpeechCompleted = _handleSpeechCompleted;
  }

  void _handleSpeechCompleted() {
    if (state.isAutoPlaying) {
      if (!state.isLastPanel) {
        // Automatically advance to the next panel and continue speaking!
        Future.delayed(const Duration(milliseconds: 600), () {
          if (state.isAutoPlaying) {
            nextPanel();
            _speakCurrentPanelInAutoPlay();
          }
        });
        return;
      } else {
        // Reached end of comic!
        state = state.copyWith(isSpeaking: false, isAutoPlaying: false);
        return;
      }
    }
    state = state.copyWith(isSpeaking: false);
  }

  /// Initializes reader with a comic story
  void initialize(ComicStory story) {
    _ttsService.stop();
    state = ComicReaderState(
      story: story,
      currentPanelIndex: 0,
      readingMode: state.readingMode,
      isSpeaking: false,
      isAutoPlaying: false,
    );
  }

  /// Switches between horizontal page-turn and vertical webtoon scroll modes
  void toggleReadingMode() {
    final nextMode = state.readingMode == ReadingMode.horizontalPage
        ? ReadingMode.verticalScroll
        : ReadingMode.horizontalPage;
    state = state.copyWith(readingMode: nextMode);
  }

  /// Sets reading mode explicitly
  void setReadingMode(ReadingMode mode) {
    state = state.copyWith(readingMode: mode);
  }

  /// Jumps to specific panel index
  void goToPanel(int index) {
    if (state.story == null) return;
    final clamped = index.clamp(0, state.totalPanels - 1);
    if (clamped != state.currentPanelIndex) {
      _ttsService.stop();
      state = state.copyWith(
        currentPanelIndex: clamped,
        isSpeaking: false,
        isAutoPlaying: false,
      );
    }
  }

  /// Advances to next panel
  void nextPanel() {
    if (!state.isLastPanel) {
      final nextIdx = state.currentPanelIndex + 1;
      state = state.copyWith(currentPanelIndex: nextIdx);
    }
  }

  /// Moves back to previous panel
  void previousPanel() {
    if (!state.isFirstPanel) {
      final prevIdx = state.currentPanelIndex - 1;
      state = state.copyWith(currentPanelIndex: prevIdx);
    }
  }

  /// Explicitly halts any ongoing speech or auto-play sequence immediately
  Future<void> stopNarration() async {
    await _ttsService.stop();
    state = state.copyWith(isSpeaking: false, isAutoPlaying: false);
  }

  /// Toggles voice narration for the current panel
  Future<void> toggleAudioNarration() async {
    if (state.isSpeaking || state.isAutoPlaying) {
      await stopNarration();
      return;
    }

    final panel = state.currentPanel;
    if (panel == null) return;

    final lang = state.story?.language;
    final script = ComicTtsService.buildPanelSpeechScript(panel, language: lang);
    if (script.isEmpty) return;

    state = state.copyWith(isSpeaking: true);
    final success = await _ttsService.speak(script, language: lang);
    if (!success) {
      state = state.copyWith(isSpeaking: false);
    }
  }

  /// Hands-free Auto-Play: Reads entire comic from current panel to end, auto-advancing panels
  Future<void> toggleAutoPlayNarration() async {
    if (state.isAutoPlaying) {
      await stopNarration();
      return;
    }

    state = state.copyWith(isAutoPlaying: true);
    await _speakCurrentPanelInAutoPlay();
  }

  Future<void> _speakCurrentPanelInAutoPlay() async {
    final panel = state.currentPanel;
    if (panel == null) {
      state = state.copyWith(isSpeaking: false, isAutoPlaying: false);
      return;
    }

    final lang = state.story?.language;
    final script = ComicTtsService.buildPanelSpeechScript(panel, language: lang);
    if (script.isEmpty) {
      _handleSpeechCompleted();
      return;
    }

    state = state.copyWith(isSpeaking: true);
    final success = await _ttsService.speak(script, language: lang);
    if (!success) {
      state = state.copyWith(isSpeaking: false, isAutoPlaying: false);
    }
  }

  /// Speaks an individual dialogue bubble when tapped by the user
  Future<void> speakSingleDialogue(ComicDialogue dialogue) async {
    await _ttsService.stop();
    state = state.copyWith(isSpeaking: true, isAutoPlaying: false);
    final isHindi = (state.story?.language.toLowerCase() == 'hindi') ||
        RegExp(r'[\u0900-\u097F]').hasMatch(dialogue.text);
    final speechText = isHindi
        ? '${dialogue.speaker} कहते हैं: ${dialogue.text}'
        : '${dialogue.speaker} says: ${dialogue.text}';
    final success = await _ttsService.speak(speechText, language: state.story?.language);
    if (!success) {
      state = state.copyWith(isSpeaking: false);
    }
  }

  /// Opens panel in fullscreen zoomable modal
  void expandPanel(ComicPanelModel panel) {
    state = state.copyWith(expandedPanel: panel);
  }

  /// Closes fullscreen modal
  void closeExpandedPanel() {
    state = state.copyWith(clearExpandedPanel: true);
  }

  /// Opens or closes concept drawer
  void setConceptSheetOpen(bool open) {
    state = state.copyWith(isConceptSheetOpen: open);
  }
}
