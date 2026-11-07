import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/router.dart';
import 'core/services/auth/auth_service.dart';
import 'core/theme/comic_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LorvaniApp(),
    ),
  );
}

/// Root Application Widget for Lorvani Comic Universe
class LorvaniApp extends StatelessWidget {
  const LorvaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lorvani',
      debugShowCheckedModeBanner: false,
      theme: ComicTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
