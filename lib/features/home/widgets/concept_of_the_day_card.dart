import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/comic_speech_bubble.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/halftone_container.dart';

/// Concept of the Day Card with Comic Narration Box aesthetic
class ConceptOfTheDayCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ConceptOfTheDayCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final concept = AppConstants.conceptOfTheDay;

    return ComicPanel(
      backgroundColor: ComicColors.cardBackground,
      borderColor: ComicColors.electricYellow.withValues(alpha: 0.8),
      borderRadius: 18,
      borderWidth: 2.2,
      shadowOffset: const Offset(4, 4),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: HalftoneContainer(
        backgroundColor: ComicColors.cardBackground,
        dotColor: ComicColors.electricYellow.withValues(alpha: 0.08),
        spacing: 12,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tag & Read time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ComicColors.electricYellow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ComicColors.comicBorder, width: 1.5),
                    ),
                    child: Text(
                      'CONCEPT OF THE DAY',
                      style: ComicTypography.comicDisplay(
                        fontSize: 11,
                        color: ComicColors.deepCharcoal,
                      ),
                    ),
                  ),
                  BadgeChip(
                    label: concept['readTime'] as String,
                    icon: Icons.timer_outlined,
                    backgroundColor: ComicColors.surfaceLight,
                    textColor: ComicColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                concept['title'] as String,
                style: ComicTypography.heading(fontSize: 18),
              ),
              const SizedBox(height: 10),

              // Comic Narration Box
              NarrationBox(
                narrator: 'Biology Log',
                text: concept['teaser'] as String,
                backgroundColor: ComicColors.surfaceLight,
                textColor: ComicColors.softWhite,
                borderColor: ComicColors.electricYellow.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),

              // Bottom action bar
              Row(
                children: [
                  BadgeChip.category(
                    name: concept['subject'] as String,
                    color: ComicColors.subjectBiology,
                  ),
                  const Spacer(),
                  Text(
                    'Read Issue',
                    style: ComicTypography.bodyMedium(
                      fontSize: 13,
                      color: ComicColors.skyCyan,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: ComicColors.skyCyan,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
