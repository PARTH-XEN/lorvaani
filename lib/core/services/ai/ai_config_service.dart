import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing user-provided AI API keys and model configurations.
class AiConfigService {
  static const _geminiKeyPref = 'lorvani_ai_gemini_key';
  static const _groqKeyPref = 'lorvani_ai_groq_key';

  /// Pre-configured high-speed Groq API key available out of the box
  static const defaultGroqApiKey =
      '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';

  final SharedPreferences? _prefs;

  AiConfigService([this._prefs]);

  static Future<AiConfigService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return AiConfigService(prefs);
  }

  /// Get stored Gemini API Key, falling back to compile-time environment variable.
  String? getGeminiApiKey() {
    final stored = _prefs?.getString(_geminiKeyPref);
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    return null;
  }

  /// Save Gemini API Key.
  Future<bool> setGeminiApiKey(String? key) async {
    if (_prefs == null) return false;
    if (key == null || key.trim().isEmpty) {
      return _prefs.remove(_geminiKeyPref);
    }
    return _prefs.setString(_geminiKeyPref, key.trim());
  }

  /// Get stored Groq API Key, falling back to compile-time environment variable or default key.
  String? getGroqApiKey() {
    final stored = _prefs?.getString(_groqKeyPref);
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }
    const envKey = String.fromEnvironment('GROQ_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    return defaultGroqApiKey;
  }

  /// Save Groq API Key.
  Future<bool> setGroqApiKey(String? key) async {
    if (_prefs == null) return false;
    if (key == null || key.trim().isEmpty) {
      return _prefs.remove(_groqKeyPref);
    }
    return _prefs.setString(_groqKeyPref, key.trim());
  }

  /// Check whether at least one live LLM provider has an active API key configured.
  bool get hasLiveKeyConfigured =>
      getGroqApiKey() != null || getGeminiApiKey() != null;

  /// Provider name currently in use for display.
  String get activeProviderName {
    if (getGroqApiKey() != null) return 'Groq LPU (GPT-OSS-120B)';
    if (getGeminiApiKey() != null) return 'Google Gemini 1.5 Flash';
    return 'Offline Comic Story Engine';
  }
}

final aiConfigServiceProvider = Provider<AiConfigService>((ref) {
  return AiConfigService();
});
