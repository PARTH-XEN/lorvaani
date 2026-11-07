import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../data/models/comic_story_model.dart';
import 'controllers/quiz_controller.dart';
import 'widgets/quiz_option_card.dart';
import 'widgets/quiz_results_view.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final ComicStory story;

  const QuizScreen({
    super.key,
    required this.story,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizControllerProvider.notifier).initialize(widget.story);
    });
  }

  static const _optionLetters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final controller = ref.read(quizControllerProvider.notifier);

    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        backgroundColor: ComicColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ComicColors.softWhite),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.story.storyTitle} — Quiz',
              style: ComicTypography.title(
                fontSize: 15,
                color: ComicColors.softWhite,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Knowledge Challenge',
              style: ComicTypography.caption(color: ComicColors.skyCyan),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.school_rounded, color: ComicColors.electricYellow),
            tooltip: 'Study Concepts',
            onPressed: () => context.push('/concepts', extra: widget.story),
          ),
        ],
      ),
      body: quizState.isCompleted
          ? QuizResultsView(
              sessionState: quizState,
              onRetake: () => controller.restartQuiz(),
              onReviewConcepts: () => context.push('/concepts', extra: widget.story),
              onBackToStory: () => context.pop(),
            )
          : _buildActiveQuizBody(context, quizState, controller),
    );
  }

  Widget _buildActiveQuizBody(
    BuildContext context,
    dynamic state,
    QuizController controller,
  ) {
    final question = state.currentQuestion as ComicQuizQuestion?;
    if (question == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentIndex = state.currentQuestionIndex as int;
    final total = state.totalQuestions as int;
    final isAnswered = state.isCurrentQuestionAnswered as bool;
    final isLast = currentIndex >= total - 1;

    return Column(
      children: [
        // Top Progress Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: ComicColors.cardBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUESTION ${currentIndex + 1} OF $total',
                    style: ComicTypography.caption(
                      color: ComicColors.electricYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Score: ${state.score}',
                    style: ComicTypography.caption(
                      color: ComicColors.skyCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? (currentIndex + 1) / total : 0.0,
                  backgroundColor: ComicColors.deepCharcoal,
                  valueColor: const AlwaysStoppedAnimation(ComicColors.comicPink),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        // Scrollable Question & Options
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question Card
                ComicPanel(
                  backgroundColor: ComicColors.cardBackground,
                  borderColor: ComicColors.comicPurple,
                  borderWidth: 2,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    question.question,
                    style: ComicTypography.title(
                      fontSize: 16,
                      color: ComicColors.softWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Options List
                ...List.generate(question.options.length, (index) {
                  final letter = index < _optionLetters.length ? _optionLetters[index] : '$index';
                  final text = question.options[index];
                  final isSelected = state.currentSelectedOption == index;
                  final isCorrect = index == question.correctAnswerIndex;

                  return QuizOptionCard(
                    optionLetter: letter,
                    optionText: text,
                    isSelected: isSelected,
                    isCorrect: isCorrect,
                    isAnswered: isAnswered,
                    onTap: () => controller.selectOption(index),
                  );
                }),

                // Explanation Callout when answered
                if (isAnswered && question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ComicColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ComicColors.skyCyan, width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: ComicColors.skyCyan, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WHY IT WORKS',
                                style: ComicTypography.caption(
                                  color: ComicColors.skyCyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                question.explanation,
                                style: ComicTypography.body(
                                  color: ComicColors.softWhite,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Bottom Action Button when answered
        if (isAnswered)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: ComicColors.cardBackground,
            child: SafeArea(
              top: false,
              child: ComicButton(
                text: isLast ? 'See Results ➔' : 'Next Question ➔',
                variant: isLast ? ComicButtonVariant.accent : ComicButtonVariant.primary,
                fullWidth: true,
                onPressed: () => controller.nextQuestion(),
              ),
            ),
          ),
      ],
    );
  }
}

