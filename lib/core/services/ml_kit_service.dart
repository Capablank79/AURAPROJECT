import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class CardScanMatch {
  const CardScanMatch({
    required this.title,
    this.collectorNumber,
    this.setCode,
    this.centeringRatio = '50/50',
    this.estimatedGrade = 'PSA 10',
  });

  final String title;
  final String? collectorNumber;
  final String? setCode;
  final String centeringRatio;
  final String estimatedGrade;
}

abstract interface class MlKitService {
  bool get isSupportedOnDevice;

  Future<CardScanMatch> extractCardDataFromImage(
    String imagePath, {
    String? languageCode,
  });

  Future<CardScanMatch> extractCardDataFromInputImage(
    InputImage inputImage, {
    Size? frameSize,
    String? languageCode,
  });

  Future<String> extractCardTitleFromImage(String imagePath);

  Future<String> translateTextOffline(String text, String targetLangCode);

  Future<void> dispose();
}

class DeviceMlKitService implements MlKitService {
  TextRecognizer? _latinRecognizer;
  TextRecognizer? _japaneseRecognizer;

  static final _collectorSlashRegex = RegExp(r'\b0*(\d{1,4})\s*/\s*\d{1,4}\b');
  static final _setAndNumRegex = RegExp(
    r'\b([A-Z]{2,4}[0-9]?)\s*[·•\- ]?\s*#?0*(\d{1,4})\b',
  );
  static final _setTokenRegex = RegExp(r'\b([A-Z]{3,4})\b');
  static final _noiseHeaderRegex = RegExp(
    r'^(HP\s*\d+|\d+\s*HP|[0-9/#.\-+× ]+|STAGE\s*\d|BASIC|FASE\s*\d|BÁSICO)$',
    caseSensitive: false,
  );

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
  Future<CardScanMatch> extractCardDataFromImage(
    String imagePath, {
    String? languageCode,
  }) async {
    if (!isSupportedOnDevice || imagePath.trim().isEmpty) {
      return const CardScanMatch(title: '');
    }
    return extractCardDataFromInputImage(
      InputImage.fromFilePath(imagePath),
      languageCode: languageCode,
    );
  }

  @override
  Future<CardScanMatch> extractCardDataFromInputImage(
    InputImage inputImage, {
    Size? frameSize,
    String? languageCode,
  }) async {
    if (!isSupportedOnDevice) {
      return const CardScanMatch(title: '');
    }
    try {
      final recognizer = languageCode == 'ja'
          ? (_japaneseRecognizer ??= TextRecognizer(
              script: TextRecognitionScript.japanese,
            ))
          : (_latinRecognizer ??= TextRecognizer(
              script: TextRecognitionScript.latin,
            ));

      final recognized = await recognizer.processImage(inputImage);
      return parseZonalRecognizedText(recognized, frameSize: frameSize);
    } on MissingPluginException {
      return const CardScanMatch(title: '');
    } on PlatformException {
      return const CardScanMatch(title: '');
    } catch (_) {
      return const CardScanMatch(title: '');
    }
  }

