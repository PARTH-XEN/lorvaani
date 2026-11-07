import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/ai/ai_provider_types.dart';
import 'package:lorevaani/features/story_generation/services/story_prompt_builder.dart';

void main() {
  group('StoryPromptBuilder Tests', () {
    const builder = StoryPromptBuilder();

    test('buildPrompt injects topic, options, and note content into prompt', () {
      const options = StoryGenerationOptions(
        learningLevel: LearningLevel.advanced,
        visualStyle: ComicVisualStyle.animeInspired,
        panelCount: 8,
        language: 'English',
      );

      final prompt = builder.buildPrompt(
        topicTitle: 'General Relativity',
        notesText: 'Mass bends the fabric of spacetime. Light bends around massive bodies.',
        options: options,
      );

      expect(prompt, contains('TOPIC: General Relativity'));
      expect(prompt, contains('LEARNING LEVEL: Advanced'));
      expect(prompt, contains('TARGET COMIC PANELS: 8'));
      expect(prompt, contains('VISUAL ART STYLE: Anime-inspired'));
      expect(prompt, contains('Mass bends the fabric of spacetime.'));
      expect(prompt, contains('Return raw JSON matching the required schema.'));
    });
  });
}

