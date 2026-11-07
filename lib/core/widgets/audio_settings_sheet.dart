import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/comic_reader/presentation/controllers/comic_reader_controller.dart';
import '../services/audio/comic_tts_service.dart';
import '../theme/comic_colors.dart';
import '../theme/comic_typography.dart';
import 'comic_button.dart';
import 'comic_panel.dart';

/// Modal bottom sheet allowing users to adjust audio volume and switch between 3 voice personas
class AudioSettingsSheet extends ConsumerStatefulWidget {
  final String? storyLanguage;

  const AudioSettingsSheet({
    super.key,
    this.storyLanguage,
  });

  static Future<void> show(BuildContext context, {String? storyLanguage}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AudioSettingsSheet(storyLanguage: storyLanguage),
    );
  }

  @override
  ConsumerState<AudioSettingsSheet> createState() => _AudioSettingsSheetState();
}

class _AudioSettingsSheetState extends ConsumerState<AudioSettingsSheet> {
  late double _currentVolume;
  late VoicePersona _currentPersona;

  @override
  void initState() {
    super.initState();
    final tts = ref.read(comicTtsServiceProvider);
    _currentVolume = tts.volume;
    _currentPersona = tts.persona;
  }

  Future<void> _updateVolume(double value) async {
    setState(() => _currentVolume = value);
    final tts = ref.read(comicTtsServiceProvider);
    await tts.setVolume(value);
  }

  Future<void> _updatePersona(VoicePersona persona) async {
    setState(() => _currentPersona = persona);
    final tts = ref.read(comicTtsServiceProvider);
    await tts.setVoicePersona(persona);
  }

  Future<void> _testVoice() async {
    final tts = ref.read(comicTtsServiceProvider);
    final isHindi = widget.storyLanguage?.toLowerCase() == 'hindi';
    final sampleText = isHindi
        ? 'नमस्ते! मैं आपकी कॉमिक कहानी का वाचक हूँ।'
        : 'Welcome! I am the voice of your illustrated comic universe.';

    await tts.stop();
    await tts.speak(sampleText, language: widget.storyLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ComicColors.deepCharcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ComicColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ComicColors.vibrantOrange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: ComicColors.vibrantOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AUDIO & VOICE SETTINGS',
                    style: ComicTypography.comicDisplay(
                      fontSize: 18,
                      color: ComicColors.electricYellow,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: ComicColors.softWhite),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. Volume Adjuster
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume Adjuster',
                style: ComicTypography.title(fontSize: 14, color: ComicColors.skyCyan),
              ),
              Text(
                '${(_currentVolume * 100).toInt()}%',
                style: ComicTypography.caption(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ComicColors.softWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                _currentVolume == 0
                    ? Icons.volume_off_rounded
                    : _currentVolume < 0.5
                        ? Icons.volume_down_rounded
                        : Icons.volume_up_rounded,
                color: ComicColors.skyCyan,
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: _currentVolume,
                  min: 0.0,
                  max: 1.0,
                  activeColor: ComicColors.skyCyan,
                  inactiveColor: ComicColors.surfaceLight,
                  onChanged: _updateVolume,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Voice Persona Selector (3 styles)
          Text(
            'Voice Persona (3 Styles)',
            style: ComicTypography.title(fontSize: 14, color: ComicColors.comicPink),
          ),
          const SizedBox(height: 8),
          ...VoicePersona.values.map((persona) {
            final isSelected = _currentPersona == persona;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _updatePersona(persona),
                child: ComicPanel(
                  backgroundColor: isSelected
                      ? const Color(0xFF2E1C38)
                      : ComicColors.cardBackground,
                  borderColor: isSelected
                      ? ComicColors.comicPink
                      : ComicColors.comicBorder,
                  borderWidth: isSelected ? 2.0 : 1.2,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ComicColors.comicPink
                              : ComicColors.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          persona == VoicePersona.nova
                              ? Icons.school_rounded
                              : persona == VoicePersona.sage
                                  ? Icons.auto_awesome_rounded
                                  : Icons.bolt_rounded,
                          size: 16,
                          color: isSelected ? Colors.white : ComicColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              persona.displayName,
                              style: ComicTypography.title(
                                fontSize: 13,
                                color: isSelected
                                    ? ComicColors.softWhite
                                    : ComicColors.textPrimary,
                              ),
                            ),
                            Text(
                              persona.description,
                              style: ComicTypography.caption(
                                fontSize: 11,
                                color: ComicColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: ComicColors.comicPink,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),

          // Test Voice Button
          ComicButton(
            text: 'Preview Voice',
            icon: Icons.play_arrow_rounded,
            variant: ComicButtonVariant.primary,
            onPressed: _testVoice,
          ),
        ],
      ),
    );
  }
}

