import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/comic_colors.dart';

/// Supported logo variations per Lorvani Brand Specification
enum DimensionFlipVariant {
  primary, // Symbol + "lorvani" wordmark horizontal
  appIcon, // Symbol only (optimized for square/squircle containers)
  splash, // Large Symbol centered + wordmark + tagline underneath
  small, // Compact simplified symbol for headers/app bars
  monochrome, // Single-color variant for high contrast or monochrome contexts
}

/// Official Lorvani Brand Logo Widget - DIMENSION FLIP
/// Implements custom vector rendering via [DimensionFlipSymbolPainter].
class DimensionFlipLogo extends StatelessWidget {
  final DimensionFlipVariant variant;
  final double size;
  final Color? monochromeColor;
  final bool showTagline;

  const DimensionFlipLogo({
    super.key,
    this.variant = DimensionFlipVariant.primary,
    this.size = 40,
    this.monochromeColor,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case DimensionFlipVariant.appIcon:
        return _buildAppIcon();
      case DimensionFlipVariant.splash:
        return _buildSplash();
      case DimensionFlipVariant.small:
        return _buildSmallSymbol();
      case DimensionFlipVariant.monochrome:
        return _buildMonochrome();
      case DimensionFlipVariant.primary:
        return _buildPrimary();
    }
  }

