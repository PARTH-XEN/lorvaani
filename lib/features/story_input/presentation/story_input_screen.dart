import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/ai_settings_dialog.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/comic_speech_bubble.dart';
import '../../../core/widgets/halftone_container.dart';
import '../data/story_input_state.dart';
import 'controllers/story_input_controller.dart';
import 'widgets/extracted_text_review_sheet.dart';
import 'widgets/input_action_bar.dart';

/// Full Interactive Learning Material Input Screen
class StoryInputScreen extends ConsumerStatefulWidget {
  const StoryInputScreen({super.key});

  @override
  ConsumerState<StoryInputScreen> createState() => _StoryInputScreenState();
}

class _StoryInputScreenState extends ConsumerState<StoryInputScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(storyInputControllerProvider);
    _titleController = TextEditingController(text: initialState.topicTitle);
    _notesController = TextEditingController(text: initialState.notesText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showReviewSheet(BuildContext context, dynamic result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ExtractedTextReviewSheet(
          result: result,
          onAccept: (editedText) {
            ref.read(storyInputControllerProvider.notifier).acceptExtractedResult(
                  result,
                  editedText: editedText,
                );
            _notesController.text = editedText;
            if (_titleController.text.isEmpty && result.suggestedTitle != null) {
              _titleController.text = result.suggestedTitle!;
            }
            Navigator.pop(context);
          },
          onDismiss: () {
            ref.read(storyInputControllerProvider.notifier).dismissExtractedResult();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storyInputControllerProvider);
    final controller = ref.read(storyInputControllerProvider.notifier);

    // Keep text controllers synchronized if state was updated externally (e.g. paste, sample, OCR)
    if (_titleController.text != state.topicTitle) {
      _titleController.text = state.topicTitle;
    }
    if (_notesController.text != state.notesText) {
      _notesController.text = state.notesText;
    }

    // Trigger review sheet if new extracted result arrives
    ref.listen<StoryInputState>(storyInputControllerProvider, (prev, next) {
      if (next.lastExtractedResult != null &&
          next.lastExtractedResult != prev?.lastExtractedResult) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showReviewSheet(context, next.lastExtractedResult);
        });
      }
    });

    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          'INPUT STUDY MATERIAL',
          style: ComicTypography.comicDisplay(fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_rounded,
                color: ComicColors.electricYellow),
            tooltip: 'AI Key / Settings',
            onPressed: () => AiSettingsDialog.show(context),
          ),
          if (state.notesText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Clear All',
              onPressed: () {
                _titleController.clear();
                _notesController.clear();
                controller.clearAll();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Speech Bubble Tip
                const ComicSpeechBubble(
                  tailDirection: BubbleTailDirection.bottomLeft,
                  child: Text(
                    'Paste notes, scan textbook pages, or upload PDFs. Lorvani will turn your facts into a comic universe!',
                    style: TextStyle(
                      color: ComicColors.deepCharcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Validation or Extraction Error Banner
                if (state.validationError != null || state.extractionError != null) ...[
                  ComicPanel(
                    backgroundColor: const Color(0xFF381923),
                    borderColor: Colors.redAccent,
                    borderRadius: 12,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.validationError ?? state.extractionError!,
                            style: ComicTypography.body(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Topic Title Input
                Text(
                  'TOPIC OR LESSON TITLE',
                  style: ComicTypography.comicDisplay(
                    fontSize: 15,
                    color: ComicColors.comicPink,
                  ),
                ),
                const SizedBox(height: 6),
                ComicPanel(
                  backgroundColor: ComicColors.cardBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  borderRadius: 14,
                  shadowOffset: const Offset(3, 3),
                  child: TextField(
                    controller: _titleController,
                    onChanged: controller.setTopicTitle,
                    style: ComicTypography.heading(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'e.g. Photosynthesis, Newton\'s Laws, French Revolution...',
                      hintStyle: ComicTypography.body(
                        color: ComicColors.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sample Templates Quick-Load
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Try sample notes:',
                      style: ComicTypography.caption(
                        color: ComicColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '1-Tap Load',
                      style: ComicTypography.caption(
                        color: ComicColors.electricYellow,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: StoryInputState.sampleTemplates.map((template) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            controller.loadSample(template);
                            _titleController.text = template.title;
                            _notesController.text = template.content;
                          },
                          child: BadgeChip(
                            label: '${template.subject}: ${template.title}',
                            icon: Icons.auto_awesome_rounded,
                            backgroundColor: ComicColors.surfaceLight,
                            textColor: ComicColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Action Bar (Paste, Camera, Gallery, PDF, Clear)
                InputActionBar(
                  onPaste: controller.pasteFromClipboard,
                  onCameraScan: controller.scanWithCamera,
                  onGalleryImport: controller.importFromGallery,
                  onPdfImport: controller.importPdfDocument,
                  onClear: () {
                    _notesController.clear();
                    controller.setNotesText('');
                  },
                  hasContent: state.notesText.isNotEmpty,
                ),
                const SizedBox(height: 14),

                // Study Notes Editor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STUDY NOTES / TEXTBOOK CONTENT',
                      style: ComicTypography.comicDisplay(
                        fontSize: 15,
                        color: ComicColors.skyCyan,
                      ),
                    ),
                    BadgeChip(
                      label: '${state.wordCount} words (${state.characterCount} chars)',
                      fontSize: 10,
                      backgroundColor: ComicColors.surfaceLight,
                      textColor: ComicColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                ComicPanel(
                  backgroundColor: ComicColors.cardBackground,
                  padding: const EdgeInsets.all(12),
                  borderRadius: 16,
                  shadowOffset: const Offset(4, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(minHeight: 180),
                        child: TextField(
                          controller: _notesController,
                          onChanged: (val) => controller.setNotesText(val),
                          maxLines: null,
                          style: ComicTypography.body(fontSize: 14, height: 1.5),
                          decoration: InputDecoration(
                            hintText:
                                'Paste your study notes here, or use the buttons above to scan a textbook page or import a PDF file...\n\nExample:\n• Concept definition\n• Key formulas or equations\n• Historical dates & narrative',
                            hintStyle: ComicTypography.body(
                              color: ComicColors.textMuted,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Divider(color: ComicColors.surfaceLight, height: 20),
                      // Content Health Indicator
                      Row(
                        children: [
                          Icon(
                            state.isValidForGeneration
                                ? Icons.check_circle_rounded
                                : Icons.info_outline_rounded,
                            size: 14,
                            color: state.isValidForGeneration
                                ? Colors.greenAccent
                                : ComicColors.vibrantOrange,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.contentHealthLabel,
                              style: ComicTypography.caption(
                                fontSize: 11,
                                color: state.isValidForGeneration
                                    ? Colors.greenAccent
                                    : ComicColors.vibrantOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Button: Proceed
                ComicButton(
                  text: 'Customize Comic Story',
                  icon: Icons.brush_rounded,
                  variant: ComicButtonVariant.gradient,
                  fullWidth: true,
                  onPressed: () {
                    final isValid = controller.validateAndProceed();
                    if (isValid) {
                      context.push('/customize');
                    }
                  },
                ),
              ],
            ),

            // Extraction Loading Overlay
            if (state.isExtracting)
              Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: Center(
                  child: ComicPanel(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 20,
                    child: HalftoneContainer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: ComicColors.comicPink,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'EXTRACTING DOCUMENT',
                            style: ComicTypography.comicDisplay(
                              fontSize: 18,
                              color: ComicColors.skyCyan,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Parsing text layer & normalizing layout...',
                            style: ComicTypography.caption(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

