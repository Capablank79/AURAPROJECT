class DeckModel {
  const DeckModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.gameType,
    this.format,
    required this.cardIds,
    required this.createdAt,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      gameType: json['game_type'] as String,
      format: json['format'] as String?,
      cardIds: List<String>.from((json['card_ids'] as List?) ?? const []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String gameType;
  final String? format;
  final List<String> cardIds;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'game_type': gameType,
    'format': format,
    'card_ids': cardIds,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
