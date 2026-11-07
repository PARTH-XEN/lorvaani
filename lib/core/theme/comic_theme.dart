import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'comic_colors.dart';

/// Lorvani Official Material 3 Dark Theme
class ComicTheme {
  ComicTheme._();

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: ComicColors.comicPurple,
      onPrimary: ComicColors.softWhite,
      secondary: ComicColors.comicPink,
      onSecondary: ComicColors.softWhite,
      tertiary: ComicColors.skyCyan,
      onTertiary: ComicColors.deepCharcoal,
      error: const Color(0xFFFF5252),
      onError: ComicColors.softWhite,
      surface: ComicColors.cardBackground,
      onSurface: ComicColors.textPrimary,
      surfaceContainerHighest: ComicColors.surfaceLight,
      outline: ComicColors.comicBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ComicColors.deepCharcoal,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: ComicColors.textPrimary,
        displayColor: ComicColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: ComicColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: ComicColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ComicColors.comicBorder, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ComicColors.comicPurple,
          foregroundColor: ComicColors.softWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: ComicColors.comicBorder, width: 2),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ComicColors.cardBackground,
        contentTextStyle: GoogleFonts.inter(color: ComicColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ComicColors.comicBorder, width: 2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
