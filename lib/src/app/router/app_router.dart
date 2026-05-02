import 'package:app/src/app/router/routes.dart';
import 'package:app/src/features/auth/application/auth_controller.dart';
import 'package:app/src/features/auth/application/auth_state.dart';
import 'package:app/src/features/auth/presentation/sign_in_screen.dart';
import 'package:app/src/features/auth/presentation/sign_up_screen.dart';
import 'package:app/src/features/auth/presentation/splash_screen.dart';
import 'package:app/src/features/home/presentation/home_screen.dart';
import 'package:app/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Singleton [GoRouter] for the app.
///
/// Auth-aware via the [_GoRouterRefreshNotifier] below: any change to
/// [authControllerProvider] triggers `redirect`, which sends the user to
/// `/sign-in` when unauthenticated and away from auth routes when
/// authenticated.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = _GoRouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);

      // While we don't yet know whether the user is signed in, sit on the
      // splash screen — don't bounce them into sign-in prematurely.
      if (auth.isLoading || !auth.hasValue) {
        return state.matchedLocation == AppRoute.splash.path
            ? null
            : AppRoute.splash.path;
      }

      final value = auth.requireValue;
      final loggingIn =
          state.matchedLocation == AppRoute.signIn.path ||
          state.matchedLocation == AppRoute.signUp.path;
      final onSplash = state.matchedLocation == AppRoute.splash.path;

      switch (value) {
        case Authenticated():
          if (loggingIn || onSplash) return AppRoute.home.path;
          return null;
        case Unauthenticated():
          if (loggingIn) return null;
          return AppRoute.signIn.path;
        case AuthInitial():
          return onSplash ? null : AppRoute.splash.path;
      }
    },
    routes: [
      GoRoute(
        name: AppRoute.splash.name,
        path: AppRoute.splash.path,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoute.signIn.name,
        path: AppRoute.signIn.path,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        name: AppRoute.signUp.name,
        path: AppRoute.signUp.path,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        name: AppRoute.home.name,
        path: AppRoute.home.path,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            name: AppRoute.settings.name,
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Bridges `ref.listen(authControllerProvider, …)` into a `Listenable`
/// that `GoRouter.refreshListenable` understands.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<AuthState>>(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
  }
}
