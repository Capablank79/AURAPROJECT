import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/binder/presentation/binder_detail_screen.dart';
import '../../features/binder/presentation/binder_home_screen.dart';
import '../../features/binder/presentation/item_detail_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../providers/app_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final preferences = ref.read(sharedPreferencesProvider);
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final completed = preferences.getBool(onboardingCompleteKey) ?? false;
  final initialUser = ref.read(authStateProvider);
  final initialLocation = !completed
      ? '/onboarding'
      : (initialUser == null ? '/auth' : '/home');

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location.startsWith('/public/') || location.startsWith('/u/')) {
        return null;
      }

      final user = ref.read(authStateProvider);
      final onboardingComplete =
          preferences.getBool(onboardingCompleteKey) ?? false;

      if (user == null) {
        if (location == '/auth') {
          return null;
        }
        if (location == '/onboarding' && !onboardingComplete) {
          return null;
        }
        return '/auth';
      }

      if (location == '/auth') {
        return onboardingComplete ? '/home' : '/onboarding';
      }
      if (location == '/onboarding' && onboardingComplete) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const BinderHomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(asScaffold: true),
      ),
      GoRoute(
        path: '/binder/:binderId',
        builder: (context, state) =>
            BinderDetailScreen(binderId: state.pathParameters['binderId']!),
      ),
      GoRoute(
        path: '/binder/:binderId/item/:itemId',
        builder: (context, state) => ItemDetailScreen(
          binderId: state.pathParameters['binderId']!,
          itemId: state.pathParameters['itemId']!,
        ),
      ),
      GoRoute(
        path: '/binder/:binderId/catalog',
        builder: (context, state) => CatalogScreen(
          binderId: state.pathParameters['binderId']!,
          positionIndex:
              int.tryParse(state.uri.queryParameters['position'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/u/:username/:binderId',
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          final binderId = state.pathParameters['binderId']!;
          return BinderDetailScreen(
            binderId: binderId,
            publicView: true,
            publicBasePath: '/u/$username/$binderId',
          );
        },
      ),
      GoRoute(
        path: '/u/:username/:binderId/item/:itemId',
        builder: (context, state) => ItemDetailScreen(
          binderId: state.pathParameters['binderId']!,
          itemId: state.pathParameters['itemId']!,
          publicView: true,
        ),
      ),
      GoRoute(
        path: '/public/binder/:binderId',
        builder: (context, state) => BinderDetailScreen(
          binderId: state.pathParameters['binderId']!,
          publicView: true,
        ),
      ),
      GoRoute(
        path: '/public/binder/:binderId/item/:itemId',
        builder: (context, state) => ItemDetailScreen(
          binderId: state.pathParameters['binderId']!,
          itemId: state.pathParameters['itemId']!,
          publicView: true,
        ),
      ),
    ],
  );
});
