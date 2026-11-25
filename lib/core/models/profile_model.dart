class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.preferredLanguage,
    required this.isPro,
    required this.isAdmin,
    required this.extraBinderCredits,
    this.revenuecatAppUserId,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferredLanguage: (json['preferred_language'] as String?) ?? 'es',
      isPro: (json['is_pro'] as bool?) ?? false,
      isAdmin: (json['is_admin'] as bool?) ?? false,
      extraBinderCredits: (json['extra_binder_credits'] as num?)?.toInt() ?? 0,
      revenuecatAppUserId: json['revenuecat_app_user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String preferredLanguage;
  final bool isPro;
  final bool isAdmin;
  final int extraBinderCredits;
  final String? revenuecatAppUserId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'preferred_language': preferredLanguage,
    'is_pro': isPro,
    'is_admin': isAdmin,
    'extra_binder_credits': extraBinderCredits,
    'revenuecat_app_user_id': revenuecatAppUserId,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
