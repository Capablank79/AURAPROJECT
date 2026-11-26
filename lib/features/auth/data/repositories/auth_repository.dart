import '../../../../core/models/profile_model.dart';

abstract interface class AuthRepository {
  ProfileModel? get currentUser;

  Future<ProfileModel> signInWithGoogle({required String preferredLanguage});

  Future<ProfileModel> signInWithApple({required String preferredLanguage});

  Future<ProfileModel> signInWithEmail({
    required String email,
    required String password,
    required String preferredLanguage,
  });

  Future<ProfileModel?> updatePreferredLanguage(String languageCode);

  Future<void> signOut();
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
