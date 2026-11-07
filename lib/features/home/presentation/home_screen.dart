import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/ai/ai_config_service.dart';
import '../../../core/services/streak/streak_service.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/ai_settings_dialog.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/dimension_flip_logo.dart';
import '../../../core/widgets/halftone_container.dart';
import '../widgets/concept_of_the_day_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/subject_card.dart';

/// Lorvani Home Screen: The Comic Universe Dashboard
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Record today's study activity on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(streakServiceProvider).recordActivityToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final streakData = ref.watch(streakDataProvider);
    final aiConfig = ref.watch(aiConfigServiceProvider);

    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar with Dimension Flip Logo, AI Settings & Profile Avatar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: DimensionFlipLogo(
                        variant: DimensionFlipVariant.primary,
                        size: 32,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // AI Model / Key Configuration Button
                        GestureDetector(
                          onTap: () => AiSettingsDialog.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: ComicColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: aiConfig.hasLiveKeyConfigured
                                    ? ComicColors.skyCyan
                                    : ComicColors.comicPurple,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  aiConfig.hasLiveKeyConfigured
                                      ? Icons.auto_awesome_rounded
                                      : Icons.vpn_key_rounded,
                                  color: aiConfig.hasLiveKeyConfigured
                                      ? ComicColors.skyCyan
                                      : ComicColors.electricYellow,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  aiConfig.hasLiveKeyConfigured
                                      ? 'Groq AI'
                                      : 'AI Key',
                                  style: ComicTypography.caption(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: ComicColors.softWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Profile Avatar
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: ComicColors.dimensionGradient,
                              border: Border.all(
                                  color: ComicColors.comicBorder, width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                '⚡',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Greeting & Intro Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, Explorer!',
                      style: ComicTypography.heading(
                        fontSize: 22,
                        color: ComicColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ready to discover today\'s illustrated learning issue?',
                      style: ComicTypography.body(
                        fontSize: 13,
                        color: ComicColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Learning Streak (Dynamic & Date-based)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: StreakCard(
                  streakDays: streakData.streakDays,
                  activeDays: streakData.activeDaysOfWeek,
                ),
              ),
            ),

            // Hero "Create Your Story" Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _buildCreateStoryHero(context),
              ),
            ),

            // Concept of the Day Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DAILY SPOTLIGHT',
                          style: ComicTypography.comicDisplay(
                            fontSize: 18,
                            color: ComicColors.electricYellow,
                          ),
                        ),
                        BadgeChip.level(level: 'Recommended'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConceptOfTheDayCard(
                      onTap: () {
                        context.push('/create');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Explore Subjects Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EXPLORE SUBJECTS',
                      style: ComicTypography.comicDisplay(
                        fontSize: 18,
                        color: ComicColors.skyCyan,
                      ),
                    ),
                    Text(
                      '8 Categories',
                      style: ComicTypography.caption(
                        color: ComicColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Subjects Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = AppConstants.subjects[index];
                    return SubjectCard(
                      subject: subject,
                      onTap: () {
                        context.push('/create');
                      },
                    );
                  },
                  childCount: AppConstants.subjects.length,
                ),
              ),
            ),

            // Bottom Spacing for shell bottom bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateStoryHero(BuildContext context) {
    return ComicPanel(
      backgroundColor: ComicColors.cardBackground,
      borderColor: ComicColors.comicPurple,
      borderWidth: 2.5,
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: HalftoneContainer(
        backgroundColor: ComicColors.cardBackground,
        dotColor: ComicColors.comicPurple.withValues(alpha: 0.12),
        dotRadius: 1.5,
        spacing: 14,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BadgeChip.category(
                    name: 'AI COMIC STUDIO',
                    color: ComicColors.comicPink,
                  ),
                  const Text(
                    'ISSUE #1',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: 14,
                      color: ComicColors.electricYellow,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Transform Your Notes Into Comics',
                style: ComicTypography.heading(
                  fontSize: 20,
                  color: ComicColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Turn difficult concepts, textbook pages or PDFs into exciting graphic novel adventures.',
                style: ComicTypography.body(
                  fontSize: 13,
                  color: ComicColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ComicButton(
                text: 'Create Your Story',
                icon: Icons.auto_stories_rounded,
                variant: ComicButtonVariant.primary,
                fullWidth: true,
                onPressed: () {
                  context.push('/create');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
