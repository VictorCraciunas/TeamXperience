import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheImageManager{
  static final CacheManager eventImageCache = CacheManager(
    Config(
      'eventImagesCache',
      maxNrOfCacheObjects: 200, // Increased for better caching
      stalePeriod: const Duration(days: 30),
      // Optional: Add repo for better performance
      repo: JsonCacheInfoRepository(databaseName: 'eventImagesCache'),
    ),
  );
}

