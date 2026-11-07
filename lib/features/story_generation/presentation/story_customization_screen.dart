import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/ai/ai_provider_types.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/comic_trial_gate_dialog.dart';
import '../../story_input/presentation/controllers/story_input_controller.dart';
import 'controllers/story_generation_controller.dart';

/// Story Customization Screen allowing selection of level, visual art style, length, and language
class StoryCustomizationScreen extends ConsumerStatefulWidget {
  const StoryCustomizationScreen({super.key});

  @override
  ConsumerState<StoryCustomizationScreen> createState() =>
      _StoryCustomizationScreenState();
}

class _StoryCustomizationScreenState
    extends ConsumerState<StoryCustomizationScreen> {
  late LearningLevel _level;
  late ComicVisualStyle _style;
  late StoryLength _length;
  late String _language;

  @override
  void initState() {
    super.initState();
    final currentOpts =
        ref.read(storyGenerationControllerProvider).options;
    _level = currentOpts.learningLevel;
    _style = currentOpts.visualStyle;
    _length = currentOpts.storyLength;
    _language = currentOpts.language;
  }

  Future<void> _onGeneratePressed() async {
    final allowed =
        await ComicTrialGateDialog.checkAndEnforceTrial(context, ref);
    if (!allowed || !mounted) return;

    final opts = StoryGenerationOptions(
      learningLevel: _level,
      visualStyle: _style,
      storyLength: _length,
      panelCount: _length.defaultPanelCount,
      language: _language,
    );

    ref.read(storyGenerationControllerProvider.notifier).updateOptions(opts);
    context.push('/generate-progress');
  }

  @override
  Widget build(BuildContext context) {
    final inputState = ref.watch(storyInputControllerProvider);

    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          'STORY CUSTOMIZER',
          style: ComicTypography.comicDisplay(fontSize: 22),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Selected Topic Overview Pill
            ComicPanel(
              backgroundColor: ComicColors.cardBackground,
              borderColor: ComicColors.comicPurple.withValues(alpha: 0.6),
              borderRadius: 14,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ComicColors.comicPurple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: ComicColors.comicPink,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inputState.topicTitle.isEmpty
                              ? 'Your Educational Story'
                              : inputState.topicTitle,
                          style: ComicTypography.title(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${inputState.wordCount} words of study notes ready',
                          style: ComicTypography.caption(
                            color: ComicColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Learning Level
            Text(
              '1. LEARNING LEVEL',
              style: ComicTypography.comicDisplay(
                fontSize: 15,
                color: ComicColors.electricYellow,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: LearningLevel.values.map((lvl) {
                final isSelected = _level == lvl;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _level = lvl),
                      child: ComicPanel(
                        backgroundColor: isSelected
                            ? ComicColors.comicPurple
                            : ComicColors.cardBackground,
                        borderColor: isSelected
                            ? ComicColors.softWhite
                            : ComicColors.comicBorder,
                        borderWidth: isSelected ? 2.5 : 1.5,
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 12),
                        child: Center(
                          child: Text(
                            lvl.label,
                            style: ComicTypography.caption(
                              fontSize: 12,
                              color: isSelected
                                  ? ComicColors.softWhite
                                  : ComicColors.textPrimary,
                            ).copyWith(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 2. Visual Art Style
            Text(
              '2. COMIC ART STYLE',
              style: ComicTypography.comicDisplay(
                fontSize: 15,
                color: ComicColors.skyCyan,
              ),
            ),
            const SizedBox(height: 8),
            ...ComicVisualStyle.values.map((style) {
              final isSelected = _style == style;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _style = style),
                  child: ComicPanel(
                    backgroundColor: isSelected
                        ? const Color(0xFF2E204A)
                        : ComicColors.cardBackground,
                    borderColor: isSelected
                        ? ComicColors.comicPink
                        : ComicColors.comicBorder,
                    borderWidth: isSelected ? 2.2 : 1.5,
                    borderRadius: 14,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? ComicColors.comicPink
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? ComicColors.softWhite
                                  : ComicColors.textSecondary,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                style.label,
                                style: ComicTypography.title(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                style.promptStyleModifier,
                                style: ComicTypography.caption(
                                  fontSize: 11,
                                  color: ComicColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // 3. Story Length & Panel Count
            Text(
              '3. STORY LENGTH',
              style: ComicTypography.comicDisplay(
                fontSize: 15,
                color: ComicColors.vibrantOrange,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: StoryLength.values.map((len) {
                final isSelected = _length == len;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _length = len),
                      child: ComicPanel(
                        backgroundColor: isSelected
                            ? const Color(0xFF3B2618)
                            : ComicColors.cardBackground,
                        borderColor: isSelected
                            ? ComicColors.vibrantOrange
                            : ComicColors.comicBorder,
                        borderWidth: isSelected ? 2.2 : 1.5,
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              len.name.toUpperCase(),
                              style: ComicTypography.caption(
                                fontSize: 11,
                                color: isSelected
                                    ? ComicColors.vibrantOrange
                                    : ComicColors.textPrimary,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            BadgeChip(
                              label: '${len.defaultPanelCount} Panels',
                              fontSize: 9,
                              backgroundColor: ComicColors.surfaceLight,
                              textColor: isSelected
                                  ? ComicColors.vibrantOrange
                                  : ComicColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Language Selection
            Text(
              '4. LANGUAGE',
              style: ComicTypography.comicDisplay(
                fontSize: 15,
                color: ComicColors.comicPurple,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['English', 'Spanish', 'French', 'German', 'Hindi']
                    .map((lang) {
                  final isSelected = _language == lang;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _language = lang),
                      child: BadgeChip(
                        label: lang,
                        backgroundColor: isSelected
                            ? ComicColors.comicPurple
                            : ComicColors.cardBackground,
                        textColor: isSelected
                            ? ComicColors.softWhite
                            : ComicColors.textPrimary,
                        borderColor: isSelected
                            ? ComicColors.softWhite
                            : ComicColors.comicBorder,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // Generate Button
            ComicButton(
              text: 'Generate Comic Story',
              icon: Icons.auto_awesome_rounded,
              variant: ComicButtonVariant.gradient,
              fullWidth: true,
              onPressed: _onGeneratePressed,
            ),
          ],
        ),
      ),
    );
  }
}
