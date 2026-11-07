import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth/auth_service.dart';
import '../theme/comic_colors.dart';
import '../theme/comic_typography.dart';
import 'comic_button.dart';
import 'comic_panel.dart';
import 'dimension_flip_logo.dart';

/// Modal dialog presented when a guest user has used their 1 free story
class ComicTrialGateDialog extends StatelessWidget {
  const ComicTrialGateDialog({super.key});

  /// Checks if generation is permitted under the 1-story guest trial policy.
  /// If guest limit reached, shows this dialog and returns whether the user authenticated.
  static Future<bool> checkAndEnforceTrial(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final authService = ref.read(authServiceProvider);
    if (authService.canGenerateStory) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => const ComicTrialGateDialog(),
    );

    // Re-check authentication state in case user signed in/registered
    if (ref.read(authServiceProvider).canGenerateStory) {
      return true;
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ComicPanel(
        backgroundColor: ComicColors.cardBackground,
        borderColor: ComicColors.comicPink,
        borderWidth: 2.5,
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Center Logo
            const Center(
              child: DimensionFlipLogo(
                variant: DimensionFlipVariant.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),

            // Heading
            Text(
              'FREE TRIAL COMPLETE! 🎉',
              textAlign: TextAlign.center,
              style: ComicTypography.comicDisplay(
                fontSize: 20,
                color: ComicColors.electricYellow,
              ),
            ),
            const SizedBox(height: 10),

            // Explanation
            Text(
              'You\'ve created your 1 free guest comic! Sign in or create an account in seconds to unlock unlimited AI comic generation, custom visual genres, and PDF exports.',
              textAlign: TextAlign.center,
              style: ComicTypography.body(
                fontSize: 13,
                color: ComicColors.softWhite,
              ),
            ),
            const SizedBox(height: 20),

            // Benefits checklist
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: ComicColors.deepCharcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ComicColors.comicBorder, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _benefitRow('Unlimited AI comic book creation'),
                  const SizedBox(height: 6),
                  _benefitRow('Multilingual stories in Hindi, Spanish & more'),
                  const SizedBox(height: 6),
                  _benefitRow('High-res printable Graphic Novel PDF export'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Actions
            ComicButton(
              text: 'Sign In / Create Account',
              icon: Icons.login_rounded,
              variant: ComicButtonVariant.gradient,
              onPressed: () async {
                final authed = await context.push<bool>('/auth');
                if (context.mounted) {
                  Navigator.of(context).pop(authed == true);
                }
              },
            ),
            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Maybe Later',
                  style: ComicTypography.caption(
                    fontSize: 13,
                    color: ComicColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded,
            size: 16, color: ComicColors.skyCyan),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: ComicTypography.caption(
              fontSize: 11,
              color: ComicColors.softWhite,
            ),
          ),
        ),
      ],
    );
  }
}

