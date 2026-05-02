import 'package:app/src/core/env/flavor.dart';
import 'package:meta/meta.dart';

/// Strongly-typed, build-time application configuration.
///
/// Values are read from `--dart-define` / `--dart-define-from-file` at
/// compile time via [String.fromEnvironment]. Use [AppConfig.fromEnvironment]
/// from `bootstrap.dart`; never call [String.fromEnvironment] elsewhere.
@immutable
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    required this.apiBaseUrl,
    required this.oauthRedirectUrl,
  });

  /// Build [AppConfig] from compile-time environment values.
  ///
  /// [flavor] is passed in (rather than read from the env) because the
  /// per-flavor entrypoint already knows which flavor it is — this lets us
  /// reject mismatches between the entrypoint and the loaded env file.
  factory AppConfig.fromEnvironment(Flavor flavor) {
    const envFlavor = String.fromEnvironment('FLAVOR');
    if (envFlavor.isNotEmpty && Flavor.fromName(envFlavor) != flavor) {
      throw StateError(
        'Flavor mismatch: entrypoint expected ${flavor.name} but env '
        'file declared $envFlavor. Did you forget '
        '--dart-define-from-file=env/${flavor.name}.json?',
      );
    }

    const appName = String.fromEnvironment('APP_NAME', defaultValue: 'App');
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    // Default matches the deep-link scheme/host registered in
    // android/app/src/main/AndroidManifest.xml and ios/Runner/Info.plist.
    // Override per-flavor in env/<flavor>.json if you change either.
    const oauthRedirectUrl = String.fromEnvironment(
      'OAUTH_REDIRECT_URL',
      defaultValue: 'com.example.app.auth://login-callback',
    );

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set in '
        'env/${flavor.name}.json (passed via --dart-define-from-file).',
      );
    }

    return AppConfig(
      flavor: flavor,
      appName: appName,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      sentryDsn: sentryDsn,
      apiBaseUrl: apiBaseUrl,
      oauthRedirectUrl: oauthRedirectUrl,
    );
  }

  final Flavor flavor;
  final String appName;
  final String supabaseUrl;
  final String supabaseAnonKey;

  /// May be empty in dev — Sentry init is skipped when blank.
  final String sentryDsn;
  final String apiBaseUrl;

  /// Deep link Supabase redirects back to after an OAuth provider flow
  /// completes. Must match a redirect URL allow-listed in the Supabase
  /// dashboard *and* the platform deep-link config (Android intent-filter
  /// + iOS `CFBundleURLTypes`).
  final String oauthRedirectUrl;

  bool get sentryEnabled => sentryDsn.isNotEmpty;
}
