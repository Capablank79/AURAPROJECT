import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/card_text_extractor_service.dart';
import '../../../core/services/media_storage_service.dart';
import '../../../core/services/ml_kit_service.dart';
import '../../../core/utils/image_compressor.dart';
import '../data/catalog_repository.dart';
import '../data/http_catalog_repository.dart';
import '../data/mock_card_strategy_repository.dart';
import '../data/repositories/card_strategy_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => HttpCatalogRepository(),
);

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final imageCompressorProvider = Provider<ImageCompressor>(
  (ref) => const AuraImageCompressor(),
);

final mediaStorageServiceProvider = Provider<MediaStorageService>(
  (ref) => MockMediaStorageService(),
);

final cardTextExtractorProvider = Provider<CardTextExtractorService>(
  (ref) => const MlKitCardTextExtractorService(),
);

final mlKitServiceProvider = Provider<MlKitService>((ref) {
  final service = DeviceMlKitService();
  ref.onDispose(service.dispose);
  return service;
});

final cardStrategyRepositoryProvider = Provider<CardStrategyRepository>(
  (ref) => const MockCardStrategyRepository(),
);

/// Contador diario simulado de análisis Aura AI (máx. 3/día en plan gratuito).
final aiDailyUsageProvider = StateProvider<int>((ref) => 0);
