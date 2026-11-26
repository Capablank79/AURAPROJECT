class BinderModel {
  const BinderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.family,
    required this.collectionCode,
    this.customCollectionName,
    String? category,
    required this.gridFormat,
    required this.maxSlots,
    required this.isFreeTier,
    required this.theme,
    required this.isPublic,
    this.isCompleted = false,
    required this.createdAt,
  }) : category =
           category ??
           (collectionCode == 'pokemon' || collectionCode == 'magic'
               ? collectionCode
               : 'custom');

  factory BinderModel.fromJson(Map<String, dynamic> json) {
    final rawCategory = (json['category'] as String?) ?? 'custom';
    final collectionCode =
        (json['collection_code'] as String?) ??
        (rawCategory == 'custom' ? 'figures' : rawCategory);
    final family =
        (json['family'] as String?) ??
        (rawCategory == 'custom' ? 'objects' : 'cards');

    return BinderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      family: family,
      collectionCode: collectionCode,
      customCollectionName: json['custom_collection_name'] as String?,
      category: rawCategory,
      gridFormat: json['grid_format'] as String,
      maxSlots: (json['max_slots'] as num).toInt(),
      isFreeTier: json['is_free_tier'] as bool,
      theme: json['theme'] as String,
      isPublic: json['is_public'] as bool,
      isCompleted: (json['is_completed'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String family;
  final String collectionCode;
  final String? customCollectionName;
  final String category;
  final String gridFormat;
  final int maxSlots;
  final bool isFreeTier;
  final String theme;
  final bool isPublic;
  final bool isCompleted;
  final DateTime createdAt;

  BinderModel copyWith({
    String? title,
    String? family,
    String? collectionCode,
    String? customCollectionName,
    String? category,
    String? gridFormat,
    int? maxSlots,
    bool? isFreeTier,
    String? theme,
    bool? isPublic,
    bool? isCompleted,
  }) {
    final nextCode = collectionCode ?? this.collectionCode;
    return BinderModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      family: family ?? this.family,
      collectionCode: nextCode,
      customCollectionName: customCollectionName ?? this.customCollectionName,
      category:
          category ??
          (nextCode == 'pokemon' || nextCode == 'magic' ? nextCode : 'custom'),
      gridFormat: gridFormat ?? this.gridFormat,
      maxSlots: maxSlots ?? this.maxSlots,
      isFreeTier: isFreeTier ?? this.isFreeTier,
      theme: theme ?? this.theme,
      isPublic: isPublic ?? this.isPublic,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'family': family,
    'collection_code': collectionCode,
    'custom_collection_name': customCollectionName,
    'category': category,
    'grid_format': gridFormat,
    'max_slots': maxSlots,
    'is_free_tier': isFreeTier,
    'theme': theme,
    'is_public': isPublic,
    'is_completed': isCompleted,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
