import 'package:app/src/features/auth/presentation/sign_in_form.dart';
import 'package:app/src/features/onboarding/application/onboarding_controller.dart';
import 'package:app/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('starts on the welcome page with Back disabled', (
      tester,
    ) async {
      final fake = FakeAuthRepository();
      addTearDown(fake.dispose);
      await pumpApp(tester, const OnboardingScreen(), authRepository: fake);

      expect(find.text('Welcome'), findsOneWidget);

      final back = tester.widget<TextButton>(
        find.byKey(const Key('onboarding.back')),
      );
      expect(back.onPressed, isNull);
    });

    testWidgets('Next advances through pages and reveals the SignInForm', (
      tester,
    ) async {
      final fake = FakeAuthRepository();
      addTearDown(fake.dispose);
      await pumpApp(tester, const OnboardingScreen(), authRepository: fake);

      // 5 taps: welcome → how-it-works → name → motivation → goal → auth.
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('onboarding.next')));
        await tester.pumpAndSettle();
      }

      expect(find.byType(SignInForm), findsOneWidget);
      // The bottom nav bar is hidden on the final page.
      expect(find.byKey(const Key('onboarding.next')), findsNothing);
      expect(find.byKey(const Key('onboarding.back')), findsNothing);
    });

    testWidgets('reaching the final page marks onboarding complete', (
      tester,
    ) async {
      final fake = FakeAuthRepository();
      addTearDown(fake.dispose);
      final container = await pumpApp(
        tester,
        const OnboardingScreen(),
        authRepository: fake,
      );

      expect(
        container.read(onboardingControllerProvider).completed,
        isFalse,
      );

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('onboarding.next')));
        await tester.pumpAndSettle();
      }

      expect(
        container.read(onboardingControllerProvider).completed,
        isTrue,
      );
    });

    testWidgets('typing on the name page persists to the controller', (
      tester,
    ) async {
      final fake = FakeAuthRepository();
      addTearDown(fake.dispose);
      final container = await pumpApp(
        tester,
        const OnboardingScreen(),
        authRepository: fake,
      );

      // Advance to the name page (welcome → how-it-works → name).
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('onboarding.next')));
        await tester.pumpAndSettle();
      }

      await tester.enterText(
        find.byKey(const Key('onboarding.name')),
        'Alex',
      );
      // Allow the awaited `setName` future to settle.
      await tester.pump();

      expect(
        container.read(onboardingControllerProvider).answers.name,
        'Alex',
      );
    });
  });
}
