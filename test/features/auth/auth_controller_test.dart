import 'dart:async';

import 'package:app/src/core/error/result.dart';
import 'package:app/src/features/auth/application/auth_controller.dart';
import 'package:app/src/features/auth/application/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('AuthController', () {
    late FakeAuthRepository fake;
    late ProviderContainer container;

    setUp(() async {
      fake = FakeAuthRepository();
      container = await testContainer(authRepository: fake);
    });

    tearDown(() async {
      container.dispose();
      await fake.dispose();
    });

    test('starts unauthenticated when no user is present', () async {
      final value = await container
          .read(authControllerProvider.future)
          .timeout(const Duration(seconds: 1));
      expect(value, const AuthState.unauthenticated());
    });

    test('signIn happy-path transitions to authenticated', () async {
      // Drain initial event.
      await container.read(authControllerProvider.future);

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'a@b.com', password: 'pw');

      final state = await container.read(authControllerProvider.future);
      expect(state, isA<Authenticated>());
      expect((state as Authenticated).user.email, 'a@b.com');
    });

    test('signIn failure surfaces as AsyncError', () async {
      await container.read(authControllerProvider.future);

      fake.nextSignInResult = Result<sb.User>.err(
        fakeAuthFailure('bad credentials'),
      );

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'a@b.com', password: 'wrong');

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Object>());
    });

    test('signOut transitions back to unauthenticated', () async {
      // First sign in.
      await container.read(authControllerProvider.future);
      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'a@b.com', password: 'pw');
      await container.read(authControllerProvider.future);

      await container.read(authControllerProvider.notifier).signOut();
      final state = await container.read(authControllerProvider.future);
      expect(state, const AuthState.unauthenticated());
    });

    test(
      'signInWithGoogle launches OAuth and stays unauthenticated until '
      'the deep-link delivers a session',
      () async {
        await container.read(authControllerProvider.future);

        // Subscribe before emitting so we can observe the post-deep-link
        // transition without depending on microtask timing.
        final authedCompleter = Completer<AuthState>();
        final sub = container.listen<AsyncValue<AuthState>>(
          authControllerProvider,
          (_, next) {
            final value = next.hasValue ? next.requireValue : null;
            if (value is Authenticated && !authedCompleter.isCompleted) {
              authedCompleter.complete(value);
            }
          },
        );
        addTearDown(sub.close);

        await container
            .read(authControllerProvider.notifier)
            .signInWithGoogle();

        expect(fake.googleSignInCount, 1);
        // Browser launched; we don't have a session yet.
        final pending = await container.read(authControllerProvider.future);
        expect(pending, const AuthState.unauthenticated());

        // Simulate the deep-link round-trip: Supabase emits a session.
        final user = sb.User(
          id: 'oauth-user-id',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          email: 'g@example.com',
          createdAt: DateTime.now().toIso8601String(),
        );
        fake.emit(user);

        final authed = await authedCompleter.future.timeout(
          const Duration(seconds: 1),
        );
        expect(authed, isA<Authenticated>());
        expect((authed as Authenticated).user.email, 'g@example.com');
      },
    );

    test('signInWithGoogle failure surfaces as AsyncError', () async {
      await container.read(authControllerProvider.future);

      fake.nextGoogleResult = Result<bool>.err(
        fakeAuthFailure('redirect not allow-listed'),
      );

      await container
          .read(authControllerProvider.notifier)
          .signInWithGoogle();

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
    });
  });
}
