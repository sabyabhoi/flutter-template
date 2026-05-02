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
  });
}
