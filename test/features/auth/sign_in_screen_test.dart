import 'package:app/src/features/auth/presentation/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('SignInScreen', () {
    testWidgets('renders email + password fields and submit button', (
      tester,
    ) async {
      final fake = FakeAuthRepository();
      addTearDown(fake.dispose);
      await pumpApp(tester, const SignInScreen(), authRepository: fake);

      expect(find.byKey(const Key('signIn.email')), findsOneWidget);
      expect(find.byKey(const Key('signIn.password')), findsOneWidget);
      expect(find.byKey(const Key('signIn.submit')), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      final fake = FakeAuthRepository();
      addTearDown(fake.dispose);
      await pumpApp(tester, const SignInScreen(), authRepository: fake);

      // Ensure the submit button is on-screen before tapping it. With the
      // default 600x800 test viewport the button can be off-screen on the
      // SignInScreen layout.
      final submit = find.byKey(const Key('signIn.submit'));
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('successful sign-in calls the repository', (tester) async {
      final fake = FakeAuthRepository();
      addTearDown(fake.dispose);
      await pumpApp(tester, const SignInScreen(), authRepository: fake);

      await tester.enterText(
        find.byKey(const Key('signIn.email')),
        'a@b.com',
      );
      await tester.enterText(
        find.byKey(const Key('signIn.password')),
        'password123',
      );
      final submit = find.byKey(const Key('signIn.submit'));
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit, warnIfMissed: false);
      // Pump enough frames for the AsyncLoading → Authenticated transition
      // and the SnackBar listener to settle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(fake.currentUser, isNotNull);
      expect(fake.currentUser!.email, 'a@b.com');
    });
  });
}
