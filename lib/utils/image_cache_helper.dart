import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Helper class for image caching configuration
class ImageCacheHelper {
  /// Duration for caching images (7 days)
  static const Duration cacheDuration = Duration(days: 7);

  /// Maximum cache size (100MB)
  static const int maxCacheBytes = 100 * 1024 * 1024;

  /// Get cached network image widget with default settings
  static Widget getCachedImage({
    required String imageUrl,
    required BoxFit fit,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? placeholder,
    Widget? errorWidget,
    Duration cacheDuration = ImageCacheHelper.cacheDuration,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: (width?.toInt() ?? 300),
      memCacheHeight: (height?.toInt() ?? 300),
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Container(
          color: placeholder ?? Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return errorWidget ??
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error_outline),
              ),
            );
      },
    );
  }

  /// Get cached image for thumbnails (smaller size)
  static Widget getCachedThumbnail({
    required String imageUrl,
    double size = 80,
    BorderRadius? borderRadius,
    Widget? errorWidget,
  }) {
    return getCachedImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: size,
      height: size,
      borderRadius: borderRadius,
      errorWidget: errorWidget ?? const Icon(Icons.image),
    );
  }

  /// Get cached image for product listings
  static Widget getCachedProductImage({
    required String imageUrl,
    double? width,
    double? height,
    Widget? errorWidget,
  }) {
    return getCachedImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: width ?? 200,
      height: height ?? 200,
      errorWidget: errorWidget,
    );
  }

  /// Get cached image for carousel/banners
  static Widget getCachedBannerImage({
    required String imageUrl,
    required double height,
    Widget? errorWidget,
  }) {
    return getCachedImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      errorWidget: errorWidget,
    );
  }

  /// Clear specific image from cache
  static Future<void> clearImageCache(String imageUrl) async {
    try {
      await CachedNetworkImage.evictFromCache(imageUrl);
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }

  /// Pre-warm image cache by loading multiple images
  static Future<void> preWarmImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await CachedNetworkImage.evictFromCache(url);
      } catch (e) {
        print('Error prewarming image cache for $url: $e');
      }
    }
  }
}
