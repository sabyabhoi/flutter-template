import 'dart:convert';

import 'package:app/src/core/storage/prefs.dart';
import 'package:app/src/features/onboarding/application/onboarding_answers.dart';
import 'package:app/src/features/onboarding/application/onboarding_controller.dart';
import 'package:app/src/features/onboarding/application/onboarding_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OnboardingController', () {
    test('starts incomplete with empty answers when no prefs exist', () async {
      final container = await testContainer();
      addTearDown(container.dispose);

      final state = container.read(onboardingControllerProvider);
      expect(state.completed, isFalse);
      expect(state.answers, const OnboardingAnswers());
    });

    test('hydrates completion flag from SharedPreferences', () async {
      final container = await testContainer(
        prefsValues: {PrefsKeys.onboardingComplete: true},
      );
      addTearDown(container.dispose);

      expect(
        container.read(onboardingControllerProvider).completed,
        isTrue,
      );
    });

    test('hydrates answers from a persisted JSON blob', () async {
      final stored = jsonEncode(
        const OnboardingAnswers(
          name: 'Alex',
          motivations: ['Save time'],
          goal: 'starter',
        ).toJson(),
      );
      final container = await testContainer(
        prefsValues: {PrefsKeys.onboardingAnswers: stored},
      );
      addTearDown(container.dispose);

      final answers = container.read(onboardingControllerProvider).answers;
      expect(answers.name, 'Alex');
      expect(answers.motivations, ['Save time']);
      expect(answers.goal, 'starter');
    });

    test('falls back to empty answers when stored JSON is malformed', () async {
      final container = await testContainer(
        prefsValues: {PrefsKeys.onboardingAnswers: 'not-json'},
      );
      addTearDown(container.dispose);

      expect(
        container.read(onboardingControllerProvider).answers,
        const OnboardingAnswers(),
      );
    });

    test('setName persists and updates state', () async {
      final container = await testContainer();
      addTearDown(container.dispose);

      await container
          .read(onboardingControllerProvider.notifier)
          .setName('Alex');

      expect(
        container.read(onboardingControllerProvider).answers.name,
        'Alex',
      );
      final raw = container
          .read(sharedPreferencesProvider)
          .getString(PrefsKeys.onboardingAnswers);
      expect(raw, isNotNull);
      final decoded = OnboardingAnswers.fromJson(
        jsonDecode(raw!) as Map<String, dynamic>,
      );
      expect(decoded.name, 'Alex');
    });

    test('setMotivations and setGoal persist together', () async {
      final container = await testContainer();
      addTearDown(container.dispose);

      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.setMotivations(['Save time', 'Just exploring']);
      await notifier.setGoal('regular');

      final answers = container.read(onboardingControllerProvider).answers;
      expect(answers.motivations, ['Save time', 'Just exploring']);
      expect(answers.goal, 'regular');
    });

    test('complete flips the flag and writes prefs (idempotent)', () async {
      final container = await testContainer();
      addTearDown(container.dispose);

      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.complete();

      expect(
        container.read(onboardingControllerProvider).completed,
        isTrue,
      );
      expect(
        container
            .read(sharedPreferencesProvider)
            .getBool(PrefsKeys.onboardingComplete),
        isTrue,
      );

      // Second call is a no-op and doesn't throw.
      await notifier.complete();
      expect(
        container.read(onboardingControllerProvider).completed,
        isTrue,
      );
    });

    test('reset clears both keys and resets state', () async {
      final container = await testContainer(
        prefsValues: {
          PrefsKeys.onboardingComplete: true,
          PrefsKeys.onboardingAnswers: jsonEncode(
            const OnboardingAnswers(name: 'Alex').toJson(),
          ),
        },
      );
      addTearDown(container.dispose);

      await container.read(onboardingControllerProvider.notifier).reset();

      expect(
        container.read(onboardingControllerProvider),
        const OnboardingState(
          completed: false,
          answers: OnboardingAnswers(),
        ),
      );
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getBool(PrefsKeys.onboardingComplete), isNull);
      expect(prefs.getString(PrefsKeys.onboardingAnswers), isNull);
    });
  });
}
