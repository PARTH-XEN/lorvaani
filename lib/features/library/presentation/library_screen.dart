import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../data/library_state.dart';
import 'controllers/library_controller.dart';
import 'widgets/saved_story_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const _subjects = [
    'All',
    'Science',
    'Biology',
    'Physics',
    'Chemistry',
    'History',
    'Mathematics',
  ];

  static const _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryControllerProvider.notifier).loadSavedStories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryControllerProvider);
    final controller = ref.read(libraryControllerProvider.notifier);
    final filteredStories = libraryState.filteredStories;

    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        backgroundColor: ComicColors.cardBackground,
        elevation: 0,
        title: Text(
          'COMIC LIBRARY',
          style: ComicTypography.comicDisplay(
            fontSize: 22,
            color: ComicColors.softWhite,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ComicColors.comicPurple,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  '${libraryState.totalCount} Saved',
                  style: ComicTypography.caption(
                    color: ComicColors.electricYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadSavedStories(),
        color: ComicColors.comicPurple,
        backgroundColor: ComicColors.cardBackground,
        child: Column(
          children: [
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: ComicColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ComicColors.comicPurple, width: 1.5),
                ),
                child: TextField(
                  controller: _searchController,
                  style: ComicTypography.body(color: ComicColors.softWhite),
                  decoration: InputDecoration(
                    hintText: 'Search saved stories by topic or title...',
                    hintStyle: ComicTypography.body(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: ComicColors.skyCyan),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (value) => controller.setSearchQuery(value),
                ),
              ),
            ),

            // 2. Subject Filter Horizontal Carousel
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final isSelected = libraryState.selectedSubject == subject;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(subject),
                      selected: isSelected,
                      labelStyle: ComicTypography.caption(
                        color: isSelected ? Colors.black : ComicColors.softWhite,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      backgroundColor: ComicColors.cardBackground,
                      selectedColor: ComicColors.electricYellow,
                      side: BorderSide(
                        color: isSelected ? Colors.black : ComicColors.comicPurple.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onSelected: (_) => controller.setSelectedSubject(subject),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // 3. Level Filter Horizontal Carousel
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  final isSelected = libraryState.selectedLevel == level;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(level),
                      selected: isSelected,
                      labelStyle: ComicTypography.caption(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: ComicColors.deepCharcoal,
                      selectedColor: ComicColors.comicPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      onSelected: (_) => controller.setSelectedLevel(level),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 4. Stories List or Empty State
            Expanded(
              child: libraryState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(ComicColors.comicPurple),
                      ),
                    )
                  : filteredStories.isEmpty
                      ? _buildEmptyState(context, libraryState, controller)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredStories.length,
                          itemBuilder: (context, index) {
                            final story = filteredStories[index];
                            return SavedStoryCard(
                              story: story,
                              onRead: () => context.push('/reader', extra: story),
                              onQuiz: () => context.push('/quiz', extra: story),
                              onExportPdf: () async {
                                final success = await controller.exportAndSharePdf(story);
                                if (context.mounted && !success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to export PDF comic book')),
                                  );
                                }
                              },
                              onShare: () => controller.shareStorySummary(story),
                              onDelete: () => controller.deleteStory(story.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    LibraryState state,
    LibraryController controller,
  ) {
    final isFiltering = state.searchQuery.isNotEmpty ||
        state.selectedSubject != 'All' ||
        state.selectedLevel != 'All';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ComicPanel(
              backgroundColor: ComicColors.cardBackground,
              borderColor: ComicColors.comicPurple,
              borderWidth: 2,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    isFiltering ? Icons.search_off_rounded : Icons.auto_stories_outlined,
                    size: 64,
                    color: ComicColors.electricYellow,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFiltering ? 'NO STORIES MATCHED' : 'LIBRARY IS EMPTY',
                    style: ComicTypography.comicDisplay(
                      fontSize: 20,
                      color: ComicColors.softWhite,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFiltering
                        ? 'Try clearing your search query or subject filters to find your stories.'
                        : 'Transform your notes, photos, and PDFs into illustrated comic stories to read offline anytime!',
                    textAlign: TextAlign.center,
                    style: ComicTypography.body(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  if (isFiltering)
                    ComicButton(
                      text: 'Clear All Filters',
                      variant: ComicButtonVariant.primary,
                      onPressed: () {
                        _searchController.clear();
                        controller.setSearchQuery('');
                        controller.setSelectedSubject('All');
                        controller.setSelectedLevel('All');
                      },
                    )
                  else
                    ComicButton(
                      text: 'Create Your First Story',
                      icon: Icons.add_rounded,
                      variant: ComicButtonVariant.accent,
                      onPressed: () => context.go('/create'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
