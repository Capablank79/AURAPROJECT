import '../../../core/collections/collection_registry.dart';
import '../../../core/models/item_model.dart';

class CatalogResult {
  const CatalogResult({
    required this.externalId,
    required this.name,
    required this.imageUrl,
    required this.collectionCode,
    required this.sourceType,
    required this.metadata,
    this.estimatedPrice,
  });

  final String externalId;
  final String name;
  final String imageUrl;
  final String collectionCode;
  final String sourceType;
  final Map<String, dynamic> metadata;
  final double? estimatedPrice;

  ItemModel toItem({
    required String binderId,
    required String userId,
    required int positionIndex,
    String condition = 'NM',
    bool isFoil = false,
  }) {
    return ItemModel(
      id: 'catalog-$collectionCode-$externalId-$positionIndex',
      binderId: binderId,
      userId: userId,
      collectionCode: collectionCode,
      sourceType: sourceType,
      externalId: externalId,
      name: name,
      imageUrl: imageUrl,
      isFoil: isFoil,
      condition: condition,
      estimatedPrice: estimatedPrice,
      positionIndex: positionIndex,
      metadata: metadata,
      createdAt: DateTime.now().toUtc(),
    );
  }
}

abstract interface class CatalogRepository {
  Future<List<CatalogResult>> search({
    required CatalogProvider provider,
    required String query,
    required String languageCode,
  });
}

class CatalogRepositoryException implements Exception {
  const CatalogRepositoryException(this.type);

  final CatalogErrorType type;
}

enum CatalogErrorType { offline, rateLimited, unavailable }
