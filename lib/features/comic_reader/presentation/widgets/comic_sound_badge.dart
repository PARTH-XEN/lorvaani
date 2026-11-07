import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';

/// Expressive comic sound effect badge ("ZAP!", "AHA!", "BOOM!", "FOCUS!")
class ComicSoundBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double angle;
  final double fontSize;

  const ComicSoundBadge({
    super.key,
    required this.text,
    this.backgroundColor = ComicColors.electricYellow,
    this.textColor = Colors.black,
    this.angle = -0.08, // Subtle comic tilt
    this.fontSize = 18,
  });

  /// Factory resolving sound badges intelligently from panel visual cues
  factory ComicSoundBadge.fromVisualCue(String cue, int panelNumber) {
    final lower = cue.toLowerCase();
    if (lower.contains('photon') || lower.contains('light') || lower.contains('zap') || lower.contains('sun')) {
      return ComicSoundBadge(
        text: 'ZAP!',
        backgroundColor: ComicColors.electricYellow,
        angle: (panelNumber % 2 == 0) ? 0.08 : -0.08,
      );
    } else if (lower.contains('reaction') || lower.contains('energy') || lower.contains('split')) {
      return ComicSoundBadge(
        text: 'BOOM!',
        backgroundColor: ComicColors.vibrantOrange,
        angle: -0.1,
      );
    } else if (lower.contains('discover') || lower.contains('look') || lower.contains('notice')) {
      return ComicSoundBadge(
        text: 'AHA!',
        backgroundColor: ComicColors.skyCyan,
        angle: 0.08,
      );
    } else if (lower.contains('cell') || lower.contains('divide') || lower.contains('grow')) {
      return ComicSoundBadge(
        text: 'EUREKA!',
        backgroundColor: ComicColors.comicPink,
        angle: -0.06,
      );
    } else {
      final defaultWords = ['FOCUS!', 'ACTION!', 'DISCOVERY!', 'WOW!'];
      final word = defaultWords[panelNumber % defaultWords.length];
      return ComicSoundBadge(
        text: word,
        backgroundColor: ComicColors.electricYellow,
        angle: -0.07,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle * math.pi,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2.5, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          text,
          style: ComicTypography.comicDisplay(
            fontSize: fontSize,
            color: textColor,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

