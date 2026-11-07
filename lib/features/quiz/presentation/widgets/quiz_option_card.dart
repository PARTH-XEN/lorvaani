import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';

/// Tactile multiple-choice option card with animated state-driven feedback
class QuizOptionCard extends StatelessWidget {
  final String optionLetter;
  final String optionText;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final VoidCallback? onTap;

  const QuizOptionCard({
    super.key,
    required this.optionLetter,
    required this.optionText,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = ComicColors.cardBackground;
    Color borderColor = ComicColors.comicPurple.withValues(alpha: 0.5);
    Color textColor = ComicColors.softWhite;
    Color badgeColor = ComicColors.deepCharcoal;
    Color badgeTextColor = ComicColors.skyCyan;
    Widget? statusIcon;

    if (isAnswered) {
      if (isSelected && isCorrect) {
        // User picked correct answer!
        backgroundColor = const Color(0xFF10B981); // Emerald green
        borderColor = Colors.black;
        textColor = Colors.black;
        badgeColor = Colors.black;
        badgeTextColor = const Color(0xFF10B981);
        statusIcon = const Icon(Icons.check_circle_rounded, color: Colors.black, size: 22);
      } else if (isSelected && !isCorrect) {
        // User picked wrong answer!
        backgroundColor = const Color(0xFFEF4444); // Crimson red
        borderColor = Colors.black;
        textColor = Colors.white;
        badgeColor = Colors.black;
        badgeTextColor = const Color(0xFFEF4444);
        statusIcon = const Icon(Icons.cancel_rounded, color: Colors.white, size: 22);
      } else if (!isSelected && isCorrect) {
        // Reveal the correct answer
        backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.15);
        borderColor = const Color(0xFF10B981);
        textColor = ComicColors.softWhite;
        badgeColor = const Color(0xFF10B981);
        badgeTextColor = Colors.black;
        statusIcon = const Icon(Icons.check_circle_outline_rounded,
            color: Color(0xFF10B981), size: 22);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  offset: const Offset(2, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Option Letter Pill
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Text(
                    optionLetter,
                    style: ComicTypography.title(
                      fontSize: 14,
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Option Content
                Expanded(
                  child: Text(
                    optionText,
                    style: ComicTypography.body(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),

                // Right Status Icon
                if (statusIcon != null) ...[
                  const SizedBox(width: 8),
                  statusIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

