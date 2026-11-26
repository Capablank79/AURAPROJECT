import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class CardScanMatch {
  const CardScanMatch({required this.title, this.collectorNumber});

  final String title;
  final String? collectorNumber;
}

abstract interface class MlKitService {
  bool get isSupportedOnDevice;

  Future<CardScanMatch> extractCardDataFromImage(String imagePath);

  Future<String> extractCardTitleFromImage(String imagePath);

  Future<String> translateTextOffline(String text, String targetLangCode);

  Future<void> dispose();
}

class DeviceMlKitService implements MlKitService {
  TextRecognizer? _recognizer;

  @override
  bool get isSupportedOnDevice =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<String> extractCardTitleFromImage(String imagePath) async {
    final match = await extractCardDataFromImage(imagePath);
    return match.title;
  }

  @override
  Future<CardScanMatch> extractCardDataFromImage(String imagePath) async {
    if (!isSupportedOnDevice || imagePath.trim().isEmpty) {
      return const CardScanMatch(title: '');
    }
    try {
      _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await _recognizer!.processImage(
        InputImage.fromFilePath(imagePath),
      );
      var title = '';
      String? collectorNumber;
      final numberRegex = RegExp(r'\b0*(\d{1,4})\s*/\s*\d{1,4}\b');

      for (final block in recognized.blocks) {
        for (final line in block.lines) {
          final cleaned = line.text.trim().replaceAll(RegExp(r'\s+'), ' ');
          if (collectorNumber == null) {
            final numMatch = numberRegex.firstMatch(cleaned);
            if (numMatch != null) {
              collectorNumber = numMatch.group(1);
            }
          }
          if (title.isEmpty &&
              cleaned.length >= 2 &&
              !RegExp(r'^[0-9/#.-]+$').hasMatch(cleaned)) {
            title = cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned;
          }
        }
      }
      return CardScanMatch(title: title, collectorNumber: collectorNumber);
    } on MissingPluginException {
      return const CardScanMatch(title: '');
    } on PlatformException {
      return const CardScanMatch(title: '');
    } catch (_) {
      return const CardScanMatch(title: '');
    }
  }

  @override
  Future<String> translateTextOffline(
    String text,
    String targetLangCode,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !isSupportedOnDevice) {
      return text;
    }
    final targetLanguage = _mapLanguage(targetLangCode);
    if (targetLanguage == TranslateLanguage.english) {
      return text;
    }
    OnDeviceTranslator? translator;
    try {
      final manager = OnDeviceTranslatorModelManager();
      final downloaded = await manager.isModelDownloaded(
        targetLanguage.bcpCode,
      );
      if (!downloaded) {
        final ok = await manager.downloadModel(targetLanguage.bcpCode);
        if (!ok) {
          return text;
        }
      }
      translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: targetLanguage,
      );
      final translated = await translator.translateText(trimmed);
      return translated.trim().isEmpty ? text : translated;
    } on MissingPluginException {
      return text;
    } on PlatformException {
      return text;
    } catch (_) {
      return text;
    } finally {
      await translator?.close();
    }
  }

  TranslateLanguage _mapLanguage(String code) {
    return switch (code) {
      'es' => TranslateLanguage.spanish,
      'pt' => TranslateLanguage.portuguese,
      'ja' => TranslateLanguage.japanese,
      _ => TranslateLanguage.english,
    };
  }

  @override
  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}

class MockMlKitService implements MlKitService {
  const MockMlKitService({
    this.stubbedTitle = '',
    this.stubbedTranslationPrefix = '[ES]',
  });

  final String stubbedTitle;
  final String stubbedTranslationPrefix;

  @override
  bool get isSupportedOnDevice => false;

  @override
  Future<CardScanMatch> extractCardDataFromImage(String imagePath) async =>
      CardScanMatch(title: stubbedTitle);

  @override
  Future<String> extractCardTitleFromImage(String imagePath) async =>
      stubbedTitle;

  @override
  Future<String> translateTextOffline(
    String text,
    String targetLangCode,
  ) async {
    if (text.trim().isEmpty) {
      return text;
    }
    return '$stubbedTranslationPrefix $text';
  }

  @override
  Future<void> dispose() async {}
}
