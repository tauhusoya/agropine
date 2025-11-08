import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageCacheService {
  // Get cached network image widget
  static Widget getCachedNetworkImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported),
            ),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }
    return image;
  }

  // Precache images for better performance
  static Future<void> precacheImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    for (final url in imageUrls) {
      try {
        await precacheImage(CachedNetworkImageProvider(url), context);
      } catch (e) {
        debugPrint('Failed to precache image: $url - $e');
      }
    }
  }

  // Clear image cache
  static void clearImageCache() {
    try {
      imageCache.clear();
      imageCache.clearLiveImages();
    } catch (e) {
      debugPrint('Failed to clear image cache: $e');
    }
  }

  // Get cache info (estimated)
  static int getCacheSize() {
    // Note: Flutter doesn't provide direct cache size API
    // This would require platform-specific implementation
    return 0;
  }
}
