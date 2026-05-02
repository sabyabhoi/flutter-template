// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User-selected app-wide [ThemeMode], persisted to [SharedPreferences].
///
/// Reads/writes go through [PrefsKeys.themeMode]. Default is
/// [ThemeMode.system].

@ProviderFor(ThemeController)
final themeControllerProvider = ThemeControllerProvider._();

/// User-selected app-wide [ThemeMode], persisted to [SharedPreferences].
///
/// Reads/writes go through [PrefsKeys.themeMode]. Default is
/// [ThemeMode.system].
final class ThemeControllerProvider
    extends $NotifierProvider<ThemeController, ThemeMode> {
  /// User-selected app-wide [ThemeMode], persisted to [SharedPreferences].
  ///
  /// Reads/writes go through [PrefsKeys.themeMode]. Default is
  /// [ThemeMode.system].
  ThemeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeControllerHash();

  @$internal
  @override
  ThemeController create() => ThemeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeControllerHash() => r'7ffb2300e8603b06c5d697113c11a6dc622bec86';

/// User-selected app-wide [ThemeMode], persisted to [SharedPreferences].
///
/// Reads/writes go through [PrefsKeys.themeMode]. Default is
/// [ThemeMode.system].

abstract class _$ThemeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
