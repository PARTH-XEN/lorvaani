import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/image_generation/data/panel_image_state.dart';
import 'package:lorevaani/features/image_generation/presentation/widgets/comic_fallback_panel_artwork.dart';
import 'package:lorevaani/features/image_generation/presentation/widgets/comic_panel_image_view.dart';

void main() {
  const samplePanel = ComicPanelModel(
    panelNumber: 1,
    panelTitle: 'Photon Absorption',
    panelDescription: 'Photons hit chlorophyll pigment inside the thylakoid.',
    narration: 'Light energy is captured by photosynthetic pigments.',
    dialogue: [
      ComicDialogue(speaker: 'Prof. Photon', text: 'Energizing electron transport chain!'),
    ],
    keyVisualCue: 'Glowing sunbeam striking emerald thylakoid discs',
  );

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            height: 300,
            child: child,
          ),
        ),
      ),
    );
  }

  group('ComicPanelImageView & Fallback Artwork Widget Tests', () {
    testWidgets('renders fallback artwork with panel title and visual cue', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ComicFallbackPanelArtwork(
            panel: samplePanel,
            visualStyle: 'Classic Comic',
          ),
        ),
      );

      expect(find.text('PANEL 1'), findsOneWidget);
      expect(find.text('PHOTON ABSORPTION'), findsOneWidget);
      expect(find.textContaining('Glowing sunbeam'), findsOneWidget);
      expect(find.textContaining('Prof. Photon'), findsOneWidget);
    });

    testWidgets('shows drawing indicator when isGenerating is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ComicPanelImageView(
            panel: samplePanel,
            status: PanelImageStatus.generating,
          ),
        ),
      );

      expect(find.text('Drawing...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows retry button and invokes onRetry callback on tap', (tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          ComicPanelImageView(
            panel: samplePanel,
            status: PanelImageStatus.failed,
            onRetry: () {
              retryTapped = true;
            },
          ),
        ),
      );

      expect(find.text('Retry Art'), findsOneWidget);
      await tester.tap(find.text('Retry Art'));
      await tester.pump();

      expect(retryTapped, isTrue);
    });
  });
}

