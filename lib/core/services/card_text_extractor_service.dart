import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Servicio local (offline, costo $0) para sugerir el título de una carta/pieza
/// leyendo la primera línea impresa de su fotografía mediante Google ML Kit.
abstract interface class CardTextExtractorService {
  bool get isSupportedOnDevice;

  Future<String?> extractSuggestedTitle(String imagePath);
}

class MlKitCardTextExtractorService implements CardTextExtractorService {
  const MlKitCardTextExtractorService();

  @override
  bool get isSupportedOnDevice =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<String?> extractSuggestedTitle(String imagePath) async {
    if (!isSupportedOnDevice || imagePath.trim().isEmpty) {
      return null;
    }
    TextRecognizer? recognizer;
    try {
      recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      for (final block in recognized.blocks) {
        for (final line in block.lines) {
          final cleaned = line.text.trim().replaceAll(RegExp(r'\s+'), ' ');
          if (cleaned.length >= 2 &&
              !RegExp(r'^[0-9/#.-]+$').hasMatch(cleaned)) {
            return cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned;
          }
        }
      }
      return null;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    } finally {
      await recognizer?.close();
    }
  }
}

class NoopCardTextExtractorService implements CardTextExtractorService {
  const NoopCardTextExtractorService({
    this.stubbedTitle,
    this.supported = false,
  });

  final String? stubbedTitle;
  final bool supported;

  @override
  bool get isSupportedOnDevice => supported;

  @override
  Future<String?> extractSuggestedTitle(String imagePath) async => stubbedTitle;
}
