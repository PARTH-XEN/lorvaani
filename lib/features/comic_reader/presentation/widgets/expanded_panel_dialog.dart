import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';
import '../../../../data/models/comic_story_model.dart';
import '../../../image_generation/presentation/widgets/comic_panel_image_view.dart';

/// Fullscreen zoomable modal for inspecting comic panel illustration and dialogue in detail
class ExpandedPanelDialog extends StatelessWidget {
  final ComicPanelModel panel;
  final String? visualStyle;
  final VoidCallback onClose;

  const ExpandedPanelDialog({
    super.key,
    required this.panel,
    this.visualStyle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        decoration: BoxDecoration(
          color: ComicColors.deepCharcoal,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ComicColors.comicPurple, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              offset: Offset(4, 6),
              blurRadius: 16,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: ComicColors.cardBackground,
              child: Row(
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      panel.panelTitle,
                      overflow: TextOverflow.ellipsis,
                      style: ComicTypography.title(
                        color: ComicColors.softWhite,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ComicColors.softWhite),
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // Zoomable Panel Art
            Expanded(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 3.5,
                child: Center(
                  child: ComicPanelImageView(
                    panel: panel,
                    visualStyle: visualStyle,
                    height: 380,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Bottom details drawer
            Container(
              padding: const EdgeInsets.all(16),
              color: ComicColors.cardBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (panel.narration.isNotEmpty) ...[
                    Text(
                      'NARRATION',
                      style: ComicTypography.caption(
                        color: ComicColors.electricYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      panel.narration,
                      style: ComicTypography.body(
                        color: ComicColors.softWhite,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (panel.dialogue.isNotEmpty) ...[
                    Text(
                      'DIALOGUE',
                      style: ComicTypography.caption(
                        color: ComicColors.skyCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ...panel.dialogue.map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '${d.speaker}: "${d.text}"',
                          style: ComicTypography.body(
                            color: ComicColors.softWhite,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

