# Milestone 1: Lorvani Project Foundation & UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the rock-solid Flutter architectural foundation, Material 3 comic universe design system, custom vector Dimension Flip branding, responsive navigation with go_router and Riverpod, animated onboarding, and the rich comic dashboard Home Screen.

**Architecture:** Feature-driven Clean Architecture with Riverpod for reactive state management, GoRouter with ShellRoute for bottom navigation, custom Flutter Canvas vector drawing for the Dimension Flip brand identity, and modular comic UI components (speech bubbles, comic panels, halftone textures).

**Tech Stack:** Flutter 3.47.9, Dart 3.13.7, flutter_riverpod, go_router, google_fonts, flutter_animate, Material 3.

---

### File Structure Map

- `lib/core/theme/comic_colors.dart`: Design tokens (Deep Charcoal #17151F, Comic Purple #8054E9, Vibrant Orange #FF914D, Electric Yellow #FFD84D, Sky Cyan #48C9E8, Comic Pink #F46CA8, Soft White #FFF9F1, Card Background #252230).
- `lib/core/theme/comic_typography.dart`: Typography scales using Google Fonts (Bangers for comic accents, Poppins for titles, Inter for body).
- `lib/core/theme/comic_theme.dart`: Material 3 ThemeData configured for dark-first comic universe aesthetic with custom card themes, button styles, and app bar themes.
- `lib/core/constants/app_constants.dart`: App name, routes, streak presets, subject categories with colors and icons.
- `lib/core/widgets/dimension_flip_logo.dart`: Vector-drawn Dimension Flip logo (folded geometric origami page transforming across dimensions with purple-pink-cyan gradients; variations: primary, app icon, splash, small, monochrome).
- `lib/core/widgets/comic_panel.dart`: Reusable graphic novel styled card with customizable border, border radius, and pop-out comic shadows.
- `lib/core/widgets/comic_speech_bubble.dart`: Authentic comic speech bubble with customizable tail direction and narrator boxes.
- `lib/core/widgets/comic_button.dart`: Tactile comic-style action buttons with 3D press effect and bold borders.
- `lib/core/widgets/halftone_container.dart`: Custom painter for graphic novel dot patterns / halftones.
- `lib/core/widgets/badge_chip.dart`: Comic pill badges for levels, streaks, and subject tags.
- `lib/app/router.dart`: GoRouter configuration with ShellRoute, splash, onboarding, home, explore, create story placeholder, library placeholder, and profile routes.
- `lib/features/onboarding/presentation/onboarding_screen.dart`: 3-screen animated onboarding introducing story generation, comic panels, and gamified quizzes with skip and get started actions.
- `lib/features/home/presentation/home_screen.dart`: Rich Comic Universe dashboard (Lorvani header, streak pill, Concept of the Day, hero "Create Your Story" callout, Subject Cards grid, Recent Stories carousel, and Progress overview).
- `lib/features/home/widgets/subject_card.dart`: Subject category cards (Science, Mathematics, Biology, Physics, Chemistry, History, Geography, Literature) with individual color themes and icons.
- `lib/features/home/widgets/concept_of_the_day_card.dart`: Daily educational mini-comic tease with narration styling.
- `lib/features/home/widgets/streak_card.dart`: Engaging learning streak tracker with animated flame and comic sparkles.
- `lib/features/shared/presentation/main_shell_screen.dart`: Comic navigation shell with bottom navigation bar and active tab indicators.
- `lib/features/explore/presentation/explore_screen.dart`: Subject exploration screen.
- `lib/features/story_input/presentation/story_input_placeholder_screen.dart`: Milestone 3 anchor screen.
- `lib/features/library/presentation/library_placeholder_screen.dart`: Milestone 6 anchor screen.
- `lib/features/profile/presentation/profile_placeholder_screen.dart`: Profile and learning stats anchor.
- `lib/main.dart`: Root widget wrapped in ProviderScope with Lorvani theme and GoRouter.
- `test/dimension_flip_logo_test.dart`: Widget test verifying logo rendering and variation switching.
- `test/theme_test.dart`: Unit test ensuring color palette and typography compliance.
- `test/onboarding_test.dart`: Widget test testing 3-step page transitions and navigation to home.
- `test/home_screen_test.dart`: Widget test verifying dashboard components, subject cards, and streak display.

---

### Tasks

- [ ] **Task 1: Core Design System & Tokens**
  - Create `lib/core/theme/comic_colors.dart` with all specified brand colors.
  - Create `lib/core/theme/comic_typography.dart` with Bangers, Poppins, and Inter font scales.
  - Create `lib/core/theme/comic_theme.dart` with complete dark mode Material 3 theme.
  - Create `lib/core/constants/app_constants.dart` with subject models and copy.

- [ ] **Task 2: Official Dimension Flip Logo**
  - Implement `lib/core/widgets/dimension_flip_logo.dart` using CustomPainter.
  - Support `DimensionFlipVariant.primary` (symbol + "lorvani" wordmark).
  - Support `DimensionFlipVariant.appIcon` (symbol only).
  - Support `DimensionFlipVariant.splash` (large symbol + wordmark + tagline).
  - Support `DimensionFlipVariant.small` (compact header symbol).
  - Support `DimensionFlipVariant.monochrome` (high-contrast single color).

- [ ] **Task 3: Reusable Comic UI Component Library**
  - Implement `ComicPanel` with solid borders and drop shadows.
  - Implement `ComicSpeechBubble` and `NarrationBox`.
  - Implement `ComicButton` with tactile click feedback.
  - Implement `HalftonePattern` custom painter.
  - Implement `BadgeChip` for streaks and categories.

- [ ] **Task 4: Router & Riverpod Shell Navigation**
  - Implement `lib/app/router.dart` with `GoRouter`.
  - Create `MainShellScreen` with comic bottom navigation bar.
  - Create placeholder screens for Explore, Create, Library, and Profile.

- [ ] **Task 5: Onboarding Experience**
  - Implement `OnboardingScreen` with 3 illustrated comic slides.
  - Add smooth PageView animations with `flutter_animate`.
  - Add Skip and Get Started actions navigating to `/home`.

- [ ] **Task 6: Comic Universe Home Screen**
  - Implement `HomeScreen` dashboard.
  - Implement `SubjectCard` with Science, Mathematics, Biology, Physics, Chemistry, History, Geography, Literature.
  - Implement `ConceptOfTheDayCard` with comic panel aesthetic.
  - Implement `StreakCard` and "Create Your Story" hero banner.
  - Wire up `main.dart` with `ProviderScope`.

- [ ] **Task 7: Testing & Verification**
  - Write widget tests for logo, theme, onboarding, and home screen.
  - Run `flutter analyze` and resolve all lint issues.
  - Run `flutter test` and ensure all tests pass.

