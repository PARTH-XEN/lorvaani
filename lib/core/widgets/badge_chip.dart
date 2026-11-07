import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/comic_colors.dart';

/// Reusable Comic Pill Badge for levels, streaks, tags, and progress indicators
class BadgeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const BadgeChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = ComicColors.surfaceLight,
    this.textColor = ComicColors.textPrimary,
    this.borderColor = ComicColors.comicBorder,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  factory BadgeChip.streak({required int days}) {
    return BadgeChip(
      label: '$days Day Streak',
      icon: Icons.local_fire_department_rounded,
      backgroundColor: const Color(0xFF332014),
      textColor: ComicColors.vibrantOrange,
      borderColor: ComicColors.vibrantOrange.withValues(alpha: 0.6),
    );
  }

  factory BadgeChip.level({required String level}) {
    return BadgeChip(
      label: level.toUpperCase(),
      backgroundColor: ComicColors.comicPurple.withValues(alpha: 0.2),
      textColor: ComicColors.comicPink,
      borderColor: ComicColors.comicPurple.withValues(alpha: 0.4),
      fontSize: 10,
    );
  }

  factory BadgeChip.category({required String name, required Color color}) {
    return BadgeChip(
      label: name,
      backgroundColor: color.withValues(alpha: 0.18),
      textColor: color,
      borderColor: color.withValues(alpha: 0.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 3, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

