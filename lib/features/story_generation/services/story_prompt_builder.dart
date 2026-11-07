import '../../../core/services/ai/ai_provider_types.dart';

/// Prompt builder constructing structured LLM instructions for educational comics
class StoryPromptBuilder {
  const StoryPromptBuilder();

  /// Builds the combined prompt payload for the LLM
  String buildPrompt({
    required String topicTitle,
    required String notesText,
    required StoryGenerationOptions options,
  }) {
    return '''
TOPIC: $topicTitle
LEARNING LEVEL: ${options.learningLevel.label}
TARGET COMIC PANELS: ${options.panelCount}
LANGUAGE: ${options.language}
VISUAL ART STYLE: ${options.visualStyle.label}

STUDY MATERIAL & RAW NOTES:
"""
$notesText
"""

INSTRUCTIONS:
1. Turn this academic material into an exciting, illustrated comic-book narrative with characters exploring the concepts first-hand.
2. The story must explain all key terms accurately without hallucinating or falsifying facts.
3. Every panel must have a rich, detailed visual description suitable for an image generator (describe characters, poses, background, lighting, and composition).
4. Dialogue should be conversational, dynamic, and educational.
5. Provide everyday analogies to demystify complex or abstract ideas.
6. Provide multiple-choice quiz questions based on the comic narrative with clear explanations.
7. Return raw JSON matching the required schema.
''';
  }
}

