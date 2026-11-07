import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/comic_story_model.dart';

enum TtsPlaybackStatus {
  stopped,
  speaking,
  paused,
}

enum VoicePersona {
  nova(
    displayName: 'Nova (Expressive Scholar)',
    pitch: 1.0,
    rate: 0.5,
    description: 'Natural, balanced scholar voice',
  ),
  sage(
    displayName: 'Sage (Cosmic Mentor)',
    pitch: 0.75,
    rate: 0.45,
    description: 'Deep, resonant mentor voice',
  ),
  spark(
    displayName: 'Spark (Energetic Hero)',
    pitch: 1.25,
    rate: 0.55,
    description: 'Bright, high-energy hero voice',
  );

  final String displayName;
  final double pitch;
  final double rate;
  final String description;

  const VoicePersona({
    required this.displayName,
    required this.pitch,
    required this.rate,
    required this.description,
  });
}

/// Text-to-Speech audio narration service for comic panels and educational dialogues
/// with volume adjustment, 3 distinct voice personas, and native Hindi/multilingual pronunciation.
class ComicTtsService {
  static const _volumePrefKey = 'lorvani_tts_volume';
  static const _personaPrefKey = 'lorvani_tts_persona';

  FlutterTts? flutterTts;
  final bool isMockMode;
  final SharedPreferences? prefs;

  TtsPlaybackStatus _status = TtsPlaybackStatus.stopped;
  String? _currentlySpeakingText;
  VoidCallback? onSpeechCompleted;

  double _volume = 1.0;
  VoicePersona _persona = VoicePersona.nova;
  String _currentLanguageCode = 'en-US';

  ComicTtsService({
    this.flutterTts,
    this.isMockMode = false,
    this.prefs,
  }) {
    _loadStoredPreferences();
    if (!isMockMode) {
      _initTts();
    }
  }

  void _loadStoredPreferences() {
    if (prefs != null) {
      _volume = prefs!.getDouble(_volumePrefKey) ?? 1.0;
      final storedPersonaName = prefs!.getString(_personaPrefKey);
      if (storedPersonaName != null) {
        _persona = VoicePersona.values.firstWhere(
          (p) => p.name == storedPersonaName,
          orElse: () => VoicePersona.nova,
        );
      }
    }
  }

  void _initTts() {
    try {
      flutterTts ??= FlutterTts();
      _initialize();
    } catch (e) {
      debugPrint('ComicTtsService initialize error (headless/unsupported): $e');
    }
  }

