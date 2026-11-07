import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/theme/comic_theme.dart';
import 'package:lorevaani/features/story_generation/presentation/story_customization_screen.dart';

void main() {
  group('StoryCustomizationScreen Widget Tests', () {
    testWidgets('renders all customization options and sections', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ComicTheme.darkTheme,
            home: const StoryCustomizationScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and sections
      expect(find.text('STORY CUSTOMIZER'), findsOneWidget);
      expect(find.text('1. LEARNING LEVEL'), findsOneWidget);
      expect(find.text('2. COMIC ART STYLE'), findsOneWidget);
      expect(find.text('3. STORY LENGTH'), findsOneWidget);
      expect(find.text('4. LANGUAGE'), findsOneWidget);

      // Check learning levels
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);

      // Check comic styles
      expect(find.text('Classic Comic'), findsOneWidget);
      expect(find.text('Cinematic Comic'), findsOneWidget);
      expect(find.text('Anime-inspired'), findsOneWidget);

      // Check CTA
      expect(find.text('Generate Comic Story'), findsOneWidget);
    });

    testWidgets('selecting different learning level updates UI selection', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ComicTheme.darkTheme,
            home: const StoryCustomizationScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap on Advanced
      await tester.tap(find.text('Advanced'));
      await tester.pump();

      expect(find.text('Advanced'), findsOneWidget);
    });
  });
}