  Widget _buildPrimary() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSymbol(size),
        SizedBox(width: size * 0.28),
        _buildWordmark(fontSize: size * 0.72),
      ],
    );
  }

  Widget _buildSmallSymbol() {
    return _buildSymbol(size);
  }

  Widget _buildAppIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ComicColors.deepCharcoal,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(
          color: ComicColors.comicPurple.withValues(alpha: 0.5),
          width: size * 0.03,
        ),
        boxShadow: [
          BoxShadow(
            color: ComicColors.comicPurple.withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.16),
      child: _buildSymbol(size * 0.68),
    );
  }

  Widget _buildSplash() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size * 1.2,
          height: size * 1.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ComicColors.comicPurple.withValues(alpha: 0.4),
                blurRadius: size * 0.5,
                spreadRadius: size * 0.05,
              ),
            ],
          ),
          child: _buildSymbol(size * 1.2),
        ),
        SizedBox(height: size * 0.3),
        _buildWordmark(fontSize: size * 0.48),
        if (showTagline) ...[
          SizedBox(height: size * 0.08),
          Text(
            'turn study into stories',
            style: GoogleFonts.poppins(
              fontSize: size * 0.14,
              fontWeight: FontWeight.w500,
              color: ComicColors.skyCyan,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMonochrome() {
    final color = monochromeColor ?? ComicColors.softWhite;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: DimensionFlipSymbolPainter(
              isMonochrome: true,
              monochromeColor: color,
            ),
          ),
        ),
        SizedBox(width: size * 0.28),
        _buildWordmark(fontSize: size * 0.72, overrideColor: color),
      ],
    );
  }

  Widget _buildSymbol(double dimension) {
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CustomPaint(
        painter: DimensionFlipSymbolPainter(
          isMonochrome: false,
        ),
      ),
    );
  }

  Widget _buildWordmark({required double fontSize, Color? overrideColor}) {
    // Custom modern rounded lowercase wordmark with distinctive branding
    return RichText(
      text: TextSpan(
        style: GoogleFonts.sora(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: overrideColor ?? ComicColors.softWhite,
        ),
        children: [
          const TextSpan(text: 'lor'),
          TextSpan(
            text: 'vani',
            style: TextStyle(
              color: overrideColor ?? ComicColors.comicPink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Vector Painter for the Dimension Flip Origami Geometric Portal
/// Represents a folded comic page turning in 3D into another dimension.
class DimensionFlipSymbolPainter extends CustomPainter {
  final bool isMonochrome;
  final Color? monochromeColor;

  const DimensionFlipSymbolPainter({
    this.isMonochrome = false,
    this.monochromeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Facet 1: The Base Folded Page (Dominant Purple #8054E9)
    final path1 = Path();
    path1.moveTo(w * 0.15, h * 0.78);
    path1.lineTo(w * 0.48, h * 0.94);
    path1.lineTo(w * 0.52, h * 0.46);
    path1.lineTo(w * 0.15, h * 0.32);
    path1.close();

    // Facet 2: The 3D Dimensional Top Turn / Portal Fold (Comic Pink #F46CA8)
    final path2 = Path();
    path2.moveTo(w * 0.15, h * 0.32);
    path2.lineTo(w * 0.52, h * 0.46);
    path2.lineTo(w * 0.85, h * 0.22);
    path2.lineTo(w * 0.48, h * 0.08);
    path2.close();

    // Facet 3: The Dimensional Under-Fold / Window into Knowledge (Sky Cyan #48C9E8)
    final path3 = Path();
    path3.moveTo(w * 0.52, h * 0.46);
    path3.lineTo(w * 0.85, h * 0.22);
    path3.lineTo(w * 0.85, h * 0.68);
    path3.lineTo(w * 0.48, h * 0.94);
    path3.close();

    // Facet 4: Geometric Origami Dynamic Flap (Accent fold)
    final path4 = Path();
    path4.moveTo(w * 0.35, h * 0.22);
    path4.lineTo(w * 0.68, h * 0.34);
    path4.lineTo(w * 0.60, h * 0.58);
    path4.lineTo(w * 0.28, h * 0.44);
    path4.close();

    if (isMonochrome) {
      final baseColor = monochromeColor ?? ComicColors.softWhite;
      final p1 = Paint()
        ..color = baseColor.withValues(alpha: 0.95)
        ..style = PaintingStyle.fill;
      final p2 = Paint()
        ..color = baseColor.withValues(alpha: 0.70)
        ..style = PaintingStyle.fill;
      final p3 = Paint()
        ..color = baseColor.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      final p4 = Paint()
        ..color = baseColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path1, p1);
      canvas.drawPath(path3, p3);
      canvas.drawPath(path2, p2);
      canvas.drawPath(path4, p4);

      final linePaint = Paint()
        ..color = ComicColors.deepCharcoal
        ..strokeWidth = w * 0.03
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path1, linePaint);
      canvas.drawPath(path2, linePaint);
      canvas.drawPath(path3, linePaint);
    } else {
      // Shaded Gradients per Part 3 Logo Specification
      // Dominant Purple to Deep Violet
      final paint1 = Paint()
        ..shader = const LinearGradient(
          colors: [ComicColors.comicPurple, Color(0xFF5B30BC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h));

      // Comic Pink to Warm Magenta Highlight
      final paint2 = Paint()
        ..shader = const LinearGradient(
          colors: [ComicColors.comicPink, Color(0xFFFF85B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, w, h));

      // Sky Cyan into Dimensional Teal
      final paint3 = Paint()
        ..shader = const LinearGradient(
          colors: [ComicColors.skyCyan, Color(0xFF2CB1D3)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ).createShader(Rect.fromLTWH(0, 0, w, h));

      // Center origami intersection fold (soft glow)
      final paint4 = Paint()
        ..shader = LinearGradient(
          colors: [
            ComicColors.softWhite.withValues(alpha: 0.3),
            ComicColors.comicPink.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, w, h));

      // Draw dimensional surfaces
      canvas.drawPath(path1, paint1);
      canvas.drawPath(path3, paint3);
      canvas.drawPath(path2, paint2);
      canvas.drawPath(path4, paint4);

      // Fine crisp comic vector contour edges
      final borderPaint = Paint()
        ..color = ComicColors.deepCharcoal.withValues(alpha: 0.6)
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path1, borderPaint);
      canvas.drawPath(path2, borderPaint);
      canvas.drawPath(path3, borderPaint);

      // Specular highlight edge on top origami ridge
      final highlightPaint = Paint()
        ..color = ComicColors.softWhite.withValues(alpha: 0.6)
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final highlightPath = Path()
        ..moveTo(w * 0.16, h * 0.32)
        ..lineTo(w * 0.52, h * 0.46)
        ..lineTo(w * 0.84, h * 0.22);
      canvas.drawPath(highlightPath, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DimensionFlipSymbolPainter oldDelegate) {
    return oldDelegate.isMonochrome != isMonochrome ||
        oldDelegate.monochromeColor != monochromeColor;
  }
}
