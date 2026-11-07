import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/utils/story_schema_validator.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';

void main() {
  group('ComicStory Model & Schema Validator Tests', () {
    const validator = StorySchemaValidator();

    final validStoryMap = {
      'storyTitle': 'The Quantum Leap of Photosynthesis',
      'originalTopic': 'Photosynthesis',
      'learningLevel': 'Intermediate',
      'visualStyle': 'Cinematic Comic',
      'language': 'English',
      'shortIntroduction': 'A journey inside a plant cell to witness solar capture.',
      'storySetting': 'Inside the thylakoid membrane of a leaf chloroplast',
      'characters': [
        {
          'name': 'Professor Quantum',
          'role': 'Guide',
          'visualDescription': 'White hair, futuristic violet coat, glowing datapad',
        },
      ],
      'panels': [
        {
          'panelNumber': 1,
          'panelTitle': 'Sunlight Arrival',
          'panelDescription': 'Photons stream through space and hit the chlorophyll antenna.',
          'narration': 'Billions of light particles strike the emerald leaf surface.',
          'dialogue': [
            {'speaker': 'Professor Quantum', 'text': 'Brace for photon impact!'}
          ],
          'keyVisualCue': 'Golden rays striking emerald hexagonal structures',
        },
        {
          'panelNumber': 2,
          'panelTitle': 'Water Splitting',
          'panelDescription': 'Enzyme complexes split H2O into oxygen and protons.',
          'narration': 'Water molecules are disassembled to free electrons.',
          'dialogue': [
            {'speaker': 'Professor Quantum', 'text': 'Oxygen is released as a byproduct!'}
          ],
          'keyVisualCue': 'Water droplet splitting with lightning sparks',
        },
      ],
      'keyConcepts': [
        {'term': 'Chlorophyll', 'definition': 'Light-absorbing pigment.'},
      ],
      'analogies': [
        {
          'targetConcept': 'Photosynthesis',
          'everydayAnalogy': 'A solar-powered automated bakery.',
          'whyItWorks': 'Converts light and raw ingredients into stored nutrition.',
        },
      ],
      'summary': 'Photosynthesis turns light energy into glucose fuel.',
      'quizQuestions': [
        {
          'question': 'What pigment absorbs light in plant cells?',
          'options': ['Chlorophyll', 'Melanin', 'Hemoglobin', 'Keratin'],
          'correctAnswerIndex': 0,
          'explanation': 'Chlorophyll is the primary photosynthetic pigment in plants.',
        },
      ],
    };

    test('Validator accepts complete schema-compliant story JSON', () {
      expect(() => validator.validate(validStoryMap), returnsNormally);
    });

    test('ComicStory deserializes and serializes without data loss', () {
      final story = ComicStory.fromJson(validStoryMap, id: 'test_123');
      expect(story.id, 'test_123');
      expect(story.storyTitle, 'The Quantum Leap of Photosynthesis');
      expect(story.characters.length, 1);
      expect(story.characters.first.name, 'Professor Quantum');
      expect(story.panels.length, 2);
      expect(story.panels.first.dialogue.first.speaker, 'Professor Quantum');
      expect(story.quizQuestions.first.correctAnswerIndex, 0);

      final json = story.toJson();
      expect(json['id'], 'test_123');
      expect(json['storyTitle'], 'The Quantum Leap of Photosynthesis');
      expect(json['panels'], isA<List>());
    });

    test('Validator throws when storyTitle is missing or empty', () {
      final invalid = Map<String, dynamic>.from(validStoryMap)..remove('storyTitle');
      expect(
        () => validator.validate(invalid),
        throwsA(isA<StorySchemaValidationException>()),
      );
    });

    test('Validator throws when characters list is empty', () {
      final invalid = Map<String, dynamic>.from(validStoryMap)..['characters'] = [];
      expect(
        () => validator.validate(invalid),
        throwsA(isA<StorySchemaValidationException>()),
      );
    });

    test('Validator throws when panels has fewer than 2 items', () {
      final panelsList = validStoryMap['panels'] as List;
      final invalid = Map<String, dynamic>.from(validStoryMap)
        ..['panels'] = [panelsList[0]];
      expect(
        () => validator.validate(invalid),
        throwsA(isA<StorySchemaValidationException>()),
      );
    });

    test('Validator throws when quiz correctAnswerIndex is out of range', () {
      final invalidQuiz = {
        'question': 'What is gravity?',
        'options': ['A force', 'A sound'],
        'correctAnswerIndex': 5, // Invalid: options length is 2
        'explanation': 'Explanation',
      };
      final invalid = Map<String, dynamic>.from(validStoryMap)
        ..['quizQuestions'] = [invalidQuiz];
      expect(
        () => validator.validate(invalid),
        throwsA(isA<StorySchemaValidationException>()),
      );
    });
  });
}
