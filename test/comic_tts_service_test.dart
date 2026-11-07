import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/audio/comic_tts_service.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';

void main() {
  group('ComicTtsService Tests', () {
    late ComicTtsService ttsService;

    setUp(() {
      ttsService = ComicTtsService(isMockMode: true);
    });

    test('builds complete panel speech script from narration and dialogue', () {
      const panel = ComicPanelModel(
        panelNumber: 1,
        panelTitle: 'Title',
        panelDescription: 'Desc',
        narration: 'The sun provides energy for the leaf',
        dialogue: [
          ComicDialogue(speaker: 'Dr. Flora', text: 'Look at the chlorophyll!'),
          ComicDialogue(speaker: 'Bot', text: 'Processing photons.'),
        ],
        keyVisualCue: 'Sunlight',
      );

      final script = ComicTtsService.buildPanelSpeechScript(panel);

      expect(script, contains('The sun provides energy for the leaf.'));
      expect(script, contains('Dr. Flora says: Look at the chlorophyll!.'));
      expect(script, contains('Bot says: Processing photons..'));
    });

    test('starts speaking and sets status', () async {
      expect(ttsService.isSpeaking, isFalse);

      final success = await ttsService.speak('Testing speech output');

      expect(success, isTrue);
      expect(ttsService.isSpeaking, isTrue);
      expect(ttsService.currentlySpeakingText, equals('Testing speech output'));
    });

    test('stops speaking cleanly', () async {
      await ttsService.speak('First text');
      expect(ttsService.isSpeaking, isTrue);

      await ttsService.stop();
      expect(ttsService.isSpeaking, isFalse);
      expect(ttsService.currentlySpeakingText, isNull);
    });

    test('pauses speaking cleanly', () async {
      await ttsService.speak('Another text');
      await ttsService.pause();

      expect(ttsService.status, equals(TtsPlaybackStatus.paused));
    });

    test('updates volume and persona correctly', () async {
      expect(ttsService.volume, equals(1.0));
      expect(ttsService.persona, equals(VoicePersona.nova));

      await ttsService.setVolume(0.4);
      expect(ttsService.volume, closeTo(0.4, 0.01));

      await ttsService.setVoicePersona(VoicePersona.sage);
      expect(ttsService.persona, equals(VoicePersona.sage));

      await ttsService.setVoicePersona(VoicePersona.spark);
      expect(ttsService.persona, equals(VoicePersona.spark));
    });

    test('resolves Hindi language code and formats Hindi dialogue properly', () {
      final langCode = ComicTtsService.resolveLanguageCode('Hindi', 'प्रकाश संश्लेषण');
      expect(langCode, equals('hi-IN'));

      final script = ComicTtsService.buildPanelSpeechScript(
        const ComicPanelModel(
          panelNumber: 1,
          panelTitle: 'Title',
          panelDescription: 'Desc',
          narration: 'पौधे सूर्य से ऊर्जा लेते हैं',
          dialogue: [
            ComicDialogue(speaker: 'अध्यापक', text: 'यह पर्णहरित है'),
          ],
          keyVisualCue: 'Sunlight',
        ),
        language: 'Hindi',
      );

      expect(script, contains('पौधे सूर्य से ऊर्जा लेते हैं.'));
      expect(script, contains('अध्यापक: यह पर्णहरित है.'));
    });

    test('sanitizes markdown artifacts and excessive symbols from text for TTS', () {
      final sanitized = ComicTtsService.sanitizeForTts('**Bold** and *italic* #header [link]');
      expect(sanitized, equals('Bold and italic header link'));
    });
  });
}

