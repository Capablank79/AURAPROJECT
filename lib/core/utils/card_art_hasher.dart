import 'dart:typed_data';

import '../../features/catalog/data/catalog_repository.dart';
import '../services/ml_kit_service.dart';

/// Utilidad pura y ultrarrápida (<0.1 ms) inspirada en MagicFrame para:
/// 1) Calcular una huella perceptual de 64 bits (Difference Hash 9x8) sobre el
///    plano de luminancia (Y) de la ilustración central de una carta.
/// 2) Puntuar y ordenar ediciones candidatas combinando código de set, número
///    de coleccionista, exactitud de título y distancia Hamming visual.
class CardArtHasher {
  const CardArtHasher._();

  /// Calcula un dHash de 64 bits muestreando la región del arte (20%..80% X,
  /// 18%..58% Y) directamente sobre un plano en escala de grises (ej. YUV Y-plane).
  static int computeLuminanceDHash({
    required Uint8List yPlane,
    required int width,
    required int height,
    required int bytesPerRow,
  }) {
    if (width < 18 || height < 16 || yPlane.isEmpty) {
      return 0;
    }
    final cropLeft = (width * 0.20).floor();
    final cropWidth = (width * 0.60).floor().clamp(9, width - cropLeft);
    final cropTop = (height * 0.18).floor();
    final cropHeight = (height * 0.40).floor().clamp(8, height - cropTop);

    var hash = 0;
    var bitIndex = 0;

    for (var row = 0; row < 8; row++) {
      final y = cropTop + ((row * cropHeight) ~/ 8);
      var prevLum = _sampleY(
        yPlane,
        x: cropLeft,
        y: y,
        bytesPerRow: bytesPerRow,
      );
      for (var col = 1; col <= 8; col++) {
        final x = cropLeft + ((col * cropWidth) ~/ 9);
        final currLum = _sampleY(
          yPlane,
          x: x,
          y: y,
          bytesPerRow: bytesPerRow,
        );
        if (currLum > prevLum) {
          hash |= (1 << bitIndex);
        }
        prevLum = currLum;
        bitIndex++;
      }
    }
    return hash;
  }

  static int _sampleY(
    Uint8List plane, {
    required int x,
    required int y,
    required int bytesPerRow,
  }) {
    final offset = y * bytesPerRow + x;
    if (offset < 0 || offset >= plane.length) {
      return 0;
    }
    return plane[offset];
  }

  /// Distancia Hamming (0 = idénticas, 64 = opuestas) entre dos huellas de 64 bits.
  static int hammingDistance64(int a, int b) {
    var xor = a ^ b;
    var count = 0;
    for (var i = 0; i < 64; i++) {
      if ((xor & 1) != 0) {
        count++;
      }
      xor = xor >>> 1;
    }
    return count;
  }

  /// Ordena las variantes/ediciones devueltas por el catálogo de mayor a menor
  /// afinidad con la lectura zonal de cámara y su huella visual opcional.
  static List<CatalogResult> rankCandidates(
    List<CatalogResult> candidates,
    CardScanMatch match, {
    int? capturedArtHash,
    Map<String, int> candidateHashes = const {},
  }) {
    if (candidates.length <= 1) {
      return candidates;
    }
    final targetNum = _normalizeNumber(match.collectorNumber);
    final targetSet = match.setCode?.trim().toUpperCase();
    final targetTitle = match.title.trim().toLowerCase();

    final scored = candidates.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      var score = 0;

      if (item.name.trim().toLowerCase() == targetTitle) {
        score += 25;
      }
      if (targetNum != null) {
        final itemNum = _normalizeNumber(item.metadata['number']?.toString());
        if (itemNum == targetNum) {
          score += 65;
        }
      }
      if (targetSet != null && targetSet.isNotEmpty) {
        final rawSet = (item.metadata['set_code'] ??
                item.metadata['set'] ??
                item.metadata['expansion'] ??
                '')
            .toString()
            .toUpperCase();
        if (rawSet == targetSet || rawSet.contains(targetSet)) {
          score += 50;
        }
      }
      final refHash = candidateHashes[item.externalId];
      if (capturedArtHash != null && capturedArtHash != 0 && refHash != null) {
        final dist = hammingDistance64(capturedArtHash, refHash);
        score += (64 - dist);
      }

      return (item: item, score: score, originalIndex: idx);
    }).toList();

    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      return cmp != 0 ? cmp : a.originalIndex.compareTo(b.originalIndex);
    });
    return scored.map((e) => e.item).toList();
  }

  static String? _normalizeNumber(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final firstPart = raw.split('/').first.trim().replaceFirst(RegExp(r'^#?0+'), '');
    return firstPart.isEmpty ? '0' : firstPart.toUpperCase();
  }
}
