import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile_model.dart';
import '../../../core/providers/app_providers.dart';
import '../data/mock_auth_repository.dart';
import '../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

final authStateProvider = NotifierProvider<AuthController, ProfileModel?>(
  AuthController.new,
);

class AuthController extends Notifier<ProfileModel?> {
  @override
  ProfileModel? build() {
    return ref.watch(authRepositoryProvider).currentUser;
  }

  Future<ProfileModel> signInWithGoogle() async {
    final lang = ref.read(appLocaleProvider).languageCode;
    final user = await ref
        .read(authRepositoryProvider)
        .signInWithGoogle(preferredLanguage: lang);
    state = user;
    return user;
  }

  Future<ProfileModel> signInWithApple() async {
    final lang = ref.read(appLocaleProvider).languageCode;
    final user = await ref
        .read(authRepositoryProvider)
        .signInWithApple(preferredLanguage: lang);
    state = user;
    return user;
  }

  Future<ProfileModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final lang = ref.read(appLocaleProvider).languageCode;
    final user = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(
          email: email,
          password: password,
          preferredLanguage: lang,
        );
    state = user;
    return user;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}
