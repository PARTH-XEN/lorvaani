import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../data/models/comic_story_model.dart';
import '../../library/presentation/controllers/library_controller.dart';
import '../data/comic_reader_state.dart';
import 'controllers/comic_reader_controller.dart';
import 'widgets/comic_panel_card.dart';
import 'widgets/concept_side_sheet.dart';
import 'widgets/expanded_panel_dialog.dart';

class ComicReaderScreen extends ConsumerStatefulWidget {
  final ComicStory story;

  const ComicReaderScreen({
    super.key,
    required this.story,
  });

  @override
  ConsumerState<ComicReaderScreen> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends ConsumerState<ComicReaderScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize reader state on next microtask
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(comicReaderControllerProvider.notifier).initialize(widget.story);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showConceptModal(BuildContext context, ComicStory story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConceptSideSheet(
        story: story,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showExpandedModal(BuildContext context, ComicPanelModel panel, String? visualStyle) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => ExpandedPanelDialog(
        panel: panel,
        visualStyle: visualStyle,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(comicReaderControllerProvider);
    final controller = ref.read(comicReaderControllerProvider.notifier);

    // Sync PageController when auto-play advances panel
    ref.listen<ComicReaderState>(comicReaderControllerProvider, (prev, next) {
      if (_pageController.hasClients &&
          next.currentPanelIndex != prev?.currentPanelIndex) {
        if (_pageController.page?.round() != next.currentPanelIndex) {
          _pageController.animateToPage(
            next.currentPanelIndex,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      }
    });

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
              widget.story.storyTitle,
              style: ComicTypography.title(
                fontSize: 16,
                color: ComicColors.softWhite,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.story.originalTopic,
              style: ComicTypography.caption(color: ComicColors.skyCyan),
            ),
          ],
        ),
        actions: [
          // Hands-free Auto-Play Full Story Audio
          IconButton(
            icon: Icon(
              readerState.isAutoPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              color: readerState.isAutoPlaying
                  ? ComicColors.vibrantOrange
                  : ComicColors.skyCyan,
            ),
            tooltip: readerState.isAutoPlaying
                ? 'Pause Hands-Free Story Audio'
                : 'Auto-Play Full Story Audio (Hands-Free)',
            onPressed: () => controller.toggleAutoPlayNarration(),
          ),

          // Reading mode switch (Horizontal Page vs Vertical Scroll)
          IconButton(
            icon: Icon(
              readerState.readingMode == ReadingMode.horizontalPage
                  ? Icons.view_carousel_rounded
                  : Icons.view_day_rounded,
              color: ComicColors.electricYellow,
            ),
            tooltip: readerState.readingMode == ReadingMode.horizontalPage
                ? 'Switch to Continuous Scroll'
                : 'Switch to Page-by-Page',
            onPressed: () => controller.toggleReadingMode(),
          ),

          // Audio narration toggle (TTS)
          IconButton(
            icon: Icon(
              readerState.isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
              color: readerState.isSpeaking ? ComicColors.comicPink : Colors.white70,
            ),
            tooltip: readerState.isSpeaking ? 'Stop Audio Narration' : 'Play Audio Narration',
            onPressed: () => controller.toggleAudioNarration(),
          ),

          // Save to Offline Library
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined, color: ComicColors.softWhite),
            tooltip: 'Save to Offline Library',
            onPressed: () async {
              final success = await ref
                  .read(libraryControllerProvider.notifier)
                  .saveStory(widget.story);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Saved "${widget.story.storyTitle}" to your offline library!'
                          : 'Story is already in your library.',
                      style: ComicTypography.body(color: Colors.white),
                    ),
                    backgroundColor: ComicColors.comicPurple,
                  ),
                );
              }
            },
          ),

          // Export Printable PDF Comic Book
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: ComicColors.skyCyan),
            tooltip: 'Export PDF Comic Book',
            onPressed: () async {
              await ref
                  .read(libraryControllerProvider.notifier)
                  .exportAndSharePdf(widget.story);
            },
          ),

          // Educational Concept Intel Drawer
          IconButton(
            icon: const Icon(Icons.school_rounded, color: ComicColors.electricYellow),
            tooltip: 'Educational Intel',
            onPressed: () => _showConceptModal(context, widget.story),
          ),
        ],
      ),
      body: Column(
        children: [
          // Auto-Play Active Notification Banner
          if (readerState.isAutoPlaying)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              color: ComicColors.vibrantOrange.withValues(alpha: 0.18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.record_voice_over_rounded,
                    size: 16,
                    color: ComicColors.vibrantOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hands-Free Narration: Panel ${readerState.currentPanelIndex + 1} of ${readerState.totalPanels}',
                    style: ComicTypography.caption(
                      color: ComicColors.vibrantOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // 1. Comic Reader Content
          Expanded(
            child: readerState.readingMode == ReadingMode.horizontalPage
                ? _buildHorizontalView(readerState, controller)
                : _buildVerticalView(widget.story, controller),
          ),

          // 2. Bottom Navigation & Progress Bar
          _buildBottomBar(context, readerState, controller),
        ],
      ),
    );
  }

  Widget _buildHorizontalView(ComicReaderState state, ComicReaderController controller) {
    final panels = widget.story.panels;

    return PageView.builder(
      controller: _pageController,
      itemCount: panels.length,
      onPageChanged: (index) {
        controller.goToPanel(index);
      },
      itemBuilder: (context, index) {
        final panel = panels[index];
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ComicPanelCard(
            panel: panel,
            visualStyle: widget.story.visualStyle,
            onExpand: () => _showExpandedModal(context, panel, widget.story.visualStyle),
            onSpeechBubbleTap: (dialogue) {
              controller.speakSingleDialogue(dialogue);
            },
          ),
        );
      },
    );
  }

  Widget _buildVerticalView(ComicStory story, ComicReaderController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: story.panels.length,
      itemBuilder: (context, index) {
        final panel = story.panels[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ComicPanelCard(
            panel: panel,
            visualStyle: story.visualStyle,
            onExpand: () => _showExpandedModal(context, panel, story.visualStyle),
            onSpeechBubbleTap: (dialogue) {
              controller.speakSingleDialogue(dialogue);
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ComicReaderState state,
    ComicReaderController controller,
  ) {
    final currentIndex = state.currentPanelIndex;
    final total = state.totalPanels;
    final isLast = state.isLastPanel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: ComicColors.cardBackground,
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Bar
            Row(
              children: [
                Text(
                  'PANEL ${currentIndex + 1} OF $total',
                  style: ComicTypography.caption(
                    color: ComicColors.electricYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.progressPercentage,
                      backgroundColor: ComicColors.deepCharcoal,
                      valueColor: const AlwaysStoppedAnimation(ComicColors.comicPurple),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Controls Row
            Row(
              children: [
                // Previous button
                if (state.readingMode == ReadingMode.horizontalPage) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                    color: state.isFirstPanel ? Colors.white24 : ComicColors.softWhite,
                    onPressed: state.isFirstPanel
                        ? null
                        : () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                  ),
                  const SizedBox(width: 8),
                ],

                // Center Quiz button or Next button
                Expanded(
                  child: isLast
                      ? ComicButton(
                          text: 'Take The Quiz ➔',
                          variant: ComicButtonVariant.accent,
                          onPressed: () {
                            context.push('/quiz', extra: widget.story);
                          },
                        )
                      : (state.readingMode == ReadingMode.horizontalPage
                          ? ComicButton(
                              text: 'Next Panel ➔',
                              variant: ComicButtonVariant.primary,
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            )
                          : const SizedBox.shrink()),
                ),

                // Next button in horizontal mode
                if (state.readingMode == ReadingMode.horizontalPage && !isLast) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    color: isLast ? Colors.white24 : ComicColors.softWhite,
                    onPressed: isLast
                        ? null
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
