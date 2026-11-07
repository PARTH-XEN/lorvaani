import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';
import '../../../../data/models/comic_story_model.dart';

/// Educational concept drawer / bottom sheet showing definitions, analogies, and character dossiers
class ConceptSideSheet extends StatelessWidget {
  final ComicStory story;
  final VoidCallback onClose;

  const ConceptSideSheet({
    super.key,
    required this.story,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: ComicColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: ComicColors.comicPurple, width: 3),
          left: BorderSide(color: ComicColors.comicPurple, width: 2),
          right: BorderSide(color: ComicColors.comicPurple, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ComicColors.comicPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: ComicColors.electricYellow,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EDUCATIONAL INTEL',
                        style: ComicTypography.comicDisplay(
                          fontSize: 18,
                          color: ComicColors.electricYellow,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        story.originalTopic,
                        style: ComicTypography.caption(color: ComicColors.skyCyan),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: ComicColors.softWhite),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          const Divider(color: ComicColors.deepCharcoal, thickness: 2),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // 1. Key Concepts
                if (story.keyConcepts.isNotEmpty) ...[
                  _buildSectionHeader('KEY CONCEPTS', Icons.lightbulb_outline),
                  const SizedBox(height: 8),
                  ...story.keyConcepts.map((concept) => _buildConceptCard(concept)),
                  const SizedBox(height: 16),
                ],

                // 2. Analogies
                if (story.analogies.isNotEmpty) ...[
                  _buildSectionHeader('EVERYDAY ANALOGIES', Icons.compare_arrows_rounded),
                  const SizedBox(height: 8),
                  ...story.analogies.map((analogy) => _buildAnalogyCard(analogy)),
                  const SizedBox(height: 16),
                ],

                // 3. Characters Dossier
                if (story.characters.isNotEmpty) ...[
                  _buildSectionHeader('CHARACTER DOSSIER', Icons.groups_rounded),
                  const SizedBox(height: 8),
                  ...story.characters.map((char) => _buildCharacterCard(char)),
                  const SizedBox(height: 16),
                ],

                // 4. Story Summary
                if (story.summary.isNotEmpty) ...[
                  _buildSectionHeader('MISSION SUMMARY', Icons.auto_stories_rounded),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ComicColors.deepCharcoal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ComicColors.comicPurple, width: 1.5),
                    ),
                    child: Text(
                      story.summary,
                      style: ComicTypography.body(
                        color: ComicColors.softWhite,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ComicColors.skyCyan),
        const SizedBox(width: 8),
        Text(
          title,
          style: ComicTypography.comicDisplay(
            fontSize: 15,
            color: ComicColors.skyCyan,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildConceptCard(ComicKeyConcept concept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ComicColors.deepCharcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ComicColors.comicPurple.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 14, color: ComicColors.electricYellow),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  concept.term,
                  style: ComicTypography.title(
                    color: ComicColors.electricYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            concept.definition,
            style: ComicTypography.body(
              color: ComicColors.softWhite,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalogyCard(ComicAnalogy analogy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ComicColors.deepCharcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ComicColors.vibrantOrange.withValues(alpha: 0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Concept: ${analogy.targetConcept}',
            style: ComicTypography.caption(
              color: ComicColors.vibrantOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '💡 Analogy: ${analogy.everydayAnalogy}',
            style: ComicTypography.body(
              color: ComicColors.softWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }

  Widget _buildCharacterCard(ComicCharacter char) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ComicColors.deepCharcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ComicColors.comicPink.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: ComicColors.comicPurple,
            child: Text(
              char.name.isNotEmpty ? char.name[0].toUpperCase() : '?',
              style: ComicTypography.comicDisplay(
                fontSize: 16,
                color: ComicColors.electricYellow,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  char.name,
                  style: ComicTypography.title(
                    color: ComicColors.comicPink,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  char.role,
                  style: ComicTypography.caption(color: ComicColors.skyCyan),
                ),
                if (char.visualDescription.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    char.visualDescription,
                    style: ComicTypography.body(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

