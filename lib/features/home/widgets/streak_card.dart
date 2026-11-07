import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_panel.dart';

/// Interactive Learning Streak Card
class StreakCard extends StatelessWidget {
  final int streakDays;
  final List<bool>? activeDays;

  const StreakCard({
    super.key,
    this.streakDays = 1,
    this.activeDays,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // Default to day 1 (today's weekday index active) if not supplied
    final effectiveActiveDays = activeDays ??
        List.generate(7, (index) => index == (DateTime.now().weekday - 1));

    final isFirstDay = streakDays <= 1;

    return ComicPanel(
      backgroundColor: const Color(0xFF261D22),
      borderColor: ComicColors.vibrantOrange.withValues(alpha: 0.6),
      borderRadius: 16,
      borderWidth: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shadowOffset: const Offset(3, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4A2511),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: ComicColors.vibrantOrange,
                  size: 22,
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                    duration: 900.ms,
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.15, 1.15),
                  ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$streakDays Day Streak!',
                        style: ComicTypography.title(
                          fontSize: 15,
                          color: ComicColors.vibrantOrange,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isFirstDay ? '🚀 Welcome!' : '🔥 On Fire',
                        style: ComicTypography.caption(
                          fontSize: 11,
                          color: ComicColors.electricYellow,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isFirstDay
                        ? 'Great start! Create your first comic today'
                        : 'Study tomorrow to keep the flame alive',
                    style: ComicTypography.caption(
                      fontSize: 11,
                      color: ComicColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day bubbles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              final isActive = index < effectiveActiveDays.length &&
                  effectiveActiveDays[index];
              return Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isActive
                      ? ComicColors.vibrantOrange
                      : ComicColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? ComicColors.electricYellow
                        : ComicColors.comicBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? ComicColors.deepCharcoal
                          : ComicColors.textMuted,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
