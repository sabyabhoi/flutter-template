import 'dart:convert';

import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/storage/prefs.dart';
import 'package:app/src/features/onboarding/application/onboarding_answers.dart';
import 'package:app/src/features/onboarding/application/onboarding_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

part 'onboarding_controller.g.dart';

/// Tracks first-launch onboarding progress, persisted to
/// [SharedPreferences].
///
/// Mirrors the [`ThemeController`](../../../../core/theme/theme_controller.dart)
/// pattern: synchronous `build` reading prefs, mutators that write through
/// and update `state`. The router watches this notifier so flipping
/// [OnboardingState.completed] re-runs the redirect guard.
@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return OnboardingState(
      completed: prefs.getBool(PrefsKeys.onboardingComplete) ?? false,
      answers: _decodeAnswers(prefs.getString(PrefsKeys.onboardingAnswers)),
    );
  }

  Future<void> setName(String name) async {
    await _updateAnswers(state.answers.copyWith(name: name));
  }

  Future<void> setMotivations(List<String> motivations) async {
    await _updateAnswers(
      state.answers.copyWith(motivations: List.unmodifiable(motivations)),
    );
  }

  Future<void> setGoal(String goal) async {
    await _updateAnswers(state.answers.copyWith(goal: goal));
  }

  /// Mark onboarding as finished. Idempotent.
  Future<void> complete() async {
    if (state.completed) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(PrefsKeys.onboardingComplete, true);
    state = state.copyWith(completed: true);
  }

  /// Wipe both the completion flag and the persisted answers. Useful for
  /// dev/QA "Reset onboarding" buttons and tests.
  Future<void> reset() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(PrefsKeys.onboardingComplete);
    await prefs.remove(PrefsKeys.onboardingAnswers);
    state = const OnboardingState(
      completed: false,
      answers: OnboardingAnswers(),
    );
  }

  Future<void> _updateAnswers(OnboardingAnswers answers) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      PrefsKeys.onboardingAnswers,
      jsonEncode(answers.toJson()),
    );
    state = state.copyWith(answers: answers);
  }

  static OnboardingAnswers _decodeAnswers(String? raw) {
    if (raw == null || raw.isEmpty) return const OnboardingAnswers();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return OnboardingAnswers.fromJson(decoded);
      }
    } on FormatException catch (e, st) {
      AppLogger.instance.handle(e, st, 'Failed to decode onboarding answers');
    }
    return const OnboardingAnswers();
  }
}
