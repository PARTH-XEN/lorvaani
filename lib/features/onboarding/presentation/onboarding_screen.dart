import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/comic_speech_bubble.dart';
import '../../../core/widgets/dimension_flip_logo.dart';
import '../../../core/widgets/halftone_container.dart';

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String comicBadge;
  final String speechBubbleText;
  final IconData icon;
  final Color accentColor;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.comicBadge,
    required this.speechBubbleText,
    required this.icon,
    required this.accentColor,
  });
}

/// 3-Screen Onboarding Experience for Lorvani
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Turn Boring Notes Into Stories',
      subtitle:
          'Paste study notes, scan textbook pages, or upload PDFs. Lorvani transforms raw facts into illustrated comic adventures!',
      comicBadge: 'EPISODE 01: THE AWAKENING',
      speechBubbleText: 'Wait, mitochondria is an actual powerhouse superhero?!',
      icon: Icons.auto_stories_rounded,
      accentColor: ComicColors.comicPurple,
    ),
    OnboardingSlide(
      title: 'Explore Comic Panels & Analogies',
      subtitle:
          'Grasp complex scientific theories, history, and math through visual graphic novel panels and real-world analogies.',
      comicBadge: 'EPISODE 02: DEEP DIVE',
      speechBubbleText: 'Gravity is like a bowling ball on a cosmic trampoline!',
      icon: Icons.view_carousel_rounded,
      accentColor: ComicColors.comicPink,
    ),
    OnboardingSlide(
      title: 'Learn, Play Quizzes & Remember',
      subtitle:
          'Test your mastery with interactive comic trivia, earn learning streaks, and build your personal visual library.',
      comicBadge: 'EPISODE 03: LEVEL UP',
      speechBubbleText: 'Boom! 100% quiz score and 5-day learning streak!',
      icon: Icons.military_tech_rounded,
      accentColor: ComicColors.vibrantOrange,
    ),
  ];

  void _finishOnboarding() {
    context.go('/home');
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Dimension Flip Logo & Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const DimensionFlipLogo(
                    variant: DimensionFlipVariant.primary,
                    size: 32,
                  ),
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: ComicColors.textSecondary,
                      ),
                      child: Text(
                        'Skip',
                        style: ComicTypography.bodyMedium(
                          fontSize: 14,
                          color: ComicColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _buildSlideContent(slide);
                },
              ),
            ),

            // Bottom Controls (Indicators & Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentPage == index ? 28 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? ComicColors.comicPink
                              : ComicColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: ComicColors.comicBorder,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  ComicButton(
                    text: _currentPage == _slides.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    icon: _currentPage == _slides.length - 1
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                    variant: _currentPage == _slides.length - 1
                        ? ComicButtonVariant.gradient
                        : ComicButtonVariant.primary,
                    fullWidth: true,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideContent(OnboardingSlide slide) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustrated Comic Card Hero
            ComicPanel(
              backgroundColor: ComicColors.cardBackground,
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: HalftoneContainer(
                backgroundColor: ComicColors.surfaceLight,
                dotColor: slide.accentColor.withValues(alpha: 0.15),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge on top of illustration
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: slide.accentColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: ComicColors.comicBorder, width: 1.5),
                        ),
                        child: Text(
                          slide.comicBadge,
                          style: ComicTypography.comicDisplay(
                            fontSize: 12,
                            color: ComicColors.softWhite,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Central Icon Graphic with glow
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: slide.accentColor.withValues(alpha: 0.2),
                          border: Border.all(color: slide.accentColor, width: 2),
                        ),
                        child: Icon(
                          slide.icon,
                          size: 44,
                          color: slide.accentColor,
                        ),
                      ).animate().scale(
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),

                      const Spacer(),

                      // Interactive Speech Bubble
                      ComicSpeechBubble(
                        backgroundColor: ComicColors.softWhite,
                        tailDirection: BubbleTailDirection.bottomLeft,
                        child: Text(
                          slide.speechBubbleText,
                          style: ComicTypography.narration(
                            fontSize: 12,
                            color: ComicColors.deepCharcoal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              slide.title,
              style: ComicTypography.heading(
                fontSize: 22,
                color: ComicColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Subtitle / Description
            Text(
              slide.subtitle,
              style: ComicTypography.body(
                fontSize: 13,
                color: ComicColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
