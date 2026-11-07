import '../../../../data/models/comic_story_model.dart';

enum ReadingMode {
  horizontalPage,
  verticalScroll,
}

/// State tracking interactive comic reader
class ComicReaderState {
  final ComicStory? story;
  final int currentPanelIndex;
  final ReadingMode readingMode;
  final bool isSpeaking;
  final bool isAutoPlaying;
  final ComicPanelModel? expandedPanel;
  final bool isConceptSheetOpen;

  const ComicReaderState({
    this.story,
    this.currentPanelIndex = 0,
    this.readingMode = ReadingMode.horizontalPage,
    this.isSpeaking = false,
    this.isAutoPlaying = false,
    this.expandedPanel,
    this.isConceptSheetOpen = false,
  });

  int get totalPanels => story?.panels.length ?? 0;

  ComicPanelModel? get currentPanel {
    if (story == null || story!.panels.isEmpty) return null;
    if (currentPanelIndex < 0 || currentPanelIndex >= story!.panels.length) return null;
    return story!.panels[currentPanelIndex];
  }

  bool get isFirstPanel => currentPanelIndex == 0;

  bool get isLastPanel => totalPanels > 0 && currentPanelIndex >= totalPanels - 1;

  double get progressPercentage =>
      totalPanels > 0 ? ((currentPanelIndex + 1) / totalPanels).clamp(0.0, 1.0) : 0.0;

  ComicReaderState copyWith({
    ComicStory? story,
    int? currentPanelIndex,
    ReadingMode? readingMode,
    bool? isSpeaking,
    bool? isAutoPlaying,
    ComicPanelModel? expandedPanel,
    bool clearExpandedPanel = false,
    bool? isConceptSheetOpen,
  }) {
    return ComicReaderState(
      story: story ?? this.story,
      currentPanelIndex: currentPanelIndex ?? this.currentPanelIndex,
      readingMode: readingMode ?? this.readingMode,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isAutoPlaying: isAutoPlaying ?? this.isAutoPlaying,
      expandedPanel: clearExpandedPanel ? null : (expandedPanel ?? this.expandedPanel),
      isConceptSheetOpen: isConceptSheetOpen ?? this.isConceptSheetOpen,
    );
  }
}