  void _initialize() {
    final tts = flutterTts;
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

      // Apply initial volume & voice persona
      _applyVoiceParams();
    } catch (e) {
      debugPrint('ComicTtsService initialize error (headless/unsupported): $e');
    }
  }

  TtsPlaybackStatus get status => _status;
  bool get isSpeaking => _status == TtsPlaybackStatus.speaking;
  String? get currentlySpeakingText => _currentlySpeakingText;
  double get volume => _volume;
  VoicePersona get persona => _persona;
  String get currentLanguageCode => _currentLanguageCode;

  /// Sets audio playback volume (0.0 silent to 1.0 maximum)
  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);
    prefs?.setDouble(_volumePrefKey, _volume);
    if (!isMockMode && flutterTts != null) {
      try {
        await flutterTts!.setVolume(_volume);
      } catch (e) {
        debugPrint('Error setting TTS volume: $e');
      }
    }
  }

  /// Changes voice persona (Nova, Sage, Spark)
  Future<void> setVoicePersona(VoicePersona newPersona) async {
    _persona = newPersona;
    prefs?.setString(_personaPrefKey, _persona.name);
    await _applyVoiceParams();
  }

  Future<void> _applyVoiceParams({bool isHindi = false}) async {
    if (isMockMode || flutterTts == null) return;
    try {
      await flutterTts!.setVolume(_volume);

      // Hindi speech engine needs a brisk, natural rate and standard pitch
      // to avoid sluggish, robotic syllable dragging.
      final pitch = isHindi ? 1.0 : _persona.pitch;
      final rate = isHindi ? 0.60 : _persona.rate;

      await flutterTts!.setPitch(pitch);
      await flutterTts!.setSpeechRate(rate);
    } catch (e) {
      debugPrint('Error applying TTS voice params: $e');
    }
  }

  /// Strips markdown characters and symbols that cause TTS hesitation or artifacts
  static String sanitizeForTts(String text) {
    return text
        .replaceAll(RegExp(r'[*_~#`>\[\]]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Resolves the optimal IETF BCP 47 language code for speech synthesis
  static String resolveLanguageCode(String? storyLanguage, String sampleText) {
    if (storyLanguage != null) {
      final normalized = storyLanguage.trim().toLowerCase();
      if (normalized == 'hindi' || normalized == 'hi') return 'hi-IN';
      if (normalized == 'spanish' || normalized == 'es') return 'es-ES';
      if (normalized == 'french' || normalized == 'fr') return 'fr-FR';
      if (normalized == 'german' || normalized == 'de') return 'de-DE';
    }

    // Auto-detect Devanagari Unicode script for Hindi
    final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(sampleText);
    if (hasDevanagari) {
      return 'hi-IN';
    }

    return 'en-US';
  }

  /// Sets TTS language code before speaking
  Future<void> setLanguage(String languageCode) async {
    _currentLanguageCode = languageCode;
    if (isMockMode || flutterTts == null) return;
    try {
      await flutterTts!.setLanguage(languageCode);
    } catch (e) {
      debugPrint('Error setting TTS language to $languageCode: $e');
    }
  }

  /// Synthesizes panel narration and dialogues into a natural voice script
  static String buildPanelSpeechScript(ComicPanelModel panel, {String? language}) {
    final buffer = StringBuffer();
    final isHindi = (language?.toLowerCase() == 'hindi') ||
        RegExp(r'[\u0900-\u097F]').hasMatch(panel.narration);

    final cleanNarration = sanitizeForTts(panel.narration);
    if (cleanNarration.isNotEmpty) {
      buffer.write(cleanNarration);
      buffer.write('. ');
    }

    for (final d in panel.dialogue) {
      final cleanText = sanitizeForTts(d.text);
      if (cleanText.isNotEmpty) {
        final cleanSpeaker = sanitizeForTts(d.speaker);
        if (isHindi) {
          // Clean, fluent Hindi dialogue flow without repetitive robotic phrasing
          if (cleanSpeaker.isNotEmpty && RegExp(r'[\u0900-\u097F]').hasMatch(cleanSpeaker)) {
            buffer.write('$cleanSpeaker: $cleanText. ');
          } else {
            buffer.write('$cleanText. ');
          }
        } else {
          buffer.write('$cleanSpeaker says: $cleanText. ');
        }
      }
    }

    return buffer.toString().trim();
  }

  /// Speaks the provided text in the target language
  Future<bool> speak(String text, {String? language}) async {
    final cleanText = sanitizeForTts(text);
    if (cleanText.isEmpty) return false;

    _currentlySpeakingText = cleanText;
    _status = TtsPlaybackStatus.speaking;

    final targetLang = resolveLanguageCode(language, cleanText);
    final isHindi = targetLang == 'hi-IN';
    if (targetLang != _currentLanguageCode) {
      await setLanguage(targetLang);
    }

    if (isMockMode) {
      return true;
    }

    try {
      await _applyVoiceParams(isHindi: isHindi);
      final result = await flutterTts?.speak(cleanText);
      return result == 1;
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _status = TtsPlaybackStatus.stopped;
      return false;
    }
  }

  /// Immediately cancels and stops any active or pending speech
  Future<bool> stop() async {
    _status = TtsPlaybackStatus.stopped;
    _currentlySpeakingText = null;

    if (isMockMode) {
      return true;
    }

    try {
      final result = await flutterTts?.stop();
      return result == 1;
    } catch (e) {
      debugPrint('TTS stop error: $e');
      return false;
    }
  }

  Future<bool> pause() async {
    if (isMockMode) {
      _status = TtsPlaybackStatus.paused;
      return true;
    }

    try {
      final result = await flutterTts?.pause();
      if (result == 1) {
        _status = TtsPlaybackStatus.paused;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('TTS pause error: $e');
      return false;
    }
  }
}
