import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/theme/comic_colors.dart';
import 'package:lorevaani/core/theme/comic_theme.dart';
import 'package:lorevaani/core/constants/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Comic Universe Theme & Tokens Test', () {
    test('Official brand color hex values match specification', () {
      expect(ComicColors.deepCharcoal, const Color(0xFF17151F));
      expect(ComicColors.comicPurple, const Color(0xFF8054E9));
      expect(ComicColors.vibrantOrange, const Color(0xFFFF914D));
      expect(ComicColors.electricYellow, const Color(0xFFFFD84D));
      expect(ComicColors.skyCyan, const Color(0xFF48C9E8));
      expect(ComicColors.comicPink, const Color(0xFFF46CA8));
      expect(ComicColors.softWhite, const Color(0xFFFFF9F1));
      expect(ComicColors.cardBackground, const Color(0xFF252230));
    });

    test('Material 3 theme is dark mode with correct scaffold background', () {
      final theme = ComicTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, ComicColors.deepCharcoal);
      expect(theme.colorScheme.primary, ComicColors.comicPurple);
      expect(theme.colorScheme.secondary, ComicColors.comicPink);
    });

    test('All 8 required subject categories are configured', () {
      expect(AppConstants.subjects.length, 8);
      final titles = AppConstants.subjects.map((s) => s.title).toList();
      expect(
        titles,
        containsAll([
          'Science',
          'Mathematics',
          'Biology',
          'Physics',
          'Chemistry',
          'History',
          'Geography',
          'Literature',
        ]),
      );
    });
  });
}
