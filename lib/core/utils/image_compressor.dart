import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompressedImageResult {
  const CompressedImageResult({
    required this.bytes,
    required this.originalBytes,
    required this.compressedBytes,
  });

  final Uint8List bytes;
  final int originalBytes;
  final int compressedBytes;

  static String formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    final kb = (bytes / 1024).clamp(1, double.infinity);
    return '${kb.round()} KB';
  }
}

abstract interface class ImageCompressor {
  Future<Uint8List> compressToWebp(String sourcePath);

  Future<CompressedImageResult> compressToWebpWithStats(String sourcePath);
}

class AuraImageCompressor implements ImageCompressor {
  const AuraImageCompressor({this.maxDimension = 1080, this.quality = 80});

  final int maxDimension;
  final int quality;

  @override
  Future<Uint8List> compressToWebp(String sourcePath) async {
    final result = await compressToWebpWithStats(sourcePath);
    return result.bytes;
  }

  @override
  Future<CompressedImageResult> compressToWebpWithStats(
    String sourcePath,
  ) async {
    final file = File(sourcePath);
    final originalBytes = await file.exists() ? await file.length() : 0;
    final result = await FlutterImageCompress.compressWithFile(
      sourcePath,
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: quality,
      format: CompressFormat.webp,
    );
    if (result == null || result.isEmpty) {
      throw const ImageCompressionException(
        'The image could not be compressed.',
      );
    }
    return CompressedImageResult(
      bytes: result,
      originalBytes: originalBytes > 0 ? originalBytes : result.length,
      compressedBytes: result.length,
    );
  }
}

class ImageCompressionException implements Exception {
  const ImageCompressionException(this.message);

  final String message;

  @override
  String toString() => message;
}
