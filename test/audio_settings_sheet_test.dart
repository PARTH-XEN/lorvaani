import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/audio/comic_tts_service.dart';
import 'package:lorevaani/core/widgets/audio_settings_sheet.dart';
import 'package:lorevaani/features/comic_reader/presentation/controllers/comic_reader_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AudioSettingsSheet Widget Tests', () {
    late ComicTtsService ttsService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      ttsService = ComicTtsService(isMockMode: true);
    });

    Widget createAudioSheet() {
      return ProviderScope(
        overrides: [
          comicTtsServiceProvider.overrideWithValue(ttsService),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AudioSettingsSheet(),
          ),
        ),
      );
    }

    testWidgets('displays volume slider and all 3 voice personas', (tester) async {
      await tester.pumpWidget(createAudioSheet());
      await tester.pumpAndSettle();

      expect(find.text('AUDIO & VOICE SETTINGS'), findsOneWidget);
      expect(find.text('Volume Adjuster'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      expect(find.text('Nova (Expressive Scholar)'), findsOneWidget);
      expect(find.text('Sage (Cosmic Mentor)'), findsOneWidget);
      expect(find.text('Spark (Energetic Hero)'), findsOneWidget);
      expect(find.text('Preview Voice'), findsOneWidget);
    });

    testWidgets('tapping persona updates selected persona', (tester) async {
      await tester.pumpWidget(createAudioSheet());
      await tester.pumpAndSettle();

      // Tap Sage persona
      await tester.tap(find.text('Sage (Cosmic Mentor)'));
      await tester.pumpAndSettle();

      expect(ttsService.persona, equals(VoicePersona.sage));

      // Tap Spark persona
      await tester.tap(find.text('Spark (Energetic Hero)'));
      await tester.pumpAndSettle();

      expect(ttsService.persona, equals(VoicePersona.spark));
    });

    testWidgets('triggers voice preview when test button is tapped', (tester) async {
      await tester.pumpWidget(createAudioSheet());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Preview Voice'));
      await tester.pumpAndSettle();

      expect(ttsService.isSpeaking, isTrue);
    });
  });
}
