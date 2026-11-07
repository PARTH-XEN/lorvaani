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
  });
}

