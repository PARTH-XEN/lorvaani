import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/comic_story_model.dart';
import '../../data/quiz_session_state.dart';

final quizControllerProvider =
    NotifierProvider<QuizController, QuizSessionState>(
  QuizController.new,
);

class QuizController extends Notifier<QuizSessionState> {
  @override
  QuizSessionState build() {
    return const QuizSessionState();
  }

  /// Initializes the quiz session with questions from a comic story
  void initialize(ComicStory story) {
    state = QuizSessionState(
      story: story,
      currentQuestionIndex: 0,
      selectedAnswers: const {},
      score: 0,
      isCompleted: false,
    );
  }

  /// Selects an answer option for the current question
  void selectOption(int optionIndex) {
    final question = state.currentQuestion;
    if (question == null || state.isCurrentQuestionAnswered) return;

    final updatedAnswers = Map<int, int>.from(state.selectedAnswers);
    updatedAnswers[state.currentQuestionIndex] = optionIndex;

    final isCorrect = optionIndex == question.correctAnswerIndex;
    final updatedScore = isCorrect ? state.score + 1 : state.score;

    state = state.copyWith(
      selectedAnswers: updatedAnswers,
      score: updatedScore,
    );
  }

  /// Advances to the next question or completes the quiz
  void nextQuestion() {
    if (state.currentQuestionIndex < state.totalQuestions - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    } else {
      state = state.copyWith(isCompleted: true);
    }
  }

  /// Restarts the quiz session from the beginning
  void restartQuiz() {
    if (state.story == null) return;
    state = QuizSessionState(
      story: state.story,
      currentQuestionIndex: 0,
      selectedAnswers: const {},
      score: 0,
      isCompleted: false,
    );
  }
}

