# Project Documentation

This directory holds a per-area audit of everything currently built in the Flutter template. It complements the top-level [`README.md`](../README.md) (which is the user-facing quickstart) by going one level deeper: actual file paths, classes, providers, and the non-obvious behavior you only see by reading the code.

If you are an AI agent or a new contributor, start with [`../agents.md`](../agents.md) and then dive into the area docs below.

## Index

| Doc | What it covers |
| --- | --- |
| [`architecture.md`](architecture.md) | Layering (`lib/main_<flavor>.dart` → `bootstrap()` → `App`), the bootstrap pipeline step-by-step, and where each piece lives. |
| [`routing-and-shell.md`](routing-and-shell.md) | `GoRouter` config, the `AppRoute` enum, the auth-aware `redirect`, the `StatefulShellRoute` with four branches, and the `FloatingNavBar` overlay. |
| [`auth.md`](auth.md) | `AuthRepository` + `SupabaseAuthRepository`, `AuthController` + `authEventsProvider`, the sign-in/up/splash screens, and the Google OAuth deep-link round-trip. |
| [`error-handling.md`](error-handling.md) | `Failure` (sealed), `Result<T>`, `ErrorMapper.guard` exception-to-failure mapping table, `ErrorHandler.install`, and the `AsyncValueX` helpers. |
| [`network.md`](network.md) | `dioProvider`, `_AuthInterceptor` (Supabase JWT bearer), `TalkerDioLogger`, optional `dio.addSentry()`, timeouts, and `ApiException`. |
| [`storage.md`](storage.md) | `SecureStorage` interface and Keychain/EncryptedSharedPreferences-backed impl, `sharedPreferencesProvider` + `PrefsKeys`, and the Drift `AppDatabase` with the `CacheEntries` sample table. |
| [`theming.md`](theming.md) | `AppTheme.light/dark`, the token layer (`AppColors` `ThemeExtension`, `AppTypography`, `AppRadii`, `AppSpacing`), the `ThemeController` (light → dark → system cycle), and how tokens are mapped onto `ColorScheme`. |
| [`env-and-flavors.md`](env-and-flavors.md) | `Flavor` enum, `AppConfig.fromEnvironment` validation, the `env/example.json` keys, Android product flavors, iOS xcconfigs, and the OAuth-redirect parity table. |
| [`observability.md`](observability.md) | `AppLogger` Talker singleton, `TalkerRiverpodObserver`, `TalkerDioLogger`, Sentry init from `bootstrap()`, the `_syncSentryUser` scope updates, and the in-app `TalkerScreen`. |
| [`testing.md`](testing.md) | `test/helpers/pump_app.dart` + `testContainer`, `FakeAuthRepository` / `FakeSecureStorage`, the existing unit + widget tests, and the integration smoke test (which is **not** wired into CI). |
| [`tooling.md`](tooling.md) | `Makefile` targets, the GitHub Actions CI flow, `analysis_options.yaml` overrides, the `build.yaml` codegen knobs, and a grouped tour of `pubspec.yaml`. |

## Conventions used in these docs

- File paths are written as repo-relative markdown links (e.g. [`lib/bootstrap.dart`](../lib/bootstrap.dart)).
- Generated files (`*.g.dart`, `*.freezed.dart`) are mentioned by their parent file but not described separately — re-run `make gen` (or `make gen-watch`) after editing the source-of-truth file.
- Where a behavior is non-obvious from the type signature alone (e.g. the `_AuthInterceptor` does not refresh tokens itself, the `AuthInitial` redirect arm is effectively dead), it is called out explicitly as a "non-obvious" note.
