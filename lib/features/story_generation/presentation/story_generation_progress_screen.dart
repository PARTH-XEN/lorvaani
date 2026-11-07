import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/comic_speech_bubble.dart';
import '../../../core/widgets/dimension_flip_logo.dart';
import '../../../core/widgets/halftone_container.dart';
import '../../story_input/presentation/controllers/story_input_controller.dart';
import '../data/story_generation_state.dart';
import 'controllers/story_generation_controller.dart';

/// Interactive Progress & Story Generation Screen
class StoryGenerationProgressScreen extends ConsumerStatefulWidget {
  const StoryGenerationProgressScreen({super.key});

  @override
  ConsumerState<StoryGenerationProgressScreen> createState() =>
      _StoryGenerationProgressScreenState();
}

class _StoryGenerationProgressScreenState
    extends ConsumerState<StoryGenerationProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration();
    });
  }

  void _startGeneration({bool forceOffline = false}) {
    final inputState = ref.read(storyInputControllerProvider);
    ref.read(storyGenerationControllerProvider.notifier).generateStory(
          topicTitle: inputState.topicTitle.isEmpty
              ? 'Educational Topic'
              : inputState.topicTitle,
          notesText: inputState.notesText,
          forceOfflineMock: forceOffline,
        );
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(storyGenerationControllerProvider);

    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          'GENERATING COMIC',
          style: ComicTypography.comicDisplay(fontSize: 22),
        ),
        leading: genState.isLoading
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: genState.hasError
              ? _buildErrorView(genState)
              : genState.isSuccess
                  ? _buildSuccessView(genState)
                  : _buildLoadingView(genState),
        ),
      ),
    );
  }

  Widget _buildLoadingView(StoryGenerationState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const DimensionFlipLogo(
          variant: DimensionFlipVariant.splash,
          size: 70,
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              duration: 800.ms,
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.05, 1.05),
            ),
        const SizedBox(height: 32),

        // Progress Message Speech Bubble
        ComicSpeechBubble(
          backgroundColor: ComicColors.softWhite,
          tailDirection: BubbleTailDirection.bottomLeft,
          child: Text(
            state.progressMessage,
            style: ComicTypography.narration(
              fontSize: 14,
              color: ComicColors.deepCharcoal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        // Animated Comic Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: state.progressPercent,
            backgroundColor: ComicColors.surfaceLight,
            valueColor:
                const AlwaysStoppedAnimation<Color>(ComicColors.comicPink),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          '${(state.progressPercent * 100).toInt()}% Complete',
          style: ComicTypography.caption(
            fontSize: 12,
            color: ComicColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(StoryGenerationState state) {
    return Center(
      child: ComicPanel(
        backgroundColor: ComicColors.cardBackground,
        borderColor: Colors.redAccent,
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 14),
            Text(
              'GENERATION PAUSED',
              style: ComicTypography.comicDisplay(
                fontSize: 20,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              state.errorMessage ?? 'An error occurred during generation.',
              style: ComicTypography.body(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ComicButton(
                    text: 'Retry',
                    icon: Icons.refresh_rounded,
                    variant: ComicButtonVariant.primary,
                    onPressed: () => _startGeneration(forceOffline: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ComicButton(
                    text: 'Use Offline',
                    icon: Icons.offline_pin_rounded,
                    variant: ComicButtonVariant.dark,
                    onPressed: () => _startGeneration(forceOffline: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(StoryGenerationState state) {
    final story = state.generatedStory!;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Center(
          child: Text(
            'STORY SCRIPT COMPLETE!',
            style: ComicTypography.comicDisplay(
              fontSize: 24,
              color: ComicColors.electricYellow,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Generated Story Overview Card
        ComicPanel(
          backgroundColor: ComicColors.cardBackground,
          borderColor: ComicColors.comicPurple,
          borderRadius: 20,
          padding: EdgeInsets.zero,
          child: HalftoneContainer(
            backgroundColor: ComicColors.cardBackground,
            dotColor: ComicColors.comicPurple.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BadgeChip.category(
                        name: story.visualStyle,
                        color: ComicColors.comicPink,
                      ),
                      BadgeChip.level(level: story.learningLevel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    story.storyTitle,
                    style: ComicTypography.heading(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.shortIntroduction,
                    style: ComicTypography.body(
                      fontSize: 13,
                      color: ComicColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Characters
                  Text(
                    'CAST OF CHARACTERS',
                    style: ComicTypography.comicDisplay(
                      fontSize: 14,
                      color: ComicColors.skyCyan,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...story.characters.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.person_pin_rounded,
                              size: 16, color: ComicColors.skyCyan),
                          const SizedBox(width: 6),
                          Text(
                            c.name,
                            style: ComicTypography.body(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '— ${c.role}',
                              style: ComicTypography.caption(
                                fontSize: 12,
                                color: ComicColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),

                  // Panel Stats
                  Row(
                    children: [
                      BadgeChip(
                        label: '${story.panels.length} Comic Panels Created',
                        icon: Icons.view_carousel_rounded,
                        backgroundColor: ComicColors.surfaceLight,
                        textColor: ComicColors.electricYellow,
                      ),
                      const SizedBox(width: 8),
                      BadgeChip(
                        label: '${story.quizQuestions.length} Quiz Questions',
                        icon: Icons.quiz_rounded,
                        backgroundColor: ComicColors.surfaceLight,
                        textColor: ComicColors.skyCyan,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Action CTA
        ComicButton(
          text: 'Open Story Reader',
          icon: Icons.auto_stories_rounded,
          variant: ComicButtonVariant.gradient,
          fullWidth: true,
          onPressed: () {
            context.push('/reader', extra: story);
          },
        ),
      ],
    );
  }
}

