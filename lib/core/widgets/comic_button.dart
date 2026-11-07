import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/comic_colors.dart';

enum ComicButtonVariant {
  primary, // Comic Purple
  secondary, // Comic Pink
  accent, // Electric Yellow with dark text
  gradient, // Dimension Flip Gradient
  dark, // Surface light
}

/// Tactile Comic Button with 3D mechanical press animation
class ComicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ComicButtonVariant variant;
  final bool fullWidth;
  final double height;
  final double fontSize;
  final bool isLoading;

  const ComicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = ComicButtonVariant.primary,
    this.fullWidth = false,
    this.height = 52,
    this.fontSize = 16,
    this.isLoading = false,
  });

  @override
  State<ComicButton> createState() => _ComicButtonState();
}

class _ComicButtonState extends State<ComicButton> {
  bool _isPressed = false;

  Color _getBackgroundColor() {
    switch (widget.variant) {
      case ComicButtonVariant.primary:
        return ComicColors.comicPurple;
      case ComicButtonVariant.secondary:
        return ComicColors.comicPink;
      case ComicButtonVariant.accent:
        return ComicColors.electricYellow;
      case ComicButtonVariant.dark:
        return ComicColors.surfaceLight;
      case ComicButtonVariant.gradient:
        return ComicColors.comicPurple;
    }
  }

  Color _getTextColor() {
    switch (widget.variant) {
      case ComicButtonVariant.accent:
        return ComicColors.deepCharcoal;
      default:
        return ComicColors.softWhite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      height: widget.height,
      transform: Matrix4.translationValues(
        _isPressed ? 2.0 : 0.0,
        _isPressed ? 2.0 : 0.0,
        0.0,
      ),
      decoration: BoxDecoration(
        color: widget.variant == ComicButtonVariant.gradient ? null : bgColor,
        gradient: widget.variant == ComicButtonVariant.gradient
            ? ComicColors.dimensionGradient
            : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ComicColors.comicBorder, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0E15),
            offset: _isPressed ? const Offset(1, 1) : const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisSize:
                      widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: textColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: GoogleFonts.poppins(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );

    if (!enabled) {
      return Opacity(
        opacity: 0.55,
        child: content,
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: content,
    );
  }
}

