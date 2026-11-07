import 'package:flutter/material.dart';
import '../theme/comic_colors.dart';

/// Subject category data structure
class SubjectItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int storiesCount;

  const SubjectItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.storiesCount,
  });
}

/// Core App Constants & Mock Models for Milestone 1
class AppConstants {
  AppConstants._();

  static const String appName = 'LORVANI';
  static const String wordmark = 'lorvani';
  static const String tagline = 'Turn Study Notes into Comic Adventures';

  static const List<SubjectItem> subjects = [
    SubjectItem(
      id: 'science',
      title: 'Science',
      subtitle: 'Black holes, galaxies & atoms',
      icon: Icons.biotech_rounded,
      color: ComicColors.subjectScience,
      storiesCount: 14,
    ),
    SubjectItem(
      id: 'math',
      title: 'Mathematics',
      subtitle: 'Calculus, algebra & patterns',
      icon: Icons.calculate_rounded,
      color: ComicColors.subjectMath,
      storiesCount: 19,
    ),
    SubjectItem(
      id: 'biology',
      title: 'Biology',
      subtitle: 'DNA, cells & living marvels',
      icon: Icons.eco_rounded,
      color: ComicColors.subjectBiology,
      storiesCount: 22,
    ),
    SubjectItem(
      id: 'physics',
      title: 'Physics',
      subtitle: 'Gravity, light & relativity',
      icon: Icons.bolt_rounded,
      color: ComicColors.subjectPhysics,
      storiesCount: 16,
    ),
    SubjectItem(
      id: 'chemistry',
      title: 'Chemistry',
      subtitle: 'Reactions, bonds & alchemy',
      icon: Icons.science_rounded,
      color: ComicColors.subjectChemistry,
      storiesCount: 12,
    ),
    SubjectItem(
      id: 'history',
      title: 'History',
      subtitle: 'Empires, revolutions & heroes',
      icon: Icons.history_edu_rounded,
      color: ComicColors.subjectHistory,
      storiesCount: 18,
    ),
    SubjectItem(
      id: 'geography',
      title: 'Geography',
      subtitle: 'Volcanoes, oceans & continents',
      icon: Icons.public_rounded,
      color: ComicColors.subjectGeography,
      storiesCount: 11,
    ),
    SubjectItem(
      id: 'literature',
      title: 'Literature',
      subtitle: 'Narratives, epics & allegories',
      icon: Icons.menu_book_rounded,
      color: ComicColors.subjectLiterature,
      storiesCount: 15,
    ),
  ];

  // Milestone 1 Concept of the Day Mock
  static const Map<String, dynamic> conceptOfTheDay = {
    'title': 'Photosynthesis: The Solar Engine',
    'subject': 'Biology',
    'readTime': '3 min read',
    'teaser':
        'How chloroplast tiny green factories turn photons into pure sugar fuel!',
    'panelsCount': 4,
    'badge': 'Concept of the Day',
  };

  // Recent Stories Mock
  static const List<Map<String, dynamic>> recentStories = [
    {
      'id': 'story_1',
      'title': 'The Quantum Cat Escape',
      'subject': 'Physics',
      'color': ComicColors.subjectPhysics,
      'progress': 0.75,
      'panels': 6,
      'style': 'Cinematic Comic',
    },
    {
      'id': 'story_2',
      'title': 'Mitosis: The Cell Splitter',
      'subject': 'Biology',
      'color': ComicColors.subjectBiology,
      'progress': 1.0,
      'panels': 5,
      'style': 'Classic Comic',
    },
    {
      'id': 'story_3',
      'title': 'The French Revolution in 5 Acts',
      'subject': 'History',
      'color': ComicColors.subjectHistory,
      'progress': 0.4,
      'panels': 8,
      'style': 'Anime-inspired',
    },
  ];
}

