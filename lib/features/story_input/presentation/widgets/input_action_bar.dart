import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';
import '../../../../core/widgets/comic_panel.dart';

/// Quick action bar for Camera, Gallery, PDF, and Paste
class InputActionBar extends StatelessWidget {
  final VoidCallback onPaste;
  final VoidCallback onCameraScan;
  final VoidCallback onGalleryImport;
  final VoidCallback onPdfImport;
  final VoidCallback onClear;
  final bool hasContent;

  const InputActionBar({
    super.key,
    required this.onPaste,
    required this.onCameraScan,
    required this.onGalleryImport,
    required this.onPdfImport,
    required this.onClear,
    required this.hasContent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildActionButton(
            label: 'Paste',
            icon: Icons.content_paste_rounded,
            color: ComicColors.electricYellow,
            onTap: onPaste,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: 'Scan Camera',
            icon: Icons.camera_alt_rounded,
            color: ComicColors.skyCyan,
            onTap: onCameraScan,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: 'Image OCR',
            icon: Icons.image_rounded,
            color: ComicColors.comicPink,
            onTap: onGalleryImport,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: 'Import PDF',
            icon: Icons.picture_as_pdf_rounded,
            color: ComicColors.vibrantOrange,
            onTap: onPdfImport,
          ),
          if (hasContent) ...[
            const SizedBox(width: 8),
            _buildActionButton(
              label: 'Clear',
              icon: Icons.delete_outline_rounded,
              color: Colors.redAccent,
              onTap: onClear,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ComicPanel(
      backgroundColor: ComicColors.cardBackground,
      borderColor: color.withValues(alpha: 0.6),
      borderRadius: 12,
      borderWidth: 1.8,
      shadowOffset: const Offset(2, 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: ComicTypography.caption(
              fontSize: 12,
              color: ComicColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

