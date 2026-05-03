// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks first-launch onboarding progress, persisted to
/// [SharedPreferences].
///
/// Mirrors the [`ThemeController`](../../../../core/theme/theme_controller.dart)
/// pattern: synchronous `build` reading prefs, mutators that write through
/// and update `state`. The router watches this notifier so flipping
/// [OnboardingState.completed] re-runs the redirect guard.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Tracks first-launch onboarding progress, persisted to
/// [SharedPreferences].
///
/// Mirrors the [`ThemeController`](../../../../core/theme/theme_controller.dart)
/// pattern: synchronous `build` reading prefs, mutators that write through
/// and update `state`. The router watches this notifier so flipping
/// [OnboardingState.completed] re-runs the redirect guard.
final class OnboardingControllerProvider
    extends $NotifierProvider<OnboardingController, OnboardingState> {
  /// Tracks first-launch onboarding progress, persisted to
  /// [SharedPreferences].
  ///
  /// Mirrors the [`ThemeController`](../../../../core/theme/theme_controller.dart)
  /// pattern: synchronous `build` reading prefs, mutators that write through
  /// and update `state`. The router watches this notifier so flipping
  /// [OnboardingState.completed] re-runs the redirect guard.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingState>(value),
    );
  }
}

String _$onboardingControllerHash() =>
    r'ee492895e3eb7223bd235b88133a0df7586fb153';

/// Tracks first-launch onboarding progress, persisted to
/// [SharedPreferences].
///
/// Mirrors the [`ThemeController`](../../../../core/theme/theme_controller.dart)
/// pattern: synchronous `build` reading prefs, mutators that write through
/// and update `state`. The router watches this notifier so flipping
/// [OnboardingState.completed] re-runs the redirect guard.

abstract class _$OnboardingController extends $Notifier<OnboardingState> {
  OnboardingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingState, OnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingState, OnboardingState>,
              OnboardingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
