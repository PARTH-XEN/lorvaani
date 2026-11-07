import '../../../../core/services/ai/ai_provider_types.dart';
import '../../../../data/models/comic_story_model.dart';

/// Prompt engineering service that synthesizes comic panel scene descriptions,
/// character continuity details, and art style tokens into unified image generation prompts.
class ComicImagePromptService {
  const ComicImagePromptService();

  /// Converts string style names to strongly-typed [ComicVisualStyle] enum
  ComicVisualStyle resolveVisualStyle(String styleName) {
    final normalized = styleName.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (normalized.contains('anime')) {
      return ComicVisualStyle.animeInspired;
    } else if (normalized.contains('cartoon')) {
      return ComicVisualStyle.cartoon;
    } else if (normalized.contains('storybook')) {
      return ComicVisualStyle.storybook;
    } else if (normalized.contains('cinematic')) {
      return ComicVisualStyle.cinematicComic;
    } else {
      return ComicVisualStyle.classicComic;
    }
  }

  /// Detailed art style prompt modifiers designed for graphic novel consistency
  String getDetailedStyleModifier(ComicVisualStyle style) {
    switch (style) {
      case ComicVisualStyle.classicComic:
        return 'vintage modern graphic novel illustration, bold ink lineart, authentic halftone screen textures, vibrant flat color palettes, dynamic dynamic superhero comic aesthetic, crisp shadows';
      case ComicVisualStyle.animeInspired:
        return 'high-end modern anime keyframe art, crisp cel shading, emotive expressive eyes, vivid cinematic lighting, clean sharp outlines, Makoto Shinkai atmosphere';
      case ComicVisualStyle.cartoon:
        return 'whimsical high-energy modern cartoon illustration, friendly exaggerated proportions, vibrant joyful palette, clean rounded vector ink lines, playful animated style';
      case ComicVisualStyle.storybook:
        return 'enchanting children storybook illustration, textured gouache and watercolor finish, warm dreamy lighting, whimsical soft contours, cozy fairytale aesthetic';
      case ComicVisualStyle.cinematicComic:
        return 'gritty cinematic graphic novel masterpiece, dramatic rim lighting, chiaroscuro atmosphere, intricate hatch shading, wide angle depth of field, photorealistic ink details';
    }
  }

  /// Builds a combined character consistency prompt from story character definitions
  String buildCharacterConsistencyPrompt(List<ComicCharacter> characters) {
    if (characters.isEmpty) return '';

    final characterSummaries = characters.map((c) {
      final desc = c.visualDescription.trim();
      return '${c.name} (${c.role}${desc.isNotEmpty ? ', $desc' : ''})';
    }).join('; ');

    return 'Characters visual continuity: $characterSummaries';
  }

  /// Calculates a stable, deterministic seed from story and character traits.
  /// Using identical seeds across panels of a story minimizes character drift.
  int calculateStorySeed(ComicStory story) {
    final seedString = '${story.id}_${story.characters.map((c) => c.name).join('_')}_${story.visualStyle}';
    return seedString.hashCode.abs() % 10000000;
  }

  /// Assembles the complete, optimized prompt for an individual comic panel
  String assemblePanelPrompt({
    required ComicStory story,
    required ComicPanelModel panel,
  }) {
    final style = resolveVisualStyle(story.visualStyle);
    final styleModifier = getDetailedStyleModifier(style);
    final characterDetails = buildCharacterConsistencyPrompt(story.characters);

    final buffer = StringBuffer();

    // 1. Core Scene Action & Setting
    buffer.write('Comic book panel: ${panel.panelDescription.trim()}');

    // 2. Setting Context
    if (story.storySetting.trim().isNotEmpty) {
      buffer.write('. Setting: ${story.storySetting.trim()}');
    }

    // 3. Visual Cue Emphasis
    if (panel.keyVisualCue.trim().isNotEmpty) {
      buffer.write('. Key visual focal point: ${panel.keyVisualCue.trim()}');
    }

    // 4. Character Visual Continuity
    if (characterDetails.isNotEmpty) {
      buffer.write('. $characterDetails');
    }

    // 5. Art Style Specification
    buffer.write('. Style: $styleModifier');

    // 6. Quality & Negative Constraints
    buffer.write(
      '. Masterpiece, highly detailed graphic novel illustration, clean composition, '
      'no text in artwork, no speech bubbles in illustration, no blur, no low-resolution artifacts.',
    );

    return buffer.toString();
  }
}
