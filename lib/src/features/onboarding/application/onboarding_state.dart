import 'package:app/src/features/onboarding/application/onboarding_answers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// Snapshot of the user's onboarding progress.
///
/// [completed] flips to true the first time the user reaches the final
/// (sign-in) page; the router uses it to decide whether to gate
/// unauthenticated users on `/onboarding`.
@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    required bool completed,
    required OnboardingAnswers answers,
  }) = _OnboardingState;
}
