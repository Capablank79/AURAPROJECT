class ItemModel {
  const ItemModel({
    required this.id,
    required this.binderId,
    required this.userId,
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
    return ItemModel(
      id: json['id'] as String,
      binderId: json['binder_id'] as String,
      userId: json['user_id'] as String,
      sourceType: json['source_type'] as String,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'binder_id': binderId,
    'user_id': userId,
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
