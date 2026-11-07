import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/ai/ai_provider_types.dart';
import 'package:lorevaani/data/models/comic_story_model.dart';
import 'package:lorevaani/features/image_generation/services/comic_image_prompt_service.dart';

void main() {
  const service = ComicImagePromptService();

  group('ComicImagePromptService Tests', () {
    test('resolves visual styles accurately from various string inputs', () {
      expect(service.resolveVisualStyle('Classic Comic'), ComicVisualStyle.classicComic);
      expect(service.resolveVisualStyle('Anime-inspired'), ComicVisualStyle.animeInspired);
      expect(service.resolveVisualStyle('Cartoon'), ComicVisualStyle.cartoon);
      expect(service.resolveVisualStyle('Storybook'), ComicVisualStyle.storybook);
      expect(service.resolveVisualStyle('Cinematic Comic'), ComicVisualStyle.cinematicComic);
      expect(service.resolveVisualStyle('unknown'), ComicVisualStyle.classicComic);
    });

    test('builds character consistency prompt correctly', () {
      const characters = [
        ComicCharacter(
          name: 'Maya',
          role: 'Lead Explorer',
          visualDescription: 'teal cyber goggles, yellow jacket',
        ),
        ComicCharacter(
          name: 'Volt',
          role: 'Robotic Companion',
          visualDescription: 'round hovering copper drone with blue sensor',
        ),
      ];

      final prompt = service.buildCharacterConsistencyPrompt(characters);
      expect(prompt, contains('Maya (Lead Explorer, teal cyber goggles, yellow jacket)'));
      expect(prompt, contains('Volt (Robotic Companion, round hovering copper drone with blue sensor)'));
    });

    test('calculates deterministic seed for story continuity', () {
      final storyA = ComicStory(
        id: 'story_123',
        storyTitle: 'Photosynthesis',
        originalTopic: 'Biology',
        learningLevel: 'Intermediate',
        visualStyle: 'Cinematic Comic',
        language: 'English',
        shortIntroduction: 'Intro',
        storySetting: 'Inside a plant cell',
        characters: const [
          ComicCharacter(name: 'Chlora', role: 'Guide', visualDescription: 'green robe'),
        ],
        panels: const [],
        keyConcepts: const [],
        analogies: const [],
        summary: 'Summary',
        quizQuestions: const [],
        createdAt: DateTime(2026, 11, 7),
      );

      final storyB = ComicStory(
        id: 'story_123',
        storyTitle: 'Photosynthesis',
        originalTopic: 'Biology',
        learningLevel: 'Intermediate',
        visualStyle: 'Cinematic Comic',
        language: 'English',
        shortIntroduction: 'Intro',
        storySetting: 'Inside a plant cell',
        characters: const [
          ComicCharacter(name: 'Chlora', role: 'Guide', visualDescription: 'green robe'),
        ],
        panels: const [],
        keyConcepts: const [],
        analogies: const [],
        summary: 'Summary',
        quizQuestions: const [],
        createdAt: DateTime(2026, 11, 7),
      );

      final seedA = service.calculateStorySeed(storyA);
      final seedB = service.calculateStorySeed(storyB);

      expect(seedA, equals(seedB));
      expect(seedA, isPositive);
    });

    test('assembles complete panel prompt with scene, cues, style, and negatives', () {
      final story = ComicStory(
        id: 'story_456',
        storyTitle: 'Gravity',
        originalTopic: 'Physics',
        learningLevel: 'Beginner',
        visualStyle: 'Anime-inspired',
        language: 'English',
        shortIntroduction: 'Intro',
        storySetting: 'Orbiting space station',
        characters: const [
          ComicCharacter(name: 'Astro', role: 'Pilot', visualDescription: 'silver space suit'),
        ],
        panels: const [],
        keyConcepts: const [],
        analogies: const [],
        summary: 'Summary',
        quizQuestions: const [],
        createdAt: DateTime.now(),
      );

      const panel = ComicPanelModel(
        panelNumber: 1,
        panelTitle: 'Zero-G Float',
        panelDescription: 'Astro releases an apple and watches it float effortlessly',
        narration: 'Without gravity, objects remain in freefall.',
        dialogue: [
          ComicDialogue(speaker: 'Astro', text: 'Look at it float!'),
        ],
        keyVisualCue: 'Floating glowing red apple in zero gravity',
      );

      final assembled = service.assemblePanelPrompt(story: story, panel: panel);

      expect(assembled, contains('Astro releases an apple and watches it float effortlessly'));
      expect(assembled, contains('Orbiting space station'));
      expect(assembled, contains('Floating glowing red apple in zero gravity'));
      expect(assembled, contains('Astro (Pilot, silver space suit)'));
      expect(assembled, contains('high-end modern anime keyframe art'));
      expect(assembled, contains('no text in artwork'));
    });
  });
}
