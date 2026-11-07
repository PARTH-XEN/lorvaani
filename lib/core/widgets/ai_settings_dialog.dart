import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai/ai_config_service.dart';
import '../theme/comic_colors.dart';
import '../theme/comic_typography.dart';
import 'comic_button.dart';
import 'comic_panel.dart';

/// Interactive modal allowing users to enter, test, and save their Gemini / Groq API Keys.
class AiSettingsDialog extends ConsumerStatefulWidget {
  const AiSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => const AiSettingsDialog(),
    );
  }

  @override
  ConsumerState<AiSettingsDialog> createState() => _AiSettingsDialogState();
}

class _AiSettingsDialogState extends ConsumerState<AiSettingsDialog> {
  late TextEditingController _geminiController;
  late TextEditingController _groqController;
  bool _obscureGemini = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(aiConfigServiceProvider);
    _geminiController =
        TextEditingController(text: config.getGeminiApiKey() ?? '');
    _groqController = TextEditingController(text: config.getGroqApiKey() ?? '');
  }

  @override
  void dispose() {
    _geminiController.dispose();
    _groqController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final config = ref.read(aiConfigServiceProvider);

    await config.setGeminiApiKey(_geminiController.text.trim());
    await config.setGroqApiKey(_groqController.text.trim());

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ComicColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          content: Text(
            config.hasLiveKeyConfigured
                ? '⚡ AI Connected! Using ${config.activeProviderName}'
                : 'Using Offline Comic Story Engine',
            style: ComicTypography.body(
              color: ComicColors.electricYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(aiConfigServiceProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ComicPanel(
        backgroundColor: ComicColors.cardBackground,
        borderColor: ComicColors.comicPurple,
        borderWidth: 2.5,
        borderRadius: 20,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ComicColors.comicPurple.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.vpn_key_rounded,
                          color: ComicColors.electricYellow,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AI SETTINGS',
                        style: ComicTypography.comicDisplay(
                          fontSize: 20,
                          color: ComicColors.electricYellow,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: ComicColors.softWhite),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Active Engine Status Banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: ComicColors.deepCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: config.hasLiveKeyConfigured
                        ? ComicColors.skyCyan
                        : ComicColors.vibrantOrange,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      config.hasLiveKeyConfigured
                          ? Icons.check_circle_rounded
                          : Icons.offline_bolt_rounded,
                      color: config.hasLiveKeyConfigured
                          ? ComicColors.skyCyan
                          : ComicColors.vibrantOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Engine',
                            style: ComicTypography.caption(
                              fontSize: 10,
                              color: ComicColors.textSecondary,
                            ),
                          ),
                          Text(
                            config.activeProviderName,
                            style: ComicTypography.title(
                              fontSize: 13,
                              color: ComicColors.softWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Gemini API Key Input
              Text(
                'Google Gemini API Key',
                style: ComicTypography.title(
                  fontSize: 14,
                  color: ComicColors.skyCyan,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _geminiController,
                obscureText: _obscureGemini,
                style: ComicTypography.body(
                  fontSize: 13,
                  color: ComicColors.softWhite,
                ),
                decoration: InputDecoration(
                  hintText: 'AIzaSy...',
                  hintStyle: ComicTypography.body(
                    fontSize: 13,
                    color: ComicColors.textMuted,
                  ),
                  filled: true,
                  fillColor: ComicColors.deepCharcoal,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: ComicColors.comicBorder, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: ComicColors.comicBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: ComicColors.comicPurple, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureGemini
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: ComicColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureGemini = !_obscureGemini),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Get a free API key at aistudio.google.com/app/apikey',
                style: ComicTypography.caption(
                  fontSize: 11,
                  color: ComicColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // Groq API Key (Optional)
              Text(
                'Groq API Key (Optional Fallback)',
                style: ComicTypography.title(
                  fontSize: 14,
                  color: ComicColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _groqController,
                obscureText: true,
                style: ComicTypography.body(
                  fontSize: 13,
                  color: ComicColors.softWhite,
                ),
                decoration: InputDecoration(
                  hintText: 'gsk_...',
                  hintStyle: ComicTypography.body(
                    fontSize: 13,
                    color: ComicColors.textMuted,
                  ),
                  filled: true,
                  fillColor: ComicColors.deepCharcoal,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: ComicColors.comicBorder, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: ComicColors.comicBorder, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _geminiController.clear();
                        _groqController.clear();
                      },
                      child: Text(
                        'Clear Keys',
                        style: ComicTypography.title(
                          fontSize: 13,
                          color: ComicColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ComicButton(
                      text: _isSaving ? 'Connecting...' : 'Save & Connect',
                      icon: Icons.flash_on_rounded,
                      variant: ComicButtonVariant.gradient,
                      onPressed: _isSaving ? null : _saveSettings,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

