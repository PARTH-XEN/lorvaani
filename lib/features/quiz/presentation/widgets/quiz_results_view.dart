import 'package:flutter/material.dart';
import '../../../../core/theme/comic_colors.dart';
import '../../../../core/theme/comic_typography.dart';
import '../../../../core/widgets/comic_button.dart';
import '../../../../core/widgets/comic_panel.dart';
import '../../data/quiz_session_state.dart';

/// Fullscreen celebration and score breakdown view after completing a comic quiz
class QuizResultsView extends StatelessWidget {
  final QuizSessionState sessionState;
  final VoidCallback onRetake;
  final VoidCallback onReviewConcepts;
  final VoidCallback onBackToStory;

  const QuizResultsView({
    super.key,
    required this.sessionState,
    required this.onRetake,
    required this.onReviewConcepts,
    required this.onBackToStory,
  });

  @override
  Widget build(BuildContext context) {
    final story = sessionState.story;
    final total = sessionState.totalQuestions;
    final score = sessionState.score;
    final pct = sessionState.percentageScore;

    Color badgeColor = ComicColors.electricYellow;
    if (sessionState.masteryTier == MasteryTier.comicNovice) {
      badgeColor = ComicColors.vibrantOrange;
    } else if (sessionState.masteryTier == MasteryTier.heroInTraining) {
      badgeColor = ComicColors.skyCyan;
    } else if (sessionState.masteryTier == MasteryTier.comicMastermind) {
      badgeColor = ComicColors.comicPurple;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Celebration Banner
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: ComicColors.vibrantOrange,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 3), blurRadius: 0),
                ],
              ),
              child: Text(
                'MISSION COMPLETE!',
                style: ComicTypography.comicDisplay(
                  fontSize: 22,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Score & Mastery Panel
          ComicPanel(
            backgroundColor: ComicColors.cardBackground,
            borderColor: badgeColor,
            borderWidth: 2.5,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Score Circle
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ComicColors.deepCharcoal,
                    shape: BoxShape.circle,
                    border: Border.all(color: badgeColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score/$total',
                        style: ComicTypography.title(
                          fontSize: 24,
                          color: ComicColors.softWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: ComicTypography.caption(
                          fontSize: 13,
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Mastery Tier Title
                Text(
                  sessionState.masteryTitle,
                  textAlign: TextAlign.center,
                  style: ComicTypography.comicDisplay(
                    fontSize: 24,
                    color: badgeColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Mastery Description
                Text(
                  sessionState.masteryDescription,
                  textAlign: TextAlign.center,
                  style: ComicTypography.body(
                    color: ComicColors.softWhite,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Concepts Mastered Section
          if (story != null && story.keyConcepts.isNotEmpty) ...[
            Text(
              'CONCEPT MASTERY',
              style: ComicTypography.comicDisplay(
                fontSize: 16,
                color: ComicColors.skyCyan,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            ...story.keyConcepts.map((concept) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: ComicColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ComicColors.comicPurple.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        concept.term,
                        style: ComicTypography.title(
                          fontSize: 14,
                          color: ComicColors.softWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],

          // 4. Action CTAs
          ComicButton(
            text: 'Review Key Concepts',
            icon: Icons.school_rounded,
            variant: ComicButtonVariant.primary,
            fullWidth: true,
            onPressed: onReviewConcepts,
          ),
          const SizedBox(height: 10),
          ComicButton(
            text: 'Retake Quiz',
            icon: Icons.refresh_rounded,
            variant: ComicButtonVariant.accent,
            fullWidth: true,
            onPressed: onRetake,
          ),
          const SizedBox(height: 10),
          ComicButton(
            text: 'Back to Story',
            icon: Icons.auto_stories_rounded,
            variant: ComicButtonVariant.dark,
            fullWidth: true,
            onPressed: onBackToStory,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

