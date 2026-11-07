import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';
import '../../../../data/models/comic_story_model.dart';

/// Comic Speed Lines & Action Burst Custom Painter
class ComicActionRaysPainter extends CustomPainter {
  final Color rayColor;
  final int rayCount;

  const ComicActionRaysPainter({
    required this.rayColor,
    this.rayCount = 18,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = rayColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.5, size.height * 0.45);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    final angleStep = (math.pi * 2) / rayCount;

    for (int i = 0; i < rayCount; i += 2) {
      final startAngle = i * angleStep;
      final endAngle = (i + 1) * angleStep;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + maxRadius * math.cos(startAngle),
          center.dy + maxRadius * math.sin(startAngle),
        )
        ..lineTo(
          center.dx + maxRadius * math.cos(endAngle),
          center.dy + maxRadius * math.sin(endAngle),
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ComicActionRaysPainter oldDelegate) =>
      oldDelegate.rayColor != rayColor || oldDelegate.rayCount != rayCount;
}

/// Stylized programmatic graphic novel fallback artwork when images are generating or offline
class ComicFallbackPanelArtwork extends StatelessWidget {
  final ComicPanelModel panel;
  final String? visualStyle;
  final VoidCallback? onRetry;
  final bool isGenerating;

  const ComicFallbackPanelArtwork({
    super.key,
    required this.panel,
    this.visualStyle,
    this.onRetry,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ComicColors.deepCharcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ComicColors.comicPurple, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dynamic comic background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  Color(0xFF382963), // Deep purple core
                  ComicColors.cardBackground,
                  ComicColors.deepCharcoal,
                ],
              ),
            ),
          ),

          // 2. Action rays burst in background
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: CustomPaint(
                painter: ComicActionRaysPainter(
                  rayColor: ComicColors.electricYellow,
                ),
              ),
            ),
          ),

          // 3. Central Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Panel tag + Status chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    if (isGenerating)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ComicColors.skyCyan.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: ComicColors.skyCyan, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(ComicColors.skyCyan),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Drawing...',
                              style: ComicTypography.caption(
                                color: ComicColors.skyCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (onRetry != null)
                      GestureDetector(
                        onTap: onRetry,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ComicColors.comicPink.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: ComicColors.comicPink, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh, size: 12, color: ComicColors.comicPink),
                              const SizedBox(width: 4),
                              Text(
                                'Retry Art',
                                style: ComicTypography.caption(
                                  color: ComicColors.comicPink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Center visual cue banner
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ComicColors.cardBackground.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ComicColors.comicPurple, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(2, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_stories_rounded,
                            size: 28,
                            color: ComicColors.electricYellow,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            panel.panelTitle.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: ComicTypography.title(
                              color: ComicColors.softWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (panel.keyVisualCue.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Focus: ${panel.keyVisualCue}',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ComicTypography.body(
                                color: ComicColors.skyCyan,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Bottom dialogue / narration callout preview
                if (panel.dialogue.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ComicColors.deepCharcoal.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: ComicColors.comicPurple.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${panel.dialogue.first.speaker}: "${panel.dialogue.first.text}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ComicTypography.body(
                        color: ComicColors.softWhite,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
