import '../../../../data/models/comic_story_model.dart';

/// State tracking the saved stories library, search queries, and subject/level filters
class LibraryState {
  final List<ComicStory> stories;
  final bool isLoading;
  final String searchQuery;
  final String selectedSubject;
  final String selectedLevel;
  final String? errorMessage;

  const LibraryState({
    this.stories = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedSubject = 'All',
    this.selectedLevel = 'All',
    this.errorMessage,
  });

  /// Computed list of stories matching active search and filters
  List<ComicStory> get filteredStories {
    return stories.where((story) {
      // 1. Search query filter
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesTitle = story.storyTitle.toLowerCase().contains(query);
        final matchesTopic = story.originalTopic.toLowerCase().contains(query);
        final matchesSummary = story.summary.toLowerCase().contains(query);
        if (!matchesTitle && !matchesTopic && !matchesSummary) {
          return false;
        }
      }

      // 2. Subject filter
      if (selectedSubject != 'All') {
        if (!story.originalTopic.toLowerCase().contains(selectedSubject.toLowerCase())) {
          return false;
        }
      }

      // 3. Learning level filter
      if (selectedLevel != 'All') {
        if (story.learningLevel.toLowerCase() != selectedLevel.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get totalCount => stories.length;
  int get filteredCount => filteredStories.length;
  bool get isEmpty => stories.isEmpty;

  LibraryState copyWith({
    List<ComicStory>? stories,
    bool? isLoading,
    String? searchQuery,
    String? selectedSubject,
    String? selectedLevel,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LibraryState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

