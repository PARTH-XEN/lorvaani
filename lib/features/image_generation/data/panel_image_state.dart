enum PanelImageStatus {
  idle,
  generating,
  completed,
  failed,
  fallback,
}

/// State tracking image generation for a single comic panel
class SinglePanelImageState {
  final int panelNumber;
  final PanelImageStatus status;
  final String? imageUrl;
  final String? prompt;
  final String? errorMessage;
  final bool isFallback;
  final int attemptCount;

  const SinglePanelImageState({
    required this.panelNumber,
    this.status = PanelImageStatus.idle,
    this.imageUrl,
    this.prompt,
    this.errorMessage,
    this.isFallback = false,
    this.attemptCount = 0,
  });

  SinglePanelImageState copyWith({
    PanelImageStatus? status,
    String? imageUrl,
    String? prompt,
    String? errorMessage,
    bool? isFallback,
    int? attemptCount,
    bool clearError = false,
  }) {
    return SinglePanelImageState(
      panelNumber: panelNumber,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      prompt: prompt ?? this.prompt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFallback: isFallback ?? this.isFallback,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }
}

/// State tracking story-wide comic panel illustration progress
class StoryImageGenerationState {
  final String storyId;
  final bool isGeneratingAll;
  final int completedCount;
  final int totalCount;
  final Map<int, SinglePanelImageState> panelStates;
  final String? overallError;

  const StoryImageGenerationState({
    this.storyId = '',
    this.isGeneratingAll = false,
    this.completedCount = 0,
    this.totalCount = 0,
    this.panelStates = const {},
    this.overallError,
  });

  double get progressRatio => totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);

  bool get isAllFinished => totalCount > 0 && completedCount >= totalCount;

  bool get hasAnyErrors => panelStates.values.any((s) => s.status == PanelImageStatus.failed);

  StoryImageGenerationState copyWith({
    String? storyId,
    bool? isGeneratingAll,
    int? completedCount,
    int? totalCount,
    Map<int, SinglePanelImageState>? panelStates,
    String? overallError,
    bool clearOverallError = false,
  }) {
    return StoryImageGenerationState(
      storyId: storyId ?? this.storyId,
      isGeneratingAll: isGeneratingAll ?? this.isGeneratingAll,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      panelStates: panelStates ?? this.panelStates,
      overallError: clearOverallError ? null : (overallError ?? this.overallError),
    );
  }
}

