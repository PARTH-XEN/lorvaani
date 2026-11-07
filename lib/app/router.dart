import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_placeholder_screen.dart';
import '../features/shared/presentation/main_shell_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/story_input/presentation/story_input_screen.dart';
import '../features/story_generation/presentation/story_customization_screen.dart';
import '../features/story_generation/presentation/story_generation_progress_screen.dart';
import '../features/comic_reader/presentation/comic_reader_screen.dart';
import '../features/quiz/presentation/quiz_screen.dart';
import '../features/quiz/presentation/concept_study_screen.dart';
import '../data/models/comic_story_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Lorvani Official Route Configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/customize',
      name: 'customize',
      builder: (context, state) => const StoryCustomizationScreen(),
    ),
    GoRoute(
      path: '/generate-progress',
      name: 'generate-progress',
      builder: (context, state) => const StoryGenerationProgressScreen(),
    ),
    GoRoute(
      path: '/reader',
      name: 'reader',
      builder: (context, state) {
        final story = state.extra as ComicStory;
        return ComicReaderScreen(story: story);
      },
    ),
    GoRoute(
      path: '/quiz',
      name: 'quiz',
      builder: (context, state) {
        final story = state.extra as ComicStory;
        return QuizScreen(story: story);
      },
    ),
    GoRoute(
      path: '/concepts',
      name: 'concepts',
      builder: (context, state) {
        final story = state.extra as ComicStory;
        return ConceptStudyScreen(story: story);
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/explore',
          name: 'explore',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExploreScreen(),
          ),
        ),
        GoRoute(
          path: '/create',
          name: 'create',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StoryInputScreen(),
          ),
        ),
        GoRoute(
          path: '/library',
          name: 'library',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfilePlaceholderScreen(),
          ),
        ),
      ],
    ),
  ],
);

