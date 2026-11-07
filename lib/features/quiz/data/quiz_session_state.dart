import '../../../../data/models/comic_story_model.dart';

enum MasteryTier {
  cosmicScholar,
  comicMastermind,
  heroInTraining,
  comicNovice,
}

/// State tracking an interactive quiz session
class QuizSessionState {
  final ComicStory? story;
  final int currentQuestionIndex;
  final Map<int, int> selectedAnswers; // questionIndex -> selectedOptionIndex
  final int score;
  final bool isCompleted;

  const QuizSessionState({
    this.story,
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.score = 0,
    this.isCompleted = false,
  });

  int get totalQuestions => story?.quizQuestions.length ?? 0;

  ComicQuizQuestion? get currentQuestion {
    if (story == null || story!.quizQuestions.isEmpty) return null;
    if (currentQuestionIndex < 0 || currentQuestionIndex >= story!.quizQuestions.length) return null;
    return story!.quizQuestions[currentQuestionIndex];
  }

  bool get isCurrentQuestionAnswered => selectedAnswers.containsKey(currentQuestionIndex);

  int? get currentSelectedOption => selectedAnswers[currentQuestionIndex];

  bool get isCurrentAnswerCorrect {
    if (!isCurrentQuestionAnswered || currentQuestion == null) return false;
    return currentSelectedOption == currentQuestion!.correctAnswerIndex;
  }

  int get percentageScore => totalQuestions > 0 ? ((score / totalQuestions) * 100).round() : 0;

  MasteryTier get masteryTier {
    final pct = percentageScore;
    if (pct == 100) return MasteryTier.cosmicScholar;
    if (pct >= 80) return MasteryTier.comicMastermind;
    if (pct >= 60) return MasteryTier.heroInTraining;
    return MasteryTier.comicNovice;
  }

  String get masteryTitle {
    switch (masteryTier) {
      case MasteryTier.cosmicScholar:
        return 'Cosmic Scholar!';
      case MasteryTier.comicMastermind:
        return 'Comic Mastermind!';
      case MasteryTier.heroInTraining:
        return 'Hero in Training!';
      case MasteryTier.comicNovice:
        return 'Comic Novice!';
    }
  }

  String get masteryDescription {
    switch (masteryTier) {
      case MasteryTier.cosmicScholar:
        return 'Flawless comprehension! You have completely mastered this concept dimension.';
      case MasteryTier.comicMastermind:
        return 'Fantastic performance! You understand the key scientific principles and analogies.';
      case MasteryTier.heroInTraining:
        return 'Good effort! Review the concept cards and analogies to sharpen your knowledge.';
      case MasteryTier.comicNovice:
        return 'Keep exploring! Re-read the comic story and try the quiz once more to level up.';
    }
  }

  QuizSessionState copyWith({
    ComicStory? story,
    int? currentQuestionIndex,
    Map<int, int>? selectedAnswers,
    int? score,
    bool? isCompleted,
  }) {
    return QuizSessionState(
      story: story ?? this.story,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

