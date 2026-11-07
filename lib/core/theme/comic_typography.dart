import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'comic_colors.dart';

/// Lorvani Official Typography - Comic Universe Design System
class ComicTypography {
  ComicTypography._();

  // Expressive comic display font (for punchy headers, sound effects, badges)
  static TextStyle comicDisplay({
    double fontSize = 32,
    Color color = ComicColors.textPrimary,
    double letterSpacing = 1.2,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.bangers(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
    );
  }

  // Major headings (clean, rounded, modern)
  static TextStyle heading({
    double fontSize = 24,
    Color color = ComicColors.textPrimary,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }

  // Subheadings and Section Titles
  static TextStyle title({
    double fontSize = 18,
    Color color = ComicColors.textPrimary,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  // Body text for high readability and educational explanations
  static TextStyle body({
    double fontSize = 14,
    Color color = ComicColors.textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.5,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }

  // Body bold/medium
  static TextStyle bodyMedium({
    double fontSize = 14,
    Color color = ComicColors.textPrimary,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.5,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }

  // Caption & Taglines
  static TextStyle caption({
    double fontSize = 12,
    Color color = ComicColors.textSecondary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  // Narration Box Text (classic comic italic narration)
  static TextStyle narration({
    double fontSize = 13,
    Color color = ComicColors.deepCharcoal,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: FontStyle.italic,
      height: 1.4,
    );
  }
}

