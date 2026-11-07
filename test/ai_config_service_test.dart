import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/ai/ai_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AiConfigService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to configured Groq key out-of-the-box', () async {
      final service = await AiConfigService.initialize();

      expect(service.hasLiveKeyConfigured, isTrue);
      expect(service.activeProviderName, contains('Groq'));
      expect(service.getGroqApiKey(), AiConfigService.defaultGroqApiKey);
      expect(service.getGeminiApiKey(), isNull);
    });

    test('stores and retrieves Gemini API key', () async {
      final service = await AiConfigService.initialize();
      await service.setGeminiApiKey('AIzaSyTestKey123');

      expect(service.getGeminiApiKey(), 'AIzaSyTestKey123');
      expect(service.hasLiveKeyConfigured, isTrue);

      // Clearing key restores null
      await service.setGeminiApiKey('');
      expect(service.getGeminiApiKey(), isNull);
    });
  });
}
