import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/core/theme/comic_theme.dart';
import 'package:lorevaani/features/story_input/presentation/story_input_screen.dart';

void main() {
  group('StoryInputScreen Widget Tests', () {
    testWidgets('renders input fields, action buttons, and sample templates', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ComicTheme.darkTheme,
            home: const StoryInputScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and titles
      expect(find.text('INPUT STUDY MATERIAL'), findsOneWidget);
      expect(find.text('TOPIC OR LESSON TITLE'), findsOneWidget);
      expect(find.text('STUDY NOTES / TEXTBOOK CONTENT'), findsOneWidget);

      // Check action buttons in action bar
      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('Scan Camera'), findsOneWidget);
      expect(find.text('Image OCR'), findsOneWidget);
      expect(find.text('Import PDF'), findsOneWidget);

      // Check sample notes are available by exact chip title
      expect(find.text('Biology: Photosynthesis & Chloroplasts'), findsOneWidget);

      // Check CTA button
      expect(find.text('Customize Comic Story'), findsOneWidget);
    });

    testWidgets('1-tap sample note loads topic and content into editor', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ComicTheme.darkTheme,
            home: const StoryInputScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap on the Photosynthesis sample badge
      await tester.tap(find.text('Biology: Photosynthesis & Chloroplasts'));
      await tester.pump();

      // Topic title field should now contain Photosynthesis & Chloroplasts
      expect(find.text('Photosynthesis & Chloroplasts'), findsOneWidget);

      // Word count badge should update from 0 words
      expect(find.text('0 words (0 chars)'), findsNothing);
    });

    testWidgets('shows validation error when attempting to proceed with empty inputs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ComicTheme.darkTheme,
            home: const StoryInputScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap Customize Comic Story with empty fields
      await tester.tap(find.text('Customize Comic Story'));
      await tester.pump();

      // Expect validation banner to appear
      expect(
        find.text('Please provide a topic title for your comic story.'),
        findsOneWidget,
      );
    });
  });
}
