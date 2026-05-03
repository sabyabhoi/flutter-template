import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_answers.freezed.dart';
part 'onboarding_answers.g.dart';

/// Quiz responses collected during the first-launch onboarding flow.
///
/// Persisted as a single JSON blob under `PrefsKeys.onboardingAnswers` so
/// we don't litter `SharedPreferences` with one key per question. The shape
/// is intentionally a generic scaffold — replace fields when product
/// decides what to actually ask.
@freezed
abstract class OnboardingAnswers with _$OnboardingAnswers {
  const factory OnboardingAnswers({
    @Default('') String name,
    @Default(<String>[]) List<String> motivations,
    @Default('') String goal,
  }) = _OnboardingAnswers;

  factory OnboardingAnswers.fromJson(Map<String, dynamic> json) =>
      _$OnboardingAnswersFromJson(json);
}
