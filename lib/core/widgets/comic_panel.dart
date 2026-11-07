import 'package:flutter/material.dart';
import '../theme/comic_colors.dart';

/// Graphic Novel Styled Comic Panel Container
/// Features bold comic borders, tactile offset shadows, and responsive layouts.
class ComicPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final VoidCallback? onTap;

  const ComicPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor = ComicColors.cardBackground,
    this.borderColor = ComicColors.comicBorder,
    this.shadowColor = const Color(0xFF0A0910),
    this.borderWidth = 2.5,
    this.borderRadius = 16,
    this.shadowOffset = const Offset(4, 4),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: shadowOffset,
            blurRadius: 0, // Comic books use sharp flat shadows
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

