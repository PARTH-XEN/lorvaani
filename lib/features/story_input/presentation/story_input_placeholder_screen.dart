import 'package:flutter/material.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/comic_speech_bubble.dart';

/// Story Input Screen - Milestone 3 Hub
class StoryInputPlaceholderScreen extends StatelessWidget {
  const StoryInputPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          'CREATE YOUR STORY',
          style: ComicTypography.comicDisplay(fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ComicSpeechBubble(
            tailDirection: BubbleTailDirection.bottomLeft,
            child: Text(
              'Input your study notes or scan documents to generate an AI comic!',
              style: TextStyle(color: ComicColors.deepCharcoal, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          ComicPanel(
            padding: const EdgeInsets.all(20),
            borderRadius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Material Input',
                  style: ComicTypography.heading(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Paste your notes or textbook text below. In Milestone 3, camera scanning, OCR, and PDF import will be activated.',
                  style: ComicTypography.body(color: ComicColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ComicColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ComicColors.comicBorder, width: 1.5),
                  ),
                  child: TextField(
                    maxLines: null,
                    style: ComicTypography.body(),
                    decoration: InputDecoration(
                      hintText: 'Enter topic or paste notes here (e.g. How does photosynthesis work?)...',
                      hintStyle: ComicTypography.body(color: ComicColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ComicButton(
                        text: 'Scan Notes',
                        icon: Icons.camera_alt_rounded,
                        variant: ComicButtonVariant.dark,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Camera scanning & OCR ready for Milestone 3!'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ComicButton(
                        text: 'Import PDF',
                        icon: Icons.picture_as_pdf_rounded,
                        variant: ComicButtonVariant.dark,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PDF document parser ready for Milestone 3!'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ComicButton(
                  text: 'Generate Comic Story',
                  icon: Icons.auto_awesome_rounded,
                  variant: ComicButtonVariant.gradient,
                  fullWidth: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AI Story generation pipeline unlocks in Milestone 4!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
