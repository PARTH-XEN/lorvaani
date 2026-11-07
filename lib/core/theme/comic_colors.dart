import 'package:flutter/material.dart';

/// Lorvani Official Color Palette - Comic Universe Design System
class ComicColors {
  ComicColors._();

  // Primary Palette
  static const Color deepCharcoal = Color(0xFF17151F);
  static const Color comicPurple = Color(0xFF8054E9);
  static const Color vibrantOrange = Color(0xFFFF914D);
  static const Color electricYellow = Color(0xFFFFD84D);
  static const Color skyCyan = Color(0xFF48C9E8);
  static const Color comicPink = Color(0xFFF46CA8);
  static const Color softWhite = Color(0xFFFFF9F1);
  static const Color cardBackground = Color(0xFF252230);

  // Surface & Elevation variants
  static const Color surfaceLight = Color(0xFF2E2A3C);
  static const Color surfaceMuted = Color(0xFF1F1C2A);
  static const Color comicBorder = Color(0xFF0F0E15);
  static const Color comicShadow = Color(0x99000000);

  // Text variations
  static const Color textPrimary = Color(0xFFFFF9F1);
  static const Color textSecondary = Color(0xFFB8B3C7);
  static const Color textMuted = Color(0xFF7A758D);

  // Subject Categorical Color Accents
  static const Color subjectScience = Color(0xFF48C9E8);     // Sky Cyan
  static const Color subjectMath = Color(0xFF8054E9);        // Comic Purple
  static const Color subjectBiology = Color(0xFF4EE38C);     // Electric Mint
  static const Color subjectPhysics = Color(0xFFFF914D);     // Vibrant Orange
  static const Color subjectChemistry = Color(0xFFF46CA8);   // Comic Pink
  static const Color subjectHistory = Color(0xFFFFD84D);     // Electric Yellow
  static const Color subjectGeography = Color(0xFF38B2AC);   // Teal Adventure
  static const Color subjectLiterature = Color(0xFFFF6584);  // Coral Novel

  // Official Dimension Flip Brand Gradient
  static const LinearGradient dimensionGradient = LinearGradient(
    colors: [comicPurple, comicPink, skyCyan],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF3B2474), Color(0xFF8054E9), Color(0xFF5B30BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

