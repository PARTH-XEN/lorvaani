import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../data/models/comic_story_model.dart';
import '../../data/panel_image_state.dart';
import 'comic_fallback_panel_artwork.dart';

/// Interactive Comic Panel Image Widget supporting network streaming, caching,
/// inking progress shimmers, graphic novel fallbacks, and retry actions.
class ComicPanelImageView extends StatelessWidget {
  final ComicPanelModel panel;
  final String? visualStyle;
  final String? imageUrl;
  final PanelImageStatus status;
  final VoidCallback? onRetry;
  final double height;
  final BoxFit fit;

  const ComicPanelImageView({
    super.key,
    required this.panel,
    this.visualStyle,
    this.imageUrl,
    this.status = PanelImageStatus.idle,
    this.onRetry,
    this.height = 260,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = imageUrl ?? panel.imageUrl;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ComicColors.deepCharcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 4),
            blurRadius: 0, // Sharp comic drop shadow
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(context, effectiveUrl),
    );
  }

  Widget _buildContent(BuildContext context, String? effectiveUrl) {
    if (status == PanelImageStatus.generating) {
      return ComicFallbackPanelArtwork(
        panel: panel,
        visualStyle: visualStyle,
        isGenerating: true,
      );
    }

    if (effectiveUrl != null && effectiveUrl.isNotEmpty) {
      return Image.network(
        effectiveUrl,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ComicFallbackPanelArtwork(
            panel: panel,
            visualStyle: visualStyle,
            isGenerating: true,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return ComicFallbackPanelArtwork(
            panel: panel,
            visualStyle: visualStyle,
            onRetry: onRetry,
          );
        },
      );
    }

    // Default Fallback
    return ComicFallbackPanelArtwork(
      panel: panel,
      visualStyle: visualStyle,
      onRetry: onRetry,
    );
  }
}

