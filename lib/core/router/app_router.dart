import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/binder/presentation/binder_home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../providers/app_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final preferences = ref.read(sharedPreferencesProvider);
  final completed = preferences.getBool(onboardingCompleteKey) ?? false;

  return GoRouter(
    initialLocation: completed ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const BinderHomeScreen(),
      ),
    ],
  );
});
