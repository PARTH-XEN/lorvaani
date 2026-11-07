import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/comic_story_model.dart';

/// Local persistence and offline storage service for comic stories
class StoryStorageService {
  static const String _storageKey = 'lorvani_saved_stories_v1';

  final bool isTestMode;
  final Map<String, ComicStory> _memoryCache = {};
  bool _isInitialized = false;

  StoryStorageService({this.isTestMode = false});

  /// Ensures storage is loaded into memory cache
  Future<void> _ensureLoaded() async {
    if (_isInitialized) return;

    if (isTestMode) {
      _isInitialized = true;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonListString = prefs.getString(_storageKey);
      if (jsonListString != null && jsonListString.isNotEmpty) {
        final rawList = jsonDecode(jsonListString) as List;
        for (final item in rawList) {
          final story = ComicStory.fromJson(Map<String, dynamic>.from(item as Map));
          _memoryCache[story.id] = story;
        }
      }
    } catch (e) {
      debugPrint('StoryStorageService error loading saved stories: $e');
    }
    _isInitialized = true;
  }

  /// Flushes current in-memory stories to persistent local storage
  Future<bool> _persist() async {
    if (isTestMode) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final serializedList = _memoryCache.values.map((s) => s.toJson()).toList();
      return await prefs.setString(_storageKey, jsonEncode(serializedList));
    } catch (e) {
      debugPrint('StoryStorageService error persisting stories: $e');
      return false;
    }
  }

  /// Retrieves all saved comic stories ordered by creation date descending
  Future<List<ComicStory>> getSavedStories() async {
    await _ensureLoaded();
    final list = _memoryCache.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Saves a comic story to local offline storage
  Future<bool> saveStory(ComicStory story) async {
    await _ensureLoaded();
    final markedStory = story.copyWith(isSaved: true);
    _memoryCache[markedStory.id] = markedStory;
    return await _persist();
  }

  /// Removes a saved story from local storage
  Future<bool> deleteStory(String storyId) async {
    await _ensureLoaded();
    if (_memoryCache.containsKey(storyId)) {
      _memoryCache.remove(storyId);
      return await _persist();
    }
    return true;
  }

  /// Checks if a story is currently saved in local storage
  Future<bool> isStorySaved(String storyId) async {
    await _ensureLoaded();
    return _memoryCache.containsKey(storyId);
  }

  /// Retrieves a specific story by id
  Future<ComicStory?> getStoryById(String storyId) async {
    await _ensureLoaded();
    return _memoryCache[storyId];
  }

  /// Clears all saved stories
  Future<void> clearAll() async {
    await _ensureLoaded();
    _memoryCache.clear();
    await _persist();
  }

  /// Injects test stories for unit testing
  @visibleForTesting
  void setTestStories(List<ComicStory> stories) {
    _memoryCache.clear();
    for (final s in stories) {
      _memoryCache[s.id] = s;
    }
    _isInitialized = true;
  }
}

