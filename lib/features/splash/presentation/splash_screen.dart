import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/widgets/dimension_flip_logo.dart';
import '../../../core/widgets/halftone_container.dart';

/// Splash Screen featuring the official Dimension Flip Branding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      body: HalftoneContainer(
        backgroundColor: ComicColors.deepCharcoal,
        dotColor: ComicColors.comicPurple.withValues(alpha: 0.08),
        spacing: 14,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DimensionFlipLogo(
                variant: DimensionFlipVariant.splash,
                size: 90,
                showTagline: true,
              )
                  .animate()
                  .scale(
                    duration: 650.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.0, 1.0),
                  )
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 36),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: ComicColors.dimensionGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate().shimmer(duration: 1200.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

