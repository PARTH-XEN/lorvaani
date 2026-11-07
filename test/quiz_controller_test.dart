import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/quiz/data/quiz_session_state.dart';
import 'package:lorevaani/features/quiz/presentation/controllers/quiz_controller.dart';

void main() {
  group('QuizController Tests', () {
    late ProviderContainer container;
    late ComicStory sampleStory;

    setUp(() {
      sampleStory = ComicStory(
        id: 'story_genetics',
        storyTitle: 'Mendel and the Peas',
        originalTopic: 'Biology: Genetics',
        learningLevel: 'Beginner',
        visualStyle: 'Classic Comic',
        language: 'English',
        shortIntroduction: 'Learn how traits are inherited.',
        storySetting: 'Monastery Garden',
        characters: const [],
        panels: const [],
        keyConcepts: const [
          ComicKeyConcept(term: 'Allele', definition: 'A variant form of a gene.'),
        ],
        analogies: const [],
        summary: 'Genetics explains biological inheritance.',
        quizQuestions: const [
          ComicQuizQuestion(
            question: 'What is a variant form of a gene called?',
            options: ['Allele', 'Ribosome', 'Lipid', 'Chloroplast'],
            correctAnswerIndex: 0,
            explanation: 'Alleles are different versions of the same gene sequence.',
          ),
          ComicQuizQuestion(
            question: 'Which trait is expressed when at least one dominant allele is present?',
            options: ['Recessive', 'Dominant', 'Mutant', 'Latent'],
            correctAnswerIndex: 1,
            explanation: 'Dominant alleles mask the phenotypic presence of recessive alleles.',
          ),
        ],
        createdAt: DateTime.now(),
      );

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes quiz session state from comic story', () {
      final controller = container.read(quizControllerProvider.notifier);
      controller.initialize(sampleStory);

      final state = container.read(quizControllerProvider);
      expect(state.totalQuestions, equals(2));
      expect(state.currentQuestionIndex, equals(0));
      expect(state.score, equals(0));
      expect(state.isCompleted, isFalse);
      expect(state.isCurrentQuestionAnswered, isFalse);
      expect(state.currentQuestion?.question, contains('variant form of a gene'));
    });

    test('selecting correct answer records selection and increments score', () {
      final controller = container.read(quizControllerProvider.notifier);
      controller.initialize(sampleStory);

      // Select correct answer (option index 0: 'Allele')
      controller.selectOption(0);

      var state = container.read(quizControllerProvider);
      expect(state.isCurrentQuestionAnswered, isTrue);
      expect(state.currentSelectedOption, equals(0));
      expect(state.isCurrentAnswerCorrect, isTrue);
      expect(state.score, equals(1));

      // Attempting to select another option on the same question is locked
      controller.selectOption(1);
      state = container.read(quizControllerProvider);
      expect(state.currentSelectedOption, equals(0)); // Unchanged
      expect(state.score, equals(1)); // Unchanged
    });

    test('selecting wrong answer records selection without incrementing score', () {
      final controller = container.read(quizControllerProvider.notifier);
      controller.initialize(sampleStory);

      // Select wrong answer (option index 2: 'Lipid')
      controller.selectOption(2);

      final state = container.read(quizControllerProvider);
      expect(state.isCurrentQuestionAnswered, isTrue);
      expect(state.currentSelectedOption, equals(2));
      expect(state.isCurrentAnswerCorrect, isFalse);
      expect(state.score, equals(0));
    });

    test('advances through questions and completes quiz on final question', () {
      final controller = container.read(quizControllerProvider.notifier);
      controller.initialize(sampleStory);

      // Answer question 1 correctly
      controller.selectOption(0);
      controller.nextQuestion();

      var state = container.read(quizControllerProvider);
      expect(state.currentQuestionIndex, equals(1));
      expect(state.isCompleted, isFalse);
      expect(state.isCurrentQuestionAnswered, isFalse);

      // Answer question 2 correctly
      controller.selectOption(1);
      controller.nextQuestion();

      state = container.read(quizControllerProvider);
      expect(state.isCompleted, isTrue);
      expect(state.score, equals(2));
      expect(state.percentageScore, equals(100));
      expect(state.masteryTier, equals(MasteryTier.cosmicScholar));
      expect(state.masteryTitle, equals('Cosmic Scholar!'));
    });

    test('restarting quiz resets all answers, score, and completion status', () {
      final controller = container.read(quizControllerProvider.notifier);
      controller.initialize(sampleStory);

      controller.selectOption(0);
      controller.nextQuestion();
      controller.selectOption(1);
      controller.nextQuestion();

      expect(container.read(quizControllerProvider).isCompleted, isTrue);

      controller.restartQuiz();

      final state = container.read(quizControllerProvider);
      expect(state.currentQuestionIndex, equals(0));
      expect(state.score, equals(0));
      expect(state.selectedAnswers, isEmpty);
      expect(state.isCompleted, isFalse);
    });
  });
}

