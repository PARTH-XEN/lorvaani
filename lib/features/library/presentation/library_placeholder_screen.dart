import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/badge_chip.dart';

/// Personal Comic Library Screen - Milestone 6 Target
class LibraryPlaceholderScreen extends StatelessWidget {
  const LibraryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          'COMIC LIBRARY',
          style: ComicTypography.comicDisplay(fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved Issues (${AppConstants.recentStories.length})',
                style: ComicTypography.title(fontSize: 16),
              ),
              BadgeChip(
                label: 'Offline Ready',
                icon: Icons.offline_pin_rounded,
                backgroundColor: ComicColors.comicPurple.withValues(alpha: 0.2),
                textColor: ComicColors.skyCyan,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...AppConstants.recentStories.map((story) {
            final color = story['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ComicPanel(
                backgroundColor: ComicColors.cardBackground,
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
                borderColor: color.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Center(
                        child: Icon(Icons.menu_book_rounded, color: color, size: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              BadgeChip.category(name: story['subject'] as String, color: color),
                              const Spacer(),
                              Text(
                                '${story['panels']} panels',
                                style: ComicTypography.caption(fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            story['title'] as String,
                            style: ComicTypography.title(fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: (story['progress'] as num).toDouble(),
                            backgroundColor: ComicColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
