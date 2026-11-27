class ItemTradeStatus {
  static const String none = 'none';
  static const String forTrade = 'for_trade';
  static const String forSale = 'for_sale';
  static const String wishlistApi = 'wishlist_api';
}

class ItemVerificationOrigin {
  static const String scanned = 'scanned';
  static const String photoWebp = 'photo_webp';
  static const String apiUnverified = 'api_unverified';
}

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

  /// True unless explicitly added from API search without optical scan.
  bool get isPhysicallyVerified =>
      metadata['verification_origin'] != ItemVerificationOrigin.apiUnverified;

  String get tradeStatus {
    if (!isPhysicallyVerified) {
      return ItemTradeStatus.wishlistApi;
    }
    final raw = metadata['trade_status']?.toString();
    if (raw == ItemTradeStatus.forTrade || raw == ItemTradeStatus.forSale) {
      return raw!;
    }
    return ItemTradeStatus.none;
  }

  String? get slabGrader {
    final raw = metadata['slab_grader']?.toString().trim();
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  String? get slabScore {
    final raw = metadata['slab_score']?.toString().trim();
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  String? get slabCert {
    final raw = metadata['slab_cert']?.toString().trim();
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  bool get hasSlab => slabGrader != null;

  double? get purchaseCost => (metadata['purchase_cost'] as num?)?.toDouble();

  int get manaOrEnergyCost => (metadata['cmc'] as num?)?.toInt() ?? 2;

  ItemModel withVaultMetadata({
    String? verificationOrigin,
    String? tradeStatus,
    String? slabGrader,
    bool clearSlab = false,
    String? slabScore,
    String? slabCert,
    double? purchaseCost,
  }) {
    final next = Map<String, dynamic>.from(metadata);
    if (verificationOrigin != null) {
      next['verification_origin'] = verificationOrigin;
    }
    if (tradeStatus != null) {
      next['trade_status'] = tradeStatus;
    }
    if (clearSlab) {
      next.remove('slab_grader');
      next.remove('slab_score');
      next.remove('slab_cert');
    } else {
      if (slabGrader != null) {
        if (slabGrader.trim().isEmpty) {
          next.remove('slab_grader');
        } else {
          next['slab_grader'] = slabGrader.trim();
        }
      }
      if (slabScore != null && slabScore.trim().isNotEmpty) {
        next['slab_score'] = slabScore.trim();
      }
      if (slabCert != null && slabCert.trim().isNotEmpty) {
        next['slab_cert'] = slabCert.trim();
      }
    }
    if (purchaseCost != null) {
      next['purchase_cost'] = purchaseCost;
    }
    return copyWith(metadata: next);
  }

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

class TrashedItemRecord {
  const TrashedItemRecord({
    required this.item,
    required this.binderTitle,
    required this.deletedAt,
  });

  final ItemModel item;
  final String binderTitle;
  final DateTime deletedAt;
}
