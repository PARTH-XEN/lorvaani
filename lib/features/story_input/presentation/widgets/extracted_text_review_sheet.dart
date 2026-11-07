import 'package:flutter/material.dart';
import '../../../../core/services/document/document_processing_types.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';
import '../../../../core/widgets/badge_chip.dart';
import '../../../../core/widgets/comic_button.dart';
import '../../../../core/widgets/comic_panel.dart';

/// Interactive modal sheet allowing users to review, correct, and edit OCR/PDF extracted text
class ExtractedTextReviewSheet extends StatefulWidget {
  final ExtractedDocumentResult result;
  final Function(String editedText) onAccept;
  final VoidCallback onDismiss;

  const ExtractedTextReviewSheet({
    super.key,
    required this.result,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  State<ExtractedTextReviewSheet> createState() =>
      _ExtractedTextReviewSheetState();
}

class _ExtractedTextReviewSheetState extends State<ExtractedTextReviewSheet> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.result.cleanedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ComicColors.deepCharcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: ComicColors.comicBorder, width: 2.5),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 16,
        left: 20,
        right: 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: ComicColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REVIEW EXTRACTED TEXT',
                style: ComicTypography.comicDisplay(
                  fontSize: 18,
                  color: ComicColors.skyCyan,
                ),
              ),
              BadgeChip.category(
                name: widget.result.sourceType.label,
                color: ComicColors.skyCyan,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Check and correct any words before adding them to your comic story.',
            style: ComicTypography.caption(color: ComicColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Metric Badges
          Row(
            children: [
              BadgeChip(
                label: '${widget.result.wordCount} Words',
                icon: Icons.text_snippet_outlined,
              ),
              const SizedBox(width: 8),
              BadgeChip(
                label: '${widget.result.characterCount} Characters',
                icon: Icons.numbers_outlined,
              ),
              const SizedBox(width: 8),
              if (widget.result.pageCount > 1)
                BadgeChip(
                  label: '${widget.result.pageCount} Pages',
                  icon: Icons.auto_stories_outlined,
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Editable Review Field inside Comic Panel
          Expanded(
            child: ComicPanel(
              backgroundColor: ComicColors.cardBackground,
              padding: const EdgeInsets.all(12),
              borderRadius: 14,
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                style: ComicTypography.body(fontSize: 13, height: 1.5),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Edit extracted content...',
                  hintStyle: ComicTypography.body(color: ComicColors.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ComicButton(
                  text: 'Cancel',
                  variant: ComicButtonVariant.dark,
                  onPressed: widget.onDismiss,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ComicButton(
                  text: 'Accept & Insert',
                  icon: Icons.check_circle_rounded,
                  variant: ComicButtonVariant.gradient,
                  onPressed: () {
                    widget.onAccept(_textController.text.trim());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
