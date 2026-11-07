import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/main.dart';
import 'package:lorevaani/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('LorvaniApp loads and initializes splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LorvaniApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance clock to allow splash transition timer to complete cleanly
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 200));
  });
}
