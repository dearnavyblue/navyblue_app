// lib/core/services/image_cache_service.dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager {
  static const key = 'exam_images';
  
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30), // Keep images for 30 days
      maxNrOfCacheObjects: 500, // Increase cache limit
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
  
  // Preload images for offline use
  static Future<void> preloadImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      try {
        await instance.downloadFile(url);
      } catch (e) {
        print('Failed to preload image: $url - $e');
      }
    }
  }
  
  // Clear specific images
  static Future<void> removeFromCache(String imageUrl) async {
    await instance.removeFile(imageUrl);
  }
  
  // Clear all cached images
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
  
  // Check if image is cached
  static Future<bool> isImageCached(String imageUrl) async {
    final file = await instance.getFileFromCache(imageUrl);
    return file != null;
  }
}