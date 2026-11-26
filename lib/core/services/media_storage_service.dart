import 'dart:typed_data';

abstract interface class MediaStorageService {
  Future<String> storeWebp({
    required Uint8List bytes,
    required String fileName,
  });
}

class MockMediaStorageService implements MediaStorageService {
  int _sequence = 0;

  @override
  Future<String> storeWebp({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      throw const MediaStorageException('The compressed image is empty.');
    }
    _sequence += 1;
    final normalizedName = fileName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9._-]'),
      '_',
    );
    return 'mock://auradeck/uploads/$_sequence/$normalizedName.webp';
  }
}

class MediaStorageException implements Exception {
  const MediaStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
