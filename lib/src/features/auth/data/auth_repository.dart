import 'package:app/src/core/error/error_mapper.dart';
import 'package:app/src/core/error/result.dart';
import 'package:app/src/core/providers/app_config_provider.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'auth_repository.g.dart';

/// Boundary between the rest of the app and Supabase auth.
///
/// All public methods return `Result<...>` — they never throw — so
/// controllers/UI can pattern-match on success vs. failure without
/// catch-blocks scattered through the call site.
abstract class AuthRepository {
  /// Stream of auth state changes from the SDK. Emits the current state
  /// immediately on listen.
  Stream<sb.AuthState> get onAuthStateChange;

  /// Currently signed-in user, or `null`.
  sb.User? get currentUser;

  Future<Result<sb.User>> signInWithPassword({
    required String email,
    required String password,
  });

  Future<Result<sb.User?>> signUpWithPassword({
    required String email,
    required String password,
  });

  /// Kicks off the Google OAuth flow. Returns `true` when the external
  /// browser was launched successfully — the actual session arrives
  /// asynchronously via [onAuthStateChange] once Supabase redirects back
  /// through the configured deep link.
  Future<Result<bool>> signInWithGoogle();

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordReset(String email);
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required String oauthRedirectUrl,
    sb.SupabaseClient? client,
    ErrorMapper mapper = const ErrorMapper(),
  }) : _client = client ?? sb.Supabase.instance.client,
       _mapper = mapper,
       _oauthRedirectUrl = oauthRedirectUrl;

  final sb.SupabaseClient _client;
  final ErrorMapper _mapper;
  final String _oauthRedirectUrl;

  @visibleForTesting
  sb.SupabaseClient get client => _client;

  @override
  Stream<sb.AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  sb.User? get currentUser => _client.auth.currentUser;

  @override
  Future<Result<sb.User>> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _mapper.guard(() async {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const sb.AuthException('Sign-in returned no user');
      }
      return user;
    });
  }

  @override
  Future<Result<sb.User?>> signUpWithPassword({
    required String email,
    required String password,
  }) {
    return _mapper.guard(() async {
      final res = await _client.auth.signUp(email: email, password: password);
      // user is null when email confirmation is required.
      return res.user;
    });
  }

  @override
  Future<Result<bool>> signInWithGoogle() {
    return _mapper.guard(
      () => _client.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        // Native flow: an external browser opens, the user authenticates,
        // and Supabase redirects back to [_oauthRedirectUrl]. The
        // supabase_flutter SDK installs an app_links listener at
        // initialize() time and completes the session for us.
        redirectTo: _oauthRedirectUrl.isEmpty ? null : _oauthRedirectUrl,
      ),
    );
  }

  @override
  Future<Result<void>> signOut() => _mapper.guard(_client.auth.signOut);

  @override
  Future<Result<void>> sendPasswordReset(String email) {
    return _mapper.guard(() => _client.auth.resetPasswordForEmail(email));
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return SupabaseAuthRepository(oauthRedirectUrl: config.oauthRedirectUrl);
}
