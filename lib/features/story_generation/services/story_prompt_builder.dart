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

CRITICAL INSTRUCTIONS:
1. LANGUAGE: The user requested "${options.language}". You MUST write the storyTitle, shortIntroduction, panel titles, narration, dialogues, key concepts, analogies, summary, and quiz questions in ${options.language}.
2. GENRE & COMIC TROPES: Match the tone, character personalities, and dialogue style to "${options.visualStyle.label}":
   - Anime-inspired: High-energy Shonen manga style, enthusiastic student & dramatic mentor, special attack-like technique names, emotional epiphanies.
   - Classic Comic: 90s Superhero graphic novel (Marvel/DC style), superhero alias names, epic hero vs villain dilemma, bold dynamic punchiness.
   - Cartoon: Lighthearted, slapstick, funny inventions, playful witty dialogue, goofy animated cartoon charm.
   - Storybook: Whimsical enchanted fairy-tale, glowing nature wonder, poetic storytelling, gentle warmth.
   - Cinematic Comic: Gritty, atmospheric, high-stakes tactical mission briefing, cinematic pacing.
3. STORY ARC: The story must explain the topic step-by-step through a complete 4-act progression (Inciting Mystery -> Microscopic/Deeper Descent -> Climax/Catalyst Transformation -> Output Harvest & Epiphany).
4. PANELS: Create exactly ${options.panelCount} progressive panels with unique titles, unique narrations, and unique character dialogue.
5. ACCURACY: Accurately teach the scientific, historical, or academic facts from the study material without hallucinations.
6. OUTPUT: Return raw JSON matching the required schema.
''';
  }
}
