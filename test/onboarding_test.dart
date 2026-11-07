import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/theme/comic_theme.dart';
import 'package:lorevaani/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  group('OnboardingScreen Tests', () {
    testWidgets('renders first slide and advances with Continue button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ComicTheme.darkTheme,
          home: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check first slide content
      expect(find.text('Turn Boring Notes Into Stories'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Tap Continue to advance to slide 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Explore Comic Panels & Analogies'), findsOneWidget);

      // Tap Continue to advance to slide 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Learn, Play Quizzes & Remember'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });
  });
}

