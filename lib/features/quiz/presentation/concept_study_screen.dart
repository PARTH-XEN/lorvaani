import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../data/models/comic_story_model.dart';

/// Full-screen educational study card experience for key concepts and analogies
class ConceptStudyScreen extends StatelessWidget {
  final ComicStory story;

  const ConceptStudyScreen({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        backgroundColor: ComicColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ComicColors.softWhite),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story.storyTitle,
              style: ComicTypography.title(
                fontSize: 16,
                color: ComicColors.softWhite,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Concept Flashcards',
              style: ComicTypography.caption(color: ComicColors.skyCyan),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Top Concept Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ComicColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ComicColors.comicPurple, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ComicColors.comicPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: ComicColors.electricYellow,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CORE CONCEPTS & ANALOGIES',
                              style: ComicTypography.comicDisplay(
                                fontSize: 16,
                                color: ComicColors.electricYellow,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Master these principles before challenging the quiz!',
                              style: ComicTypography.caption(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Key Concepts Section
                if (story.keyConcepts.isNotEmpty) ...[
                  Text(
                    'DEFINITIONS & PRINCIPLES',
                    style: ComicTypography.comicDisplay(
                      fontSize: 18,
                      color: ComicColors.skyCyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...story.keyConcepts.map((concept) => _buildConceptCard(concept)),
                  const SizedBox(height: 24),
                ],

                // Analogies Section
                if (story.analogies.isNotEmpty) ...[
                  Text(
                    'EVERYDAY ANALOGIES',
                    style: ComicTypography.comicDisplay(
                      fontSize: 18,
                      color: ComicColors.vibrantOrange,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...story.analogies.map((analogy) => _buildAnalogyCard(analogy)),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),

          // Bottom Action to Jump to Quiz
          if (story.quizQuestions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: ComicColors.cardBackground,
              child: SafeArea(
                top: false,
                child: ComicButton(
                  text: 'Take The Quiz Now ➔',
                  icon: Icons.quiz_rounded,
                  variant: ComicButtonVariant.accent,
                  fullWidth: true,
                  onPressed: () {
                    context.pushReplacement('/quiz', extra: story);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConceptCard(ComicKeyConcept concept) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ComicPanel(
        backgroundColor: ComicColors.cardBackground,
        borderColor: ComicColors.comicPurple,
        borderWidth: 1.5,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: ComicColors.electricYellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    concept.term,
                    style: ComicTypography.title(
                      fontSize: 15,
                      color: ComicColors.electricYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              concept.definition,
              style: ComicTypography.body(
                color: ComicColors.softWhite,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalogyCard(ComicAnalogy analogy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ComicPanel(
        backgroundColor: ComicColors.cardBackground,
        borderColor: ComicColors.vibrantOrange,
        borderWidth: 1.5,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONCEPT: ${analogy.targetConcept.toUpperCase()}',
              style: ComicTypography.caption(
                color: ComicColors.vibrantOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '💡 ${analogy.everydayAnalogy}',
              style: ComicTypography.body(
                color: ComicColors.softWhite,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Why it works: ${analogy.whyItWorks}',
              style: ComicTypography.body(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

