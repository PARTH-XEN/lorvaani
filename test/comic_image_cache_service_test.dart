import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/features/image_generation/services/comic_image_cache_service.dart';

void main() {
  group('ComicImageCacheService Tests', () {
    late ComicImageCacheService cacheService;

    setUp(() {
      cacheService = ComicImageCacheService(maxCacheEntries: 3);
    });

    test('builds consistent cache keys', () {
      final key = ComicImageCacheService.buildCacheKey(
        storyId: 'story_abc',
        panelNumber: 2,
        seed: 42,
      );
      expect(key, equals('panel_story_abc_2_42'));
    });

    test('stores and retrieves cached image URLs', () {
      const key = 'panel_story_1_1_0';
      const url = 'https://example.com/panel1.png';

      expect(cacheService.has(key), isFalse);
      expect(cacheService.getCachedUrl(key), isNull);

      cacheService.cacheUrl(key, url);

      expect(cacheService.has(key), isTrue);
      expect(cacheService.getCachedUrl(key), equals(url));
      expect(cacheService.cachedUrlCount, equals(1));
    });

    test('evicts oldest entries when exceeding maxCacheEntries (LRU)', () {
      cacheService.cacheUrl('key_1', 'url_1');
      cacheService.cacheUrl('key_2', 'url_2');
      cacheService.cacheUrl('key_3', 'url_3');

      // Access key_1 to make it recently used
      cacheService.getCachedUrl('key_1');

      // Add a 4th entry, which should evict key_2 (oldest unaccessed)
      cacheService.cacheUrl('key_4', 'url_4');

      expect(cacheService.getCachedUrl('key_1'), equals('url_1'));
      expect(cacheService.getCachedUrl('key_2'), isNull); // Evicted!
      expect(cacheService.getCachedUrl('key_3'), equals('url_3'));
      expect(cacheService.getCachedUrl('key_4'), equals('url_4'));
    });

    test('invalidates all entries for a specific story', () {
      cacheService.cacheUrl('panel_storyA_1_0', 'url_A1');
      cacheService.cacheUrl('panel_storyA_2_0', 'url_A2');
      cacheService.cacheUrl('panel_storyB_1_0', 'url_B1');

      cacheService.invalidateStory('storyA');

      expect(cacheService.getCachedUrl('panel_storyA_1_0'), isNull);
      expect(cacheService.getCachedUrl('panel_storyA_2_0'), isNull);
      expect(cacheService.getCachedUrl('panel_storyB_1_0'), equals('url_B1'));
    });

    test('clears all cached URLs and byte arrays', () {
      cacheService.cacheUrl('k1', 'u1');
      cacheService.cacheBytes('b1', [1, 2, 3]);

      expect(cacheService.cachedUrlCount, equals(1));
      expect(cacheService.cachedByteCount, equals(1));

      cacheService.clearAll();

      expect(cacheService.cachedUrlCount, equals(0));
      expect(cacheService.cachedByteCount, equals(0));
    });
  });
}

