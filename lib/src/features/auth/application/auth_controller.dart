import 'package:app/src/core/error/failure.dart';
import 'package:app/src/core/error/result.dart';
import 'package:app/src/features/auth/application/auth_state.dart';
import 'package:app/src/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'auth_controller.g.dart';

/// Stream of underlying auth events from the SDK. Wrapped as a Riverpod
/// `StreamProvider` so [AuthController] can `ref.listen` to it without
/// owning subscription lifecycle.
@Riverpod(keepAlive: true)
Stream<sb.AuthState> authEvents(Ref ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
}

/// Single source of truth for "is the user signed in?" used by the router
/// guard and by feature controllers.
///
/// Resolves the initial auth state synchronously on `build`, then keeps
/// it in sync with [authEventsProvider]. Mutations (`signIn`/`signUp`/
/// `signOut`) drive the state explicitly so the UI shows loading/error
/// states promptly.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthState> build() async {
    final repo = ref.watch(authRepositoryProvider);

    // Push live auth-event updates into state, syncing Sentry on the way.
    ref.listen<AsyncValue<sb.AuthState>>(
      authEventsProvider,
      (previous, next) {
        next.whenData((event) {
          final projected = _project(event.session?.user);
          state = AsyncData<AuthState>(projected);
          _syncSentryUser(projected);
        });
      },
    );

    final initial = _project(repo.currentUser);
    _syncSentryUser(initial);
    return initial;
  }

  /// Sign in with email/password. Updates state through loading then
  /// success/error.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading<AuthState>();
    final result = await repo.signInWithPassword(
      email: email,
      password: password,
    );
    _applyAuthResult(result.map<AuthState>(Authenticated.new));
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading<AuthState>();
    final result = await repo.signUpWithPassword(
      email: email,
      password: password,
    );
    _applyAuthResult(
      result.map<AuthState>(
        (user) => user == null ? const Unauthenticated() : Authenticated(user),
      ),
    );
  }

  /// Launches the Google OAuth flow. The session itself arrives later via
  /// [authEventsProvider] once Supabase redirects back through the
  /// configured deep link, so on success we *don't* flip to
  /// `Authenticated` here — we just clear the loading state. On failure
  /// (e.g. user cancelled the browser, no allow-listed redirect) we
  /// surface the error like any other auth mutation.
  Future<void> signInWithGoogle() async {
    final repo = ref.read(authRepositoryProvider);
    final previous = state.hasValue
        ? state.requireValue
        : const Unauthenticated();
    state = const AsyncLoading<AuthState>();
    final result = await repo.signInWithGoogle();
    switch (result) {
      case Ok():
        // Stay unauthenticated until the deep link delivers a session.
        state = AsyncData<AuthState>(previous);
      case Err(:final failure):
        state = AsyncError<AuthState>(failure, _stackOf(failure));
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading<AuthState>();
    final result = await repo.signOut();
    _applyAuthResult(result.map<AuthState>((_) => const Unauthenticated()));
  }

  void _applyAuthResult(Result<AuthState> result) {
    switch (result) {
      case Ok(:final value):
        state = AsyncData<AuthState>(value);
      case Err(:final failure):
        state = AsyncError<AuthState>(failure, _stackOf(failure));
    }
  }

  static StackTrace _stackOf(Failure failure) => switch (failure) {
    NetworkFailure(:final stackTrace) => stackTrace ?? StackTrace.empty,
    AuthFailure(:final stackTrace) => stackTrace ?? StackTrace.empty,
    ServerFailure(:final stackTrace) => stackTrace ?? StackTrace.empty,
    ValidationFailure() => StackTrace.empty,
    UnknownFailure(:final stackTrace) => stackTrace ?? StackTrace.empty,
  };

  AuthState _project(sb.User? user) =>
      user == null ? const Unauthenticated() : Authenticated(user);

  void _syncSentryUser(AuthState state) {
    if (!Sentry.isEnabled) return;
    // Sentry's scope APIs are fire-and-forget here.
    // ignore: discarded_futures
    Sentry.configureScope((scope) async {
      switch (state) {
        case Authenticated(:final user):
          await scope.setUser(SentryUser(id: user.id, email: user.email));
        case Unauthenticated():
        case AuthInitial():
          await scope.setUser(null);
      }
    });
  }
}
