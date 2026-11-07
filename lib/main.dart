import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'core/theme/comic_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: LorvaniApp(),
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
