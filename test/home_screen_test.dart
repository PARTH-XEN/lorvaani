import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/theme/comic_theme.dart';
import 'package:lorevaani/features/home/presentation/home_screen.dart';
import 'package:lorevaani/features/home/widgets/concept_of_the_day_card.dart';
import 'package:lorevaani/features/home/widgets/streak_card.dart';
import 'package:lorevaani/features/home/widgets/subject_card.dart';

void main() {
  group('HomeScreen Dashboard Tests', () {
    testWidgets('renders all key dashboard components', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ComicTheme.darkTheme,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Check greetings and headers
      expect(find.text('Welcome back, Explorer!'), findsOneWidget);
      expect(find.text('DAILY SPOTLIGHT'), findsOneWidget);
      expect(find.text('EXPLORE SUBJECTS'), findsOneWidget);

      // Check StreakCard and ConceptOfTheDayCard
      expect(find.byType(StreakCard), findsOneWidget);
      expect(find.text('1 Day Streak!'), findsOneWidget);
      expect(find.byType(ConceptOfTheDayCard), findsOneWidget);

      // Check Subject cards
      expect(find.byType(SubjectCard), findsWidgets);
      expect(find.text('Science'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);

      // Check Create Story CTA
      expect(find.text('Transform Your Notes Into Comics'), findsOneWidget);
      expect(find.text('Create Your Story'), findsOneWidget);
    });
  });
}
