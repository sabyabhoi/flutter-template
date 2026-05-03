import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the shared [SharedPreferences] instance.
///
/// Overridden in `bootstrap.dart` after `SharedPreferences.getInstance()`
/// resolves so that consumers can synchronously `ref.watch` it without
/// dealing with `FutureProvider`s for what is, in practice, an instant
/// in-memory store.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main / tests.',
  ),
  name: 'sharedPreferencesProvider',
);

/// Centralised list of preference keys. Keep names here to avoid typos
/// across the codebase.
abstract class PrefsKeys {
  static const themeMode = 'app.theme_mode';
  static const onboardingComplete = 'app.onboarding_complete';
  static const localeTag = 'app.locale_tag';
}
