import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/ai/ai_config_service.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../core/services/streak/streak_service.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/ai_settings_dialog.dart';
import '../../../core/widgets/audio_settings_sheet.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/dimension_flip_logo.dart';
import '../../library/presentation/controllers/library_controller.dart';

/// User Profile, Account Management, Audio Settings, and Scholar Dashboard
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakData = ref.watch(streakDataProvider);
    final libraryState = ref.watch(libraryControllerProvider);
    final aiConfig = ref.watch(aiConfigServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    final storyCount = libraryState.stories.length;
    final isLoggedIn = currentUser != null;

    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          'EXPLORER PROFILE',
          style: ComicTypography.comicDisplay(fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Banner Card with Dynamic Authentication State
          ComicPanel(
            backgroundColor: ComicColors.cardBackground,
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: ComicColors.dimensionGradient,
                        border: Border.all(
                            color: ComicColors.comicBorder, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          '⚡',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn
                                ? currentUser.name
                                : 'Guest Explorer',
                            style: ComicTypography.heading(fontSize: 18),
                          ),
                          if (isLoggedIn) ...[
                            const SizedBox(height: 2),
                            Text(
                              currentUser.email,
                              style: ComicTypography.caption(
                                fontSize: 12,
                                color: ComicColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              BadgeChip.streak(days: streakData.streakDays),
                              BadgeChip.level(
                                level: isLoggedIn
                                    ? 'Unlimited Scholar'
                                    : 'Guest Trial (${authService.guestStoriesCount}/1 Used)',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Auth Action CTA
                if (isLoggedIn)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded,
                        size: 16, color: ComicColors.comicPink),
                    label: Text(
                      'Sign Out',
                      style: ComicTypography.caption(
                        color: ComicColors.comicPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: ComicColors.comicPink, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () async {
                      await authService.signOut();
                      ref.read(currentUserProvider.notifier).setUser(null);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Signed out successfully.'),
                            backgroundColor: ComicColors.cardBackground,
                          ),
                        );
                      }
                    },
                  )
                else
                  ComicButton(
                    text: 'Sign In or Create Account',
                    icon: Icons.login_rounded,
                    variant: ComicButtonVariant.gradient,
                    onPressed: () async {
                      final authed = await context.push<bool>('/auth');
                      if (authed == true) {
                        ref.read(currentUserProvider.notifier).setUser(
                              authService.getCurrentUser(),
                            );
                      }
                    },
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
                      Text(
                        '$storyCount',
                        style: ComicTypography.comicDisplay(
                          fontSize: 24,
                          color: ComicColors.skyCyan,
                        ),
                      ),
                      Text(
                        'Stories Saved',
                        style: ComicTypography.caption(fontSize: 11),
                      ),
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
                      Text(
                        '${streakData.streakDays}',
                        style: ComicTypography.comicDisplay(
                          fontSize: 24,
                          color: ComicColors.vibrantOrange,
                        ),
                      ),
                      Text(
                        'Day Streak',
                        style: ComicTypography.caption(fontSize: 11),
                      ),
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
                      Text(
                        aiConfig.hasLiveKeyConfigured ? 'Groq' : 'Mock',
                        style: ComicTypography.comicDisplay(
                          fontSize: 24,
                          color: aiConfig.hasLiveKeyConfigured
                              ? ComicColors.electricYellow
                              : ComicColors.comicPink,
                        ),
                      ),
                      Text(
                        'AI Engine',
                        style: ComicTypography.caption(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Voice & Audio Settings Tile
          GestureDetector(
            onTap: () => AudioSettingsSheet.show(context),
            child: ComicPanel(
              backgroundColor: ComicColors.cardBackground,
              borderColor: ComicColors.vibrantOrange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ComicColors.vibrantOrange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: ComicColors.vibrantOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voice & Audio Settings',
                          style: ComicTypography.title(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '3 Voice Personas (Nova, Sage, Spark) & Volume Adjuster',
                          style: ComicTypography.caption(
                            fontSize: 12,
                            color: ComicColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: ComicColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // AI Engine Configuration Tile
          GestureDetector(
            onTap: () => AiSettingsDialog.show(context),
            child: ComicPanel(
              backgroundColor: ComicColors.cardBackground,
              borderColor: aiConfig.hasLiveKeyConfigured
                  ? ComicColors.skyCyan
                  : ComicColors.comicPurple,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ComicColors.comicPurple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      aiConfig.hasLiveKeyConfigured
                          ? Icons.auto_awesome_rounded
                          : Icons.vpn_key_rounded,
                      color: aiConfig.hasLiveKeyConfigured
                          ? ComicColors.skyCyan
                          : ComicColors.electricYellow,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Story Engine Settings',
                          style: ComicTypography.title(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          aiConfig.activeProviderName,
                          style: ComicTypography.caption(
                            fontSize: 12,
                            color: ComicColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: ComicColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // About Lorvani & Dimension Flip Branding
          ComicPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const DimensionFlipLogo(
                      variant: DimensionFlipVariant.small,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'About Lorvani',
                      style: ComicTypography.title(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Lorvani turns dry textbooks, study notes, and research PDFs into an illustrated comic book universe.',
                  style: ComicTypography.body(
                    fontSize: 13,
                    color: ComicColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '• 1 Free Trial Story: Explore the app freely as a guest.\n'
                  '• Unlimited Scholar Access: Free registration unlocks limitless comics.\n'
                  '• Multilingual Voices: Auto-reads in Hindi, Spanish, French, German, or English.\n'
                  '• Graphic Novel PDF: Export any story to a multi-page printable comic.',
                  style: ComicTypography.caption(
                    fontSize: 11,
                    color: ComicColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
