import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'auth_state.freezed.dart';

/// What the rest of the app sees about the user's auth status.
///
/// Sourced from `Supabase.instance.client.auth.onAuthStateChange` and held
/// by `authControllerProvider`. Routing redirects key off this.
@freezed
sealed class AuthState with _$AuthState {
  const AuthState._();

  /// Initial state before the first auth event has been observed.
  const factory AuthState.initial() = AuthInitial;

  /// User has a valid session.
  const factory AuthState.authenticated(sb.User user) = Authenticated;

  /// User is signed out (no session, or session was just cleared).
  const factory AuthState.unauthenticated() = Unauthenticated;

  bool get isAuthenticated => this is Authenticated;
  bool get isUnauthenticated => this is Unauthenticated;
}
