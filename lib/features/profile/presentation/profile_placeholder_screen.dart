import 'package:flutter/material.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/dimension_flip_logo.dart';

/// User Profile and Learning Stats - Milestone 8 Target
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          'SCHOLAR PROFILE',
          style: ComicTypography.comicDisplay(fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Banner Card
          ComicPanel(
            backgroundColor: ComicColors.cardBackground,
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: ComicColors.dimensionGradient,
                    border: Border.all(color: ComicColors.comicBorder, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.bolt_rounded, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nova Scholar',
                        style: ComicTypography.heading(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          BadgeChip.level(level: 'Level 4 Explorer'),
                          const SizedBox(width: 8),
                          BadgeChip.streak(days: 5),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stat Highlights
          Row(
            children: [
              Expanded(
                child: ComicPanel(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('12', style: ComicTypography.comicDisplay(fontSize: 24, color: ComicColors.skyCyan)),
                      Text('Stories Mastered', style: ComicTypography.caption(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ComicPanel(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('88%', style: ComicTypography.comicDisplay(fontSize: 24, color: ComicColors.vibrantOrange)),
                      Text('Quiz Accuracy', style: ComicTypography.caption(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ComicPanel(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('150', style: ComicTypography.comicDisplay(fontSize: 24, color: ComicColors.comicPink)),
                      Text('XP Points', style: ComicTypography.caption(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About Lorvani & Dimension Flip Branding
          ComicPanel(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const DimensionFlipLogo(
                      variant: DimensionFlipVariant.small,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'About Lorvani',
                      style: ComicTypography.title(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Powered by AI-driven comic book storytelling. Transforms complex academic concepts into memorable visual graphic novels.',
                  style: ComicTypography.body(fontSize: 12, color: ComicColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
