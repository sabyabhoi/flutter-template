import 'dart:async';

import 'package:app/src/core/error/failure.dart';
import 'package:app/src/core/error/result.dart';
import 'package:app/src/core/storage/secure_storage.dart';
import 'package:app/src/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// In-memory [AuthRepository] for tests. Lets you script success/failure
/// per call and pump synthetic auth events through [emit].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({sb.User? initialUser}) : _currentUser = initialUser;

  final _controller = StreamController<sb.AuthState>.broadcast();
  sb.User? _currentUser;

  /// Optional override for the next signIn/signUp/signOut call.
  Result<sb.User>? nextSignInResult;
  Result<sb.User?>? nextSignUpResult;
  Result<void>? nextSignOutResult;
  Result<bool>? nextGoogleResult;

  /// Number of times [signInWithGoogle] has been called. Useful for
  /// asserting the OAuth flow was kicked off without having to spin up
  /// a real browser.
  int googleSignInCount = 0;

  @override
  sb.User? get currentUser => _currentUser;

  @override
  Stream<sb.AuthState> get onAuthStateChange => _controller.stream;

  /// Push a synthetic event through the auth stream. Mutates [currentUser]
  /// to match [user] so subsequent reads stay in sync.
  void emit(sb.User? user, {sb.AuthChangeEvent? event}) {
    _currentUser = user;
    final session = user == null
        ? null
        : sb.Session(
            accessToken: 'fake-token',
            tokenType: 'bearer',
            user: user,
          );
    _controller.add(
      sb.AuthState(event ?? sb.AuthChangeEvent.signedIn, session),
    );
  }

  @override
  Future<Result<sb.User>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final r = nextSignInResult;
    if (r != null) {
      nextSignInResult = null;
      if (r case Ok(:final value)) emit(value);
      return r;
    }
    final user = sb.User(
      id: 'fake-user-id',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      email: email,
      createdAt: DateTime.now().toIso8601String(),
    );
    emit(user);
    return Result<sb.User>.ok(user);
  }

  @override
  Future<Result<sb.User?>> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    final r = nextSignUpResult;
    if (r != null) {
      nextSignUpResult = null;
      return r;
    }
    return signInWithPassword(
      email: email,
      password: password,
    ).then((r) => r.map<sb.User?>((u) => u));
  }

  @override
  Future<Result<bool>> signInWithGoogle() async {
    googleSignInCount++;
    final r = nextGoogleResult;
    if (r != null) {
      nextGoogleResult = null;
      return r;
    }
    // Default success: pretend the browser launched but no session has
    // arrived yet. Tests that want a session can call [emit] explicitly.
    return const Result<bool>.ok(true);
  }

  @override
  Future<Result<void>> signOut() async {
    final r = nextSignOutResult;
    if (r != null) {
      nextSignOutResult = null;
      return r;
    }
    emit(null, event: sb.AuthChangeEvent.signedOut);
    return const Result<void>.ok(null);
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async =>
      const Result<void>.ok(null);

  Future<void> dispose() => _controller.close();
}

/// Convenience for scripting auth failures without constructing a Failure
/// by hand.
Failure fakeAuthFailure(String message) => Failure.auth(message: message);

/// In-memory [SecureStorage] for tests.
class FakeSecureStorage implements SecureStorage {
  final _store = <String, String>{};

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }
}
