class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.tradeContact,
    required this.preferredLanguage,
    required this.isPro,
    required this.isAdmin,
    required this.extraBinderCredits,
    this.availableSlots = 0,
    this.revenuecatAppUserId,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      tradeContact: json['trade_contact'] as String?,
      preferredLanguage: (json['preferred_language'] as String?) ?? 'es',
      isPro: (json['is_pro'] as bool?) ?? false,
      isAdmin: (json['is_admin'] as bool?) ?? false,
      extraBinderCredits: (json['extra_binder_credits'] as num?)?.toInt() ?? 0,
      availableSlots: (json['available_slots'] as num?)?.toInt() ?? 0,
      revenuecatAppUserId: json['revenuecat_app_user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? tradeContact;
  final String preferredLanguage;
  final bool isPro;
  final bool isAdmin;
  final int extraBinderCredits;
  final int availableSlots;
  final String? revenuecatAppUserId;
  final DateTime createdAt;

  String get initials {
    final source = (displayName?.trim().isNotEmpty == true)
        ? displayName!.trim()
        : username.trim();
    if (source.isEmpty) {
      return 'AC';
    }
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return source.substring(0, source.length >= 2 ? 2 : 1).toUpperCase();
  }

  ProfileModel copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    String? tradeContact,
    bool clearTradeContact = false,
    String? preferredLanguage,
    bool? isPro,
    bool? isAdmin,
    int? extraBinderCredits,
    int? availableSlots,
    String? revenuecatAppUserId,
  }) {
    return ProfileModel(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tradeContact: clearTradeContact
          ? null
          : (tradeContact ?? this.tradeContact),
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isPro: isPro ?? this.isPro,
      isAdmin: isAdmin ?? this.isAdmin,
      extraBinderCredits: extraBinderCredits ?? this.extraBinderCredits,
      availableSlots: availableSlots ?? this.availableSlots,
      revenuecatAppUserId: revenuecatAppUserId ?? this.revenuecatAppUserId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    if (tradeContact != null) 'trade_contact': tradeContact,
    'preferred_language': preferredLanguage,
    'is_pro': isPro,
    'is_admin': isAdmin,
    'extra_binder_credits': extraBinderCredits,
    'revenuecat_app_user_id': revenuecatAppUserId,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
