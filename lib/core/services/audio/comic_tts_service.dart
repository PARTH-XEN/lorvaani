import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../data/models/comic_story_model.dart';

enum TtsPlaybackStatus {
  stopped,
  speaking,
  paused,
}

/// Text-to-Speech audio narration service for comic panels and educational dialogues
class ComicTtsService {
  FlutterTts? _flutterTts;
  final bool isMockMode;

  TtsPlaybackStatus _status = TtsPlaybackStatus.stopped;
  String? _currentlySpeakingText;
  VoidCallback? onSpeechCompleted;

  ComicTtsService({
    FlutterTts? flutterTts,
    this.isMockMode = false,
  }) {
    _flutterTts = flutterTts;
    if (!isMockMode) {
      _initTts();
    }
  }

  void _initTts() {
    try {
      _flutterTts ??= FlutterTts();
      _initialize();
    } catch (e) {
      debugPrint('ComicTtsService initialize error (headless/unsupported): $e');
    }
  }

  void _initialize() {
    final tts = _flutterTts;
    if (tts == null) return;

    try {
      tts.setStartHandler(() {
        _status = TtsPlaybackStatus.speaking;
      });

      tts.setCompletionHandler(() {
        _status = TtsPlaybackStatus.stopped;
        _currentlySpeakingText = null;
        onSpeechCompleted?.call();
      });

      tts.setCancelHandler(() {
        _status = TtsPlaybackStatus.stopped;
        _currentlySpeakingText = null;
      });

      tts.setErrorHandler((dynamic message) {
        _status = TtsPlaybackStatus.stopped;
        _currentlySpeakingText = null;
      });
    } catch (e) {
      debugPrint('ComicTtsService initialize error (headless/unsupported): $e');
    }
  }

  TtsPlaybackStatus get status => _status;
  bool get isSpeaking => _status == TtsPlaybackStatus.speaking;
  String? get currentlySpeakingText => _currentlySpeakingText;

  /// Synthesizes panel narration and dialogues into a natural voice script
  static String buildPanelSpeechScript(ComicPanelModel panel) {
    final buffer = StringBuffer();

    if (panel.narration.trim().isNotEmpty) {
      buffer.write(panel.narration.trim());
      buffer.write('. ');
    }

    for (final d in panel.dialogue) {
      if (d.text.trim().isNotEmpty) {
        buffer.write('${d.speaker} says: ${d.text.trim()}. ');
      }
    }

    return buffer.toString().trim();
  }

  /// Speaks the provided text
  Future<bool> speak(String text) async {
    if (text.trim().isEmpty) return false;

    _currentlySpeakingText = text;
    _status = TtsPlaybackStatus.speaking;

    if (isMockMode) {
      return true;
    }

    try {
      final tts = _flutterTts;
      if (tts == null) return false;

      await tts.setLanguage('en-US');
      await tts.setSpeechRate(0.5);
      await tts.setVolume(1.0);
      await tts.setPitch(1.0);

      final result = await tts.speak(text);
      return result == 1;
    } catch (e) {
      debugPrint('ComicTtsService speak error: $e');
      _status = TtsPlaybackStatus.stopped;
      return false;
    }
  }

  /// Stops current speech output
  Future<void> stop() async {
    _status = TtsPlaybackStatus.stopped;
    _currentlySpeakingText = null;

    if (isMockMode) return;

    try {
      await _flutterTts?.stop();
    } catch (e) {
      debugPrint('ComicTtsService stop error: $e');
    }
  }

  /// Pauses current speech output
  Future<void> pause() async {
    _status = TtsPlaybackStatus.paused;

    if (isMockMode) return;

    try {
      await _flutterTts?.pause();
    } catch (e) {
      debugPrint('ComicTtsService pause error: $e');
    }
  }
}
