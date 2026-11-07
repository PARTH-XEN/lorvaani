import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/widgets/comic_trial_gate_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ComicTrialGateDialog Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget createDialogTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ComicTrialGateDialog(),
          ),
        ),
      );
    }

    testWidgets('displays trial limit notice and member benefits', (tester) async {
      await tester.pumpWidget(createDialogTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('FREE TRIAL COMPLETE! 🎉'), findsOneWidget);
      expect(find.textContaining('You\'ve created your 1 free guest comic!'), findsOneWidget);
      expect(find.text('Unlimited AI comic book creation'), findsOneWidget);
      expect(find.text('Multilingual stories in Hindi, Spanish & more'), findsOneWidget);
      expect(find.text('Sign In / Create Account'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);
    });

    testWidgets('dismisses dialog when Maybe Later is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ComicTrialGateDialog(),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('FREE TRIAL COMPLETE! 🎉'), findsOneWidget);

      await tester.tap(find.text('Maybe Later'));
      await tester.pumpAndSettle();

      expect(find.text('FREE TRIAL COMPLETE! 🎉'), findsNothing);
    });
  });
}

