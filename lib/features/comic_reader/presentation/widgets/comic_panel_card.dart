import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';
import '../../../../core/widgets/comic_panel.dart';
import '../../../../core/widgets/comic_speech_bubble.dart';
import '../../../../data/models/comic_story_model.dart';
import '../../../image_generation/presentation/widgets/comic_panel_image_view.dart';
import 'comic_sound_badge.dart';

/// Full interactive comic panel card rendering artwork, sound badge, narration box, and speech bubbles
class ComicPanelCard extends StatelessWidget {
  final ComicPanelModel panel;
  final String? visualStyle;
  final VoidCallback? onExpand;
  final void Function(ComicDialogue dialogue)? onSpeechBubbleTap;

  const ComicPanelCard({
    super.key,
    required this.panel,
    this.visualStyle,
    this.onExpand,
    this.onSpeechBubbleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ComicPanel(
      borderColor: Colors.black,
      backgroundColor: ComicColors.cardBackground,
      borderWidth: 2.5,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Panel Header Row (Panel number + title + expand icon)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ComicColors.vibrantOrange,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  'PANEL ${panel.panelNumber}',
                  style: ComicTypography.caption(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  panel.panelTitle,
                  style: ComicTypography.title(
                    color: ComicColors.softWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onExpand != null)
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded, color: ComicColors.skyCyan),
                  onPressed: onExpand,
                  tooltip: 'Expand Panel',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. Illustration Area with overlaid Sound Badge
          Stack(
            children: [
              ComicPanelImageView(
                panel: panel,
                visualStyle: visualStyle,
                height: 250,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: ComicSoundBadge.fromVisualCue(
                  panel.keyVisualCue,
                  panel.panelNumber,
                ),
              ),
            ],
          ),

          // 3. Narration Box (if available)
          if (panel.narration.isNotEmpty) ...[
            const SizedBox(height: 10),
            NarrationBox(
              text: panel.narration,
            ),
          ],

          // 4. Interactive Speech Bubbles
          if (panel.dialogue.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...panel.dialogue.map((dialogue) {
              final isLeft = panel.dialogue.indexOf(dialogue) % 2 == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment:
                      isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () => onSpeechBubbleTap?.call(dialogue),
                        child: ComicSpeechBubble(
                          tailDirection: isLeft
                              ? BubbleTailDirection.bottomLeft
                              : BubbleTailDirection.bottomRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dialogue.speaker.toUpperCase(),
                                style: ComicTypography.caption(
                                  color: ComicColors.comicPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dialogue.text,
                                style: ComicTypography.body(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
