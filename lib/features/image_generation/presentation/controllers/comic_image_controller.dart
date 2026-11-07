import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai/ai_provider_types.dart';
import '../../../../core/services/ai/mock/mock_image_provider.dart';
import '../../../../core/services/ai/orchestrator/ai_orchestrator.dart';
import '../../../../data/models/comic_story_model.dart';
import '../../../story_generation/presentation/controllers/story_generation_controller.dart';
import '../../data/panel_image_state.dart';
import '../../services/comic_image_cache_service.dart';
import '../../services/comic_image_prompt_service.dart';

final comicImagePromptServiceProvider =
    Provider<ComicImagePromptService>((ref) => const ComicImagePromptService());

final comicImageCacheServiceProvider =
    Provider<ComicImageCacheService>((ref) => ComicImageCacheService());

final comicImageControllerProvider =
    NotifierProvider<ComicImageController, StoryImageGenerationState>(
  ComicImageController.new,
);

class ComicImageController extends Notifier<StoryImageGenerationState> {
  late AiOrchestrator _orchestrator;
  late ComicImagePromptService _promptService;
  late ComicImageCacheService _cacheService;

  @override
  StoryImageGenerationState build() {
    _orchestrator = ref.watch(aiOrchestratorProvider);
    _promptService = ref.watch(comicImagePromptServiceProvider);
    _cacheService = ref.watch(comicImageCacheServiceProvider);
    return const StoryImageGenerationState();
  }

  // Dependency injection helper for testing
  void setDependencies({
    AiOrchestrator? orchestrator,
    ComicImagePromptService? promptService,
    ComicImageCacheService? cacheService,
  }) {
    if (orchestrator != null) _orchestrator = orchestrator;
    if (promptService != null) _promptService = promptService;
    if (cacheService != null) _cacheService = cacheService;
  }

  /// Initializes image tracking for a newly loaded or generated story
  void initializeStory(ComicStory story) {
    final panelMap = <int, SinglePanelImageState>{};
    int completed = 0;

    for (final panel in story.panels) {
      final cacheKey = ComicImageCacheService.buildCacheKey(
        storyId: story.id,
        panelNumber: panel.panelNumber,
        seed: _promptService.calculateStorySeed(story),
      );

      final cachedUrl = _cacheService.getCachedUrl(cacheKey) ?? panel.imageUrl;

      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        panelMap[panel.panelNumber] = SinglePanelImageState(
          panelNumber: panel.panelNumber,
          status: PanelImageStatus.completed,
          imageUrl: cachedUrl,
        );
        completed++;
      } else {
        panelMap[panel.panelNumber] = SinglePanelImageState(
          panelNumber: panel.panelNumber,
          status: PanelImageStatus.idle,
        );
      }
    }

    state = StoryImageGenerationState(
      storyId: story.id,
      isGeneratingAll: false,
      completedCount: completed,
      totalCount: story.panels.length,
      panelStates: panelMap,
    );
  }

  /// Generates illustration for a single panel with caching, character consistency, and error handling
  Future<String?> generatePanelImage({
    required ComicStory story,
    required ComicPanelModel panel,
    bool forceOfflineMock = false,
  }) async {
    final panelNumber = panel.panelNumber;
    final currentPanelState = state.panelStates[panelNumber] ??
        SinglePanelImageState(panelNumber: panelNumber);

    // 1. Check Cache
    final seed = _promptService.calculateStorySeed(story);
    final cacheKey = ComicImageCacheService.buildCacheKey(
      storyId: story.id,
      panelNumber: panelNumber,
      seed: seed,
    );

    final existingCachedUrl = _cacheService.getCachedUrl(cacheKey);
    if (existingCachedUrl != null && existingCachedUrl.isNotEmpty) {
      _updatePanelState(
        panelNumber,
        currentPanelState.copyWith(
          status: PanelImageStatus.completed,
          imageUrl: existingCachedUrl,
        ),
      );
      return existingCachedUrl;
    }

    // 2. Mark Generating
    _updatePanelState(
      panelNumber,
      currentPanelState.copyWith(
        status: PanelImageStatus.generating,
        attemptCount: currentPanelState.attemptCount + 1,
        clearError: true,
      ),
    );

    // 3. Assemble Prompt & Parameters
    final visualStyle = _promptService.resolveVisualStyle(story.visualStyle);
    final characterConsistency =
        _promptService.buildCharacterConsistencyPrompt(story.characters);
    final prompt = _promptService.assemblePanelPrompt(story: story, panel: panel);

    try {
      AiImageResponse response;

      if (forceOfflineMock) {
        const mockProvider = MockImageProvider();
        response = await mockProvider.generatePanelIllustration(
          panelDescription: panel.panelDescription,
          visualStyle: visualStyle,
          characterConsistencyPrompt: characterConsistency,
          seed: seed,
        );
      } else {
        response = await _orchestrator.generatePanelIllustration(
          panelDescription: panel.panelDescription,
          visualStyle: visualStyle,
          characterConsistencyPrompt: characterConsistency,
          seed: seed,
        );
      }

      // Cache successful URL
      _cacheService.cacheUrl(cacheKey, response.imageUrl);

      _updatePanelState(
        panelNumber,
        currentPanelState.copyWith(
          status: response.isFallback
              ? PanelImageStatus.fallback
              : PanelImageStatus.completed,
          imageUrl: response.imageUrl,
          prompt: prompt,
          isFallback: response.isFallback,
        ),
        incrementCompleted: true,
      );

      return response.imageUrl;
    } catch (e) {
      // Graceful error state without breaking reader screen
      _updatePanelState(
        panelNumber,
        currentPanelState.copyWith(
          status: PanelImageStatus.failed,
          errorMessage: 'Illustration generation failed: $e',
          prompt: prompt,
        ),
      );
      return null;
    }
  }

  /// Concurrently generates all panel images for a story with a throttle
  Future<ComicStory> generateAllPanels({
    required ComicStory story,
    bool forceOfflineMock = false,
  }) async {
    state = state.copyWith(isGeneratingAll: true);

    final updatedPanels = <ComicPanelModel>[];

    for (final panel in story.panels) {
      final generatedUrl = await generatePanelImage(
        story: story,
        panel: panel,
        forceOfflineMock: forceOfflineMock,
      );

      updatedPanels.add(
        panel.copyWith(imageUrl: generatedUrl ?? panel.imageUrl),
      );
    }

    state = state.copyWith(isGeneratingAll: false);
    return story.copyWith(panels: updatedPanels);
  }

  /// Retries a single panel that previously failed or timed out
  Future<String?> retryPanel({
    required ComicStory story,
    required int panelNumber,
    bool forceOfflineMock = false,
  }) async {
    final panel = story.panels.firstWhere(
      (p) => p.panelNumber == panelNumber,
      orElse: () => story.panels.first,
    );
    return generatePanelImage(
      story: story,
      panel: panel,
      forceOfflineMock: forceOfflineMock,
    );
  }

  void _updatePanelState(
    int panelNumber,
    SinglePanelImageState newPanelState, {
    bool incrementCompleted = false,
  }) {
    final newMap = Map<int, SinglePanelImageState>.from(state.panelStates);
    newMap[panelNumber] = newPanelState;

    int newCompleted = state.completedCount;
    if (incrementCompleted) {
      newCompleted = newMap.values
          .where((s) => s.status == PanelImageStatus.completed || s.status == PanelImageStatus.fallback)
          .length;
    }

    state = state.copyWith(
      panelStates: newMap,
      completedCount: newCompleted,
    );
  }
}

