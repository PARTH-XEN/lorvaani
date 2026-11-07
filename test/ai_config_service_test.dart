import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/ai/ai_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AiConfigService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to no live keys and offline story engine', () async {
      final service = await AiConfigService.initialize();

      expect(service.hasLiveKeyConfigured, isFalse);
      expect(service.activeProviderName, 'Offline Comic Story Engine');
      expect(service.getGeminiApiKey(), isNull);
    });

    test('stores and retrieves Gemini API key', () async {
      final service = await AiConfigService.initialize();
      await service.setGeminiApiKey('AIzaSyTestKey123');

      expect(service.getGeminiApiKey(), 'AIzaSyTestKey123');
      expect(service.hasLiveKeyConfigured, isTrue);
      expect(service.activeProviderName, contains('Gemini'));

      // Clearing key restores offline engine
      await service.setGeminiApiKey('');
      expect(service.getGeminiApiKey(), isNull);
      expect(service.hasLiveKeyConfigured, isFalse);
    });
  });
}
