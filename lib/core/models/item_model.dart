class ItemModel {
  const ItemModel({
    required this.id,
    required this.binderId,
    required this.userId,
    required this.collectionCode,
    required this.sourceType,
    this.externalId,
    required this.name,
    required this.imageUrl,
    required this.isFoil,
    required this.condition,
    this.estimatedPrice,
    required this.positionIndex,
    required this.metadata,
    this.notes,
    required this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final sourceType = json['source_type'] as String;
    final inferredCode = switch (sourceType) {
      'api_scryfall' => 'magic',
      'api_tcgdex' => 'pokemon',
      'api_ygoprodeck' => 'yugioh',
      _ => 'figures',
    };
    return ItemModel(
      id: json['id'] as String,
      binderId: json['binder_id'] as String,
      userId: json['user_id'] as String,
      collectionCode: (json['collection_code'] as String?) ?? inferredCode,
      sourceType: sourceType,
      externalId: json['external_id'] as String?,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      isFoil: (json['is_foil'] as bool?) ?? false,
      condition: (json['condition'] as String?) ?? 'NM',
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble(),
      positionIndex: (json['position_index'] as num).toInt(),
      metadata: Map<String, dynamic>.from(
        (json['metadata'] as Map?) ?? const {},
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String binderId;
  final String userId;
  final String collectionCode;
  final String sourceType;
  final String? externalId;
  final String name;
  final String imageUrl;
  final bool isFoil;
  final String condition;
  final double? estimatedPrice;
  final int positionIndex;
  final Map<String, dynamic> metadata;
  final String? notes;
  final DateTime createdAt;

  ItemModel copyWith({
    String? collectionCode,
    String? name,
    String? imageUrl,
    bool? isFoil,
    String? condition,
    double? estimatedPrice,
    int? positionIndex,
    Map<String, dynamic>? metadata,
    String? notes,
  }) {
    return ItemModel(
      id: id,
      binderId: binderId,
      userId: userId,
      collectionCode: collectionCode ?? this.collectionCode,
      sourceType: sourceType,
      externalId: externalId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isFoil: isFoil ?? this.isFoil,
      condition: condition ?? this.condition,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      positionIndex: positionIndex ?? this.positionIndex,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'binder_id': binderId,
    'user_id': userId,
    'collection_code': collectionCode,
    'source_type': sourceType,
    'external_id': externalId,
    'name': name,
    'image_url': imageUrl,
    'is_foil': isFoil,
    'condition': condition,
    'estimated_price': estimatedPrice,
    'position_index': positionIndex,
    'metadata': metadata,
    'notes': notes,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
