import '../../../../core/models/profile_model.dart';
import 'repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({ProfileModel? initialUser}) : _currentUser = initialUser;

  ProfileModel? _currentUser;

  @override
  ProfileModel? get currentUser => _currentUser;

  @override
  Future<ProfileModel> signInWithGoogle({
    required String preferredLanguage,
  }) async {
    _currentUser = _demoProfile(preferredLanguage);
    return _currentUser!;
  }

  @override
  Future<ProfileModel> signInWithApple({
    required String preferredLanguage,
  }) async {
    _currentUser = _demoProfile(preferredLanguage);
    return _currentUser!;
  }

  @override
  Future<ProfileModel> signInWithEmail({
    required String email,
    required String password,
    required String preferredLanguage,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty ||
        !trimmedEmail.contains('@') ||
        password.isEmpty) {
      throw const AuthRepositoryException('Invalid email or password.');
    }
    _currentUser = _demoProfile(preferredLanguage);
    return _currentUser!;
  }

  @override
  Future<ProfileModel?> updatePreferredLanguage(String languageCode) async {
    final user = _currentUser;
    if (user == null) {
      return null;
    }
    _currentUser = user.copyWith(preferredLanguage: languageCode);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  static ProfileModel demoUser({String preferredLanguage = 'es'}) =>
      _demoProfile(preferredLanguage);

  static ProfileModel _demoProfile(String preferredLanguage) => ProfileModel(
    id: '00000000-0000-0000-0000-000000000010',
    username: 'coleccionista_aura',
    displayName: 'Coleccionista Aura',
    preferredLanguage: preferredLanguage,
    isPro: false,
    isAdmin: false,
    extraBinderCredits: 0,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}
