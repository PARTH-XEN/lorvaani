import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/features/auth/presentation/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget createAuthScreen() {
      return const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      );
    }

    testWidgets('renders sign in screen elements', (tester) async {
      await tester.pumpWidget(createAuthScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign In & Continue'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('switches to create account mode when toggle tapped', (tester) async {
      await tester.pumpWidget(createAuthScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Your Name / Alias'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Free Account'), findsOneWidget);
    });

    testWidgets('validates empty inputs on submission', (tester) async {
      await tester.pumpWidget(createAuthScreen());
      await tester.pumpAndSettle();

      // Tap submit CTA without filling fields
      await tester.tap(find.text('Sign In & Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      await tester.pumpWidget(createAuthScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Sign In & Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });
  });
}
