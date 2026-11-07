import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/badge_chip.dart';

/// Explore Screen: Subject catalog and curated story exploration
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          'EXPLORE SUBJECTS',
          style: ComicTypography.comicDisplay(
            fontSize: 24,
            color: ComicColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Search Bar with Comic Styling
          ComicPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            borderRadius: 14,
            backgroundColor: ComicColors.surfaceLight,
            shadowOffset: const Offset(3, 3),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: ComicColors.textSecondary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: ComicTypography.body(color: ComicColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search stories, topics or concepts...',
                      hintStyle: ComicTypography.body(
                        color: ComicColors.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Title
          Text(
            'All Disciplines',
            style: ComicTypography.title(fontSize: 18),
          ),
          const SizedBox(height: 12),

          // Grid of Subjects
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppConstants.subjects.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final subject = AppConstants.subjects[index];
              return GestureDetector(
                onTap: () => context.go('/create'),
                child: ComicPanel(
                  backgroundColor: ComicColors.cardBackground,
                  padding: const EdgeInsets.all(12),
                  borderRadius: 16,
                  borderColor: subject.color.withValues(alpha: 0.6),
                  shadowOffset: const Offset(3, 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: subject.color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: subject.color, width: 1.5),
                            ),
                            child: Icon(subject.icon, color: subject.color, size: 20),
                          ),
                          BadgeChip.category(
                            name: '${subject.storiesCount} comics',
                            color: subject.color,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.title,
                            style: ComicTypography.title(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subject.subtitle,
                            style: ComicTypography.caption(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
