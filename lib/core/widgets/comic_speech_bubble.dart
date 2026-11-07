import 'package:flutter/material.dart';
import '../theme/comic_colors.dart';
import '../theme/comic_typography.dart';

enum BubbleTailDirection {
  bottomLeft,
  bottomRight,
  topLeft,
  topRight,
  none,
}

/// Authentic Comic Speech Bubble
class ComicSpeechBubble extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final BubbleTailDirection tailDirection;
  final EdgeInsetsGeometry padding;

  const ComicSpeechBubble({
    super.key,
    required this.child,
    this.backgroundColor = ComicColors.softWhite,
    this.borderColor = ComicColors.comicBorder,
    this.tailDirection = BubbleTailDirection.bottomLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubblePainter(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        tailDirection: tailDirection,
      ),
      child: Container(
        padding: padding,
        margin: EdgeInsets.only(
          bottom: tailDirection == BubbleTailDirection.bottomLeft ||
                  tailDirection == BubbleTailDirection.bottomRight
              ? 12
              : 0,
          top: tailDirection == BubbleTailDirection.topLeft ||
                  tailDirection == BubbleTailDirection.topRight
              ? 12
              : 0,
        ),
        child: child,
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final BubbleTailDirection tailDirection;

  _SpeechBubblePainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.tailDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const double radius = 14.0;
    const double tailHeight = 10.0;
    const double tailWidth = 12.0;

    double top = 0;
    double bottom = h;

    if (tailDirection == BubbleTailDirection.topLeft ||
        tailDirection == BubbleTailDirection.topRight) {
      top = tailHeight;
    } else if (tailDirection == BubbleTailDirection.bottomLeft ||
        tailDirection == BubbleTailDirection.bottomRight) {
      bottom = h - tailHeight;
    }

    final path = Path();
    // Body rectangle with rounded corners
    path.moveTo(radius, top);
    path.lineTo(w - radius, top);
    path.arcToPoint(Offset(w, top + radius), radius: const Radius.circular(radius));
    path.lineTo(w, bottom - radius);
    path.arcToPoint(Offset(w - radius, bottom), radius: const Radius.circular(radius));

    // Bottom edge + optional tail
    if (tailDirection == BubbleTailDirection.bottomLeft) {
      path.lineTo(w * 0.25 + tailWidth, bottom);
      path.lineTo(w * 0.18, h);
      path.lineTo(w * 0.25, bottom);
    } else if (tailDirection == BubbleTailDirection.bottomRight) {
      path.lineTo(w * 0.75 + tailWidth, bottom);
      path.lineTo(w * 0.82, h);
      path.lineTo(w * 0.75, bottom);
    }

    path.lineTo(radius, bottom);
    path.arcToPoint(Offset(0, bottom - radius), radius: const Radius.circular(radius));
    path.lineTo(0, top + radius);
    path.arcToPoint(Offset(radius, top), radius: const Radius.circular(radius));

    // Optional top tail
    if (tailDirection == BubbleTailDirection.topLeft) {
      path.moveTo(w * 0.25, top);
      path.lineTo(w * 0.18, 0);
      path.lineTo(w * 0.25 + tailWidth, top);
    }

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path.shift(const Offset(3, 3)), shadowPaint);

    // Background
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.tailDirection != tailDirection;
  }
}

/// Graphic Novel Narration Box
/// Traditional yellow or colored caption box with bold borders and italic styling.
class NarrationBox extends StatelessWidget {
  final String text;
  final String? narrator;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const NarrationBox({
    super.key,
    required this.text,
    this.narrator,
    this.backgroundColor = ComicColors.electricYellow,
    this.textColor = ComicColors.deepCharcoal,
    this.borderColor = ComicColors.comicBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (narrator != null) ...[
            Text(
              narrator!.toUpperCase(),
              style: ComicTypography.comicDisplay(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.8),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            text,
            style: ComicTypography.narration(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
