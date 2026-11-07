import 'dart:collection';

/// Service managing in-memory and local image caching for generated comic panels
class ComicImageCacheService {
  final int maxCacheEntries;
  final LinkedHashMap<String, String> _urlCache = LinkedHashMap<String, String>();
  final LinkedHashMap<String, List<int>> _byteCache = LinkedHashMap<String, List<int>>();

  ComicImageCacheService({this.maxCacheEntries = 100});

  /// Generates a unique, deterministic cache key for a specific panel in a story
  static String buildCacheKey({
    required String storyId,
    required int panelNumber,
    int? seed,
  }) {
    return 'panel_${storyId}_${panelNumber}_${seed ?? 0}';
  }

  /// Retrieves cached URL for a given cache key if available
  String? getCachedUrl(String cacheKey) {
    if (_urlCache.containsKey(cacheKey)) {
      // Refresh LRU order
      final url = _urlCache.remove(cacheKey)!;
      _urlCache[cacheKey] = url;
      return url;
    }
    return null;
  }

  /// Stores a generated image URL in the cache with LRU eviction
  void cacheUrl(String cacheKey, String imageUrl) {
    if (_urlCache.containsKey(cacheKey)) {
      _urlCache.remove(cacheKey);
    } else if (_urlCache.length >= maxCacheEntries) {
      _urlCache.remove(_urlCache.keys.first);
    }
    _urlCache[cacheKey] = imageUrl;
  }

  /// Retrieves cached image bytes if pre-fetched or saved locally
  List<int>? getCachedBytes(String cacheKey) {
    if (_byteCache.containsKey(cacheKey)) {
      final bytes = _byteCache.remove(cacheKey)!;
      _byteCache[cacheKey] = bytes;
      return bytes;
    }
    return null;
  }

  /// Stores raw image bytes in the memory cache
  void cacheBytes(String cacheKey, List<int> bytes) {
    if (_byteCache.containsKey(cacheKey)) {
      _byteCache.remove(cacheKey);
    } else if (_byteCache.length >= maxCacheEntries) {
      _byteCache.remove(_byteCache.keys.first);
    }
    _byteCache[cacheKey] = bytes;
  }

  /// Checks if an image is already cached
  bool has(String cacheKey) => _urlCache.containsKey(cacheKey) || _byteCache.containsKey(cacheKey);

  /// Clears cache entries associated with a specific story
  void invalidateStory(String storyId) {
    _urlCache.removeWhere((key, _) => key.startsWith('panel_${storyId}_'));
    _byteCache.removeWhere((key, _) => key.startsWith('panel_${storyId}_'));
  }

  /// Clears all cached entries
  void clearAll() {
    _urlCache.clear();
    _byteCache.clear();
  }

  /// Current number of cached URLs
  int get cachedUrlCount => _urlCache.length;

  /// Current number of cached byte entries
  int get cachedByteCount => _byteCache.length;
}

