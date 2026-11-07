import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';
import '../../../../core/widgets/badge_chip.dart';
import '../../../../core/widgets/comic_button.dart';
import '../../../../core/widgets/comic_panel.dart';
import '../../../../data/models/comic_story_model.dart';

/// Card component representing a saved comic story in the user's offline library
class SavedStoryCard extends StatelessWidget {
  final ComicStory story;
  final VoidCallback onRead;
  final VoidCallback onQuiz;
  final VoidCallback onExportPdf;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const SavedStoryCard({
    super.key,
    required this.story,
    required this.onRead,
    required this.onQuiz,
    required this.onExportPdf,
    required this.onShare,
    required this.onDelete,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ComicColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        title: Text(
          'DELETE STORY?',
          style: ComicTypography.comicDisplay(
            fontSize: 20,
            color: Colors.redAccent,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${story.storyTitle}" from your offline library?',
          style: ComicTypography.body(color: ComicColors.softWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: ComicTypography.body(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            child: Text(
              'Delete',
              style: ComicTypography.body(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateString =
        '${story.createdAt.year}-${story.createdAt.month.toString().padLeft(2, '0')}-${story.createdAt.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ComicPanel(
        backgroundColor: ComicColors.cardBackground,
        borderColor: ComicColors.comicPurple,
        borderWidth: 2,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Subject category + Level badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BadgeChip.category(
                      name: story.originalTopic,
                      color: ComicColors.comicPink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BadgeChip.level(level: story.learningLevel),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              story.storyTitle,
              style: ComicTypography.title(
                fontSize: 18,
                color: ComicColors.softWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // Overview summary
            Text(
              story.shortIntroduction.isNotEmpty ? story.shortIntroduction : story.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ComicTypography.body(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Info Pills & Date
            Row(
              children: [
                BadgeChip(
                  label: '${story.panels.length} Panels',
                  icon: Icons.view_carousel_rounded,
                  backgroundColor: ComicColors.deepCharcoal,
                  textColor: ComicColors.electricYellow,
                ),
                const SizedBox(width: 8),
                BadgeChip(
                  label: '${story.quizQuestions.length} Questions',
                  icon: Icons.quiz_rounded,
                  backgroundColor: ComicColors.deepCharcoal,
                  textColor: ComicColors.skyCyan,
                ),
                const Spacer(),
                Text(
                  dateString,
                  style: ComicTypography.caption(color: Colors.white38),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Bottom Actions Bar
            Row(
              children: [
                // Read CTA
                Expanded(
                  child: ComicButton(
                    text: 'Read Comic ➔',
                    icon: Icons.auto_stories_rounded,
                    variant: ComicButtonVariant.primary,
                    height: 44,
                    onPressed: onRead,
                  ),
                ),
                const SizedBox(width: 8),

                // Quiz button
                IconButton(
                  icon: const Icon(Icons.quiz_rounded, color: ComicColors.electricYellow),
                  tooltip: 'Take Quiz',
                  onPressed: onQuiz,
                ),

                // PDF Export button
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_rounded, color: ComicColors.skyCyan),
                  tooltip: 'Export PDF',
                  onPressed: onExportPdf,
                ),

                // Share button
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: ComicColors.softWhite),
                  tooltip: 'Share Story',
                  onPressed: onShare,
                ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'Delete Story',
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

