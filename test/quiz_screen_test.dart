import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/quiz/presentation/quiz_screen.dart';

void main() {
  final sampleStory = ComicStory(
    id: 'story_genetics_ui',
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
        question: 'Which trait is expressed when a dominant allele is present?',
        options: ['Recessive', 'Dominant'],
        correctAnswerIndex: 1,
        explanation: 'Dominant alleles mask recessive alleles in phenotypic expression.',
      ),
    ],
    createdAt: DateTime.now(),
  );

  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: QuizScreen(story: sampleStory),
      ),
    );
  }

  group('QuizScreen Widget Tests', () {
    testWidgets('renders question header, progress bar, question text, and options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('QUESTION 1 OF 2'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('What is a variant form of a gene called?'), findsOneWidget);
      expect(find.text('Allele'), findsOneWidget);
      expect(find.text('Ribosome'), findsOneWidget);
      expect(find.text('Lipid'), findsOneWidget);
      expect(find.text('Chloroplast'), findsOneWidget);
    });

    testWidgets('selecting an answer displays explanation callout and next button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap option 'Allele' (correct answer)
      await tester.tap(find.text('Allele'));
      await tester.pumpAndSettle();

      expect(find.text('WHY IT WORKS'), findsOneWidget);
      expect(find.textContaining('Alleles are different versions'), findsOneWidget);
      expect(find.text('Next Question ➔'), findsOneWidget);
      expect(find.text('Score: 1'), findsOneWidget);
    });

    testWidgets('completing full quiz shows results screen with mastery breakdown', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Question 1: Select 'Allele' (correct)
      await tester.tap(find.text('Allele'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Question ➔'));
      await tester.pumpAndSettle();

      expect(find.text('QUESTION 2 OF 2'), findsOneWidget);

      // Question 2: Select 'Dominant' (correct)
      await tester.tap(find.text('Dominant'));
      await tester.pumpAndSettle();

      expect(find.text('See Results ➔'), findsOneWidget);
      await tester.tap(find.text('See Results ➔'));
      await tester.pumpAndSettle();

      // Results view
      expect(find.text('MISSION COMPLETE!'), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Cosmic Scholar!'), findsOneWidget);
      expect(find.text('Retake Quiz'), findsOneWidget);
      expect(find.text('Review Key Concepts'), findsOneWidget);
    });
  });
}

