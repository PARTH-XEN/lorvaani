import 'package:flutter/material.dart';
import '../theme/comic_colors.dart';

/// Halftone pattern painter creating authentic comic screentone dots
class HalftonePainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  const HalftonePainter({
    this.dotColor = const Color(0x1AFFFFFF),
    this.spacing = 10.0,
    this.dotRadius = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += spacing) {
      final double xOffset = ((y / spacing).round() % 2 == 0) ? 0 : spacing / 2;
      for (double x = xOffset; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HalftonePainter oldDelegate) {
    return oldDelegate.dotColor != dotColor ||
        oldDelegate.spacing != spacing ||
        oldDelegate.dotRadius != dotRadius;
  }
}

/// A container decorated with a comic-style halftone overlay
class HalftoneContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color dotColor;
  final double spacing;
  final double dotRadius;
  final BorderRadius? borderRadius;

  const HalftoneContainer({
    super.key,
    required this.child,
    this.backgroundColor = ComicColors.cardBackground,
    this.dotColor = const Color(0x14FFFFFF),
    this.spacing = 10.0,
    this.dotRadius = 1.4,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: HalftonePainter(
                  dotColor: dotColor,
                  spacing: spacing,
                  dotRadius: dotRadius,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

