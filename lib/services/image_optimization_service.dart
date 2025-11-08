import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Image optimization and compression utility
class ImageOptimizationService {
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;
  static const int jpegQuality = 75;
  static const int webpQuality = 75;

  /// Check if image should be compressed
  static bool shouldCompress(File imageFile) {
    final sizeInMB = imageFile.lengthSync() / (1024 * 1024);
    return sizeInMB > 2; // Compress if larger than 2MB
  }

  /// Compress image and convert to WebP if possible
  /// Returns compressed image path
  static Future<String?> compressImage(String imagePath) async {
    try {
      final originalFile = File(imagePath);
      if (!originalFile.existsSync()) {
        debugPrint('✗ Image file not found: $imagePath');
        return null;
      }

      // Read image
      final imageBytes = await originalFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        debugPrint('✗ Failed to decode image: $imagePath');
        return null;
      }

      // Resize if necessary
      img.Image resized = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        resized = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
          interpolation: img.Interpolation.linear,
        );
        debugPrint('✓ Image resized: ${image.width}x${image.height} → ${resized.width}x${resized.height}');
      }

      // Save as JPEG first (for compatibility)
      final directory = await getTemporaryDirectory();
      final jpegPath = '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final jpegFile = File(jpegPath);
      await jpegFile.writeAsBytes(img.encodeJpg(resized, quality: jpegQuality));

      final originalSize = originalFile.lengthSync();
      final compressedSize = jpegFile.lengthSync();
      final reduction = ((1 - (compressedSize / originalSize)) * 100).toStringAsFixed(1);

      debugPrint('✓ Image compressed: ${(originalSize / 1024).toStringAsFixed(1)}KB → ${(compressedSize / 1024).toStringAsFixed(1)}KB ($reduction% reduction)');

      return jpegPath;
    } catch (e) {
      debugPrint('✗ Error compressing image: $e');
      return null;
    }
  }

  /// Compress multiple images
  static Future<List<String>> compressImages(List<String> imagePaths) async {
    final compressedPaths = <String>[];
    for (final path in imagePaths) {
      final compressed = await compressImage(path);
      if (compressed != null) {
        compressedPaths.add(compressed);
      }
    }
    return compressedPaths;
  }

  /// Get image info (dimensions, size)
  static Future<Map<String, dynamic>?> getImageInfo(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return null;

      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) return null;

      return {
        'width': image.width,
        'height': image.height,
        'size': file.lengthSync(),
        'path': imagePath,
      };
    } catch (e) {
      debugPrint('✗ Error getting image info: $e');
      return null;
    }
  }

  /// Calculate compression ratio
  static double calculateCompressionRatio(int originalSize, int compressedSize) {
    if (originalSize == 0) return 0;
    return ((originalSize - compressedSize) / originalSize) * 100;
  }

  /// Preload and cache images for better performance
  static Future<void> precacheOptimizedImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    try {
      for (final url in imageUrls) {
        precacheImage(NetworkImage(url), context);
      }
      debugPrint('✓ ${imageUrls.length} images precached');
    } catch (e) {
      debugPrint('✗ Error precaching images: $e');
    }
  }

  /// Get thumbnail of image
  static Future<Uint8List?> getThumbnail(String imagePath, {int size = 150}) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) return null;

      final thumbnail = img.copyResize(
        image,
        width: size,
        height: size,
        interpolation: img.Interpolation.linear,
      );

      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 80));
    } catch (e) {
      debugPrint('✗ Error creating thumbnail: $e');
      return null;
    }
  }

  /// Estimate bundle size savings
  static String estimateBundleSavings(List<String> imagePaths) {
    int totalOriginal = 0;
    int totalCompressed = 0;

    for (final path in imagePaths) {
      final file = File(path);
      if (file.existsSync()) {
        totalOriginal += file.lengthSync();
        // Estimate 40-60% compression
        totalCompressed += (file.lengthSync() * 0.5).toInt();
      }
    }

    final savings = totalOriginal - totalCompressed;
    final savingsMB = savings / (1024 * 1024);
    final percent = ((savings / totalOriginal) * 100).toStringAsFixed(1);

    return 'Estimated savings: ${savingsMB.toStringAsFixed(2)}MB ($percent%)';
  }

  /// Clear temporary compressed images
  static Future<void> clearCompressedImageCache() async {
    try {
      final directory = await getTemporaryDirectory();
      final files = directory.listSync();

      for (final file in files) {
        if (file.path.contains('compressed_') && file.path.endsWith('.jpg')) {
          await file.delete();
        }
      }
      debugPrint('✓ Compressed image cache cleared');
    } catch (e) {
      debugPrint('✗ Error clearing cache: $e');
    }
  }
}