  /// Motor Zonal estilo MagicFrame:
  /// - Zona Superior (top <= 35%): extrae el nombre evitando HP/maná a la derecha.
  /// - Zona Inferior (bottom >= 70%): extrae código de Set (3-4 letras) + número.
  /// - Simetría óptica: estima el centrado L/R a partir de los márgenes detectados.
  @visibleForTesting
  static CardScanMatch parseZonalRecognizedText(
    RecognizedText recognized, {
    Size? frameSize,
  }) {
    final lines = <TextLine>[];
    for (final block in recognized.blocks) {
      lines.addAll(block.lines);
    }
    if (lines.isEmpty) {
      return const CardScanMatch(title: '');
    }

    lines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));
    final effectiveHeight =
        frameSize?.height ??
        lines.fold<double>(
          1,
          (maxBottom, l) =>
              l.boundingBox.bottom > maxBottom ? l.boundingBox.bottom : maxBottom,
        );
    final effectiveWidth =
        frameSize?.width ??
        lines.fold<double>(
          1,
          (maxRight, l) =>
              l.boundingBox.right > maxRight ? l.boundingBox.right : maxRight,
        );

    var topZoneTitle = '';
    var fallbackTitle = '';
    String? collectorNumber;
    String? setCode;

    double minLeft = effectiveWidth;
    double maxRight = 0;

    for (final line in lines) {
      final box = line.boundingBox;
      if (box != Rect.zero) {
        if (box.left < minLeft) minLeft = box.left;
        if (box.right > maxRight) maxRight = box.right;
      }

      final cleaned = _sanitizeTitleCandidate(line.text);
      final relTop = effectiveHeight > 0 ? box.top / effectiveHeight : 0.0;
      final relLeft = effectiveWidth > 0 ? box.left / effectiveWidth : 0.0;
      final isBottomZone = relTop >= 0.68;
      final isTopTitleZone = relTop <= 0.36 && relLeft < 0.65;

      // 1. Buscar Número de Coleccionista y Set (prioridad en franja inferior)
      final slashMatch = _collectorSlashRegex.firstMatch(line.text);
      if (slashMatch != null && (collectorNumber == null || isBottomZone)) {
        collectorNumber = slashMatch.group(1);
      }
      if (isBottomZone) {
        final pair = _setAndNumRegex.firstMatch(line.text.toUpperCase());
        if (pair != null) {
          setCode ??= pair.group(1);
          collectorNumber ??= pair.group(2);
        } else {
          final token = _setTokenRegex.firstMatch(line.text);
          if (token != null) {
            final candidateSet = token.group(1)!;
            if (candidateSet != 'TCG' && candidateSet != 'USA') {
              setCode ??= candidateSet;
            }
          }
        }
      }

      // 2. Buscar Título limpio en franja superior izquierda/central
      if (cleaned.length >= 2 && !_noiseHeaderRegex.hasMatch(cleaned)) {
        if (isTopTitleZone && topZoneTitle.isEmpty) {
          topZoneTitle = cleaned;
        } else if (fallbackTitle.isEmpty) {
          fallbackTitle = cleaned;
        }
      }
    }

    final chosenTitle = topZoneTitle.isNotEmpty ? topZoneTitle : fallbackTitle;
    final (ratio, grade) = estimateCentering(
      minLeft: minLeft,
      maxRight: maxRight,
      frameWidth: effectiveWidth,
    );

    return CardScanMatch(
      title: chosenTitle.length > 60
          ? chosenTitle.substring(0, 60)
          : chosenTitle,
      collectorNumber: collectorNumber,
      setCode: setCode,
      centeringRatio: ratio,
      estimatedGrade: grade,
    );
  }

  static String _sanitizeTitleCandidate(String raw) {
    // Quita sufijos comunes de HP que aparecen en la misma línea superior
    return raw
        .trim()
        .replaceAll(RegExp(r'\s+HP\s*\d+$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+\d{2,3}\s*HP$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @visibleForTesting
  static (String ratio, String grade) estimateCentering({
    required double minLeft,
    required double maxRight,
    required double frameWidth,
  }) {
    if (frameWidth <= 0 || maxRight <= minLeft) {
      return ('51/49', 'PSA 10');
    }
    final leftMargin = minLeft.clamp(1.0, frameWidth);
    final rightMargin = (frameWidth - maxRight).clamp(1.0, frameWidth);
    final total = leftMargin + rightMargin;
    if (total <= 0) {
      return ('51/49', 'PSA 10');
    }
    final leftPct = ((leftMargin / total) * 100).round().clamp(35, 65);
    final rightPct = 100 - leftPct;
    final heavier = leftPct >= rightPct ? leftPct : rightPct;

    final grade = heavier <= 55
        ? 'PSA 10'
        : (heavier <= 60 ? 'PSA 9' : 'PSA 8');

    return ('$leftPct/$rightPct', grade);
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
    await _latinRecognizer?.close();
    await _japaneseRecognizer?.close();
    _latinRecognizer = null;
    _japaneseRecognizer = null;
  }
}

class MockMlKitService implements MlKitService {
  const MockMlKitService({
    this.stubbedTitle = '',
    this.stubbedSetCode,
    this.stubbedCollectorNumber,
    this.stubbedTranslationPrefix = '[ES]',
  });

  final String stubbedTitle;
  final String? stubbedSetCode;
  final String? stubbedCollectorNumber;
  final String stubbedTranslationPrefix;

  @override
  bool get isSupportedOnDevice => false;

  @override
  Future<CardScanMatch> extractCardDataFromImage(
    String imagePath, {
    String? languageCode,
  }) async => CardScanMatch(
    title: stubbedTitle,
    setCode: stubbedSetCode,
    collectorNumber: stubbedCollectorNumber,
  );

  @override
  Future<CardScanMatch> extractCardDataFromInputImage(
    InputImage inputImage, {
    Size? frameSize,
    String? languageCode,
  }) async => CardScanMatch(
    title: stubbedTitle,
    setCode: stubbedSetCode,
    collectorNumber: stubbedCollectorNumber,
  );

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
