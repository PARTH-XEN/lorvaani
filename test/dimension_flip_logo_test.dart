import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/widgets/dimension_flip_logo.dart';

void main() {
  group('Dimension Flip Logo Tests', () {
    testWidgets('renders primary logo with wordmark', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DimensionFlipLogo(
              variant: DimensionFlipVariant.primary,
              size: 40,
            ),
          ),
        ),
      );

      expect(find.byType(DimensionFlipLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders appIcon variant without wordmark', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DimensionFlipLogo(
              variant: DimensionFlipVariant.appIcon,
              size: 64,
            ),
          ),
        ),
      );

      expect(find.byType(DimensionFlipLogo), findsOneWidget);
    });

    testWidgets('renders splash variant with tagline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DimensionFlipLogo(
              variant: DimensionFlipVariant.splash,
              size: 80,
              showTagline: true,
            ),
          ),
        ),
      );

      expect(find.byType(DimensionFlipLogo), findsOneWidget);
      expect(find.text('turn study into stories'), findsOneWidget);
    });

    testWidgets('renders small icon and monochrome variants', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DimensionFlipLogo(variant: DimensionFlipVariant.small, size: 24),
                DimensionFlipLogo(
                  variant: DimensionFlipVariant.monochrome,
                  size: 32,
                  monochromeColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(DimensionFlipLogo), findsNWidgets(2));
    });
  });
}

