class DeckCardEntry {
  const DeckCardEntry({
    required this.name,
    required this.quantity,
    this.cost = 2,
    this.estimatedUnitUsd = 4.5,
  });

  final String name;
  final int quantity;
  final int cost;
  final double estimatedUnitUsd;

  DeckCardEntry copyWith({
    String? name,
    int? quantity,
    int? cost,
    double? estimatedUnitUsd,
  }) {
    return DeckCardEntry(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      estimatedUnitUsd: estimatedUnitUsd ?? this.estimatedUnitUsd,
    );
  }
}

class DeckModel {
  const DeckModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.gameType,
    this.format,
    required this.cardIds,
    this.entries = const [],
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
  final List<DeckCardEntry> entries;
  final DateTime createdAt;

  int get totalCards => entries.isEmpty
      ? cardIds.length
      : entries.fold<int>(0, (sum, entry) => sum + entry.quantity);

  DeckModel copyWith({
    String? title,
    String? gameType,
    String? format,
    List<String>? cardIds,
    List<DeckCardEntry>? entries,
  }) {
    return DeckModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      gameType: gameType ?? this.gameType,
      format: format ?? this.format,
      cardIds: cardIds ?? this.cardIds,
      entries: entries ?? this.entries,
      createdAt: createdAt,
    );
  }

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
