class BinderModel {
  const BinderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.gridFormat,
    required this.maxSlots,
    required this.isFreeTier,
    required this.theme,
    required this.isPublic,
    required this.createdAt,
  });

  factory BinderModel.fromJson(Map<String, dynamic> json) {
    return BinderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      gridFormat: json['grid_format'] as String,
      maxSlots: (json['max_slots'] as num).toInt(),
      isFreeTier: json['is_free_tier'] as bool,
      theme: json['theme'] as String,
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String category;
  final String gridFormat;
  final int maxSlots;
  final bool isFreeTier;
  final String theme;
  final bool isPublic;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'category': category,
    'grid_format': gridFormat,
    'max_slots': maxSlots,
    'is_free_tier': isFreeTier,
    'theme': theme,
    'is_public': isPublic,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
