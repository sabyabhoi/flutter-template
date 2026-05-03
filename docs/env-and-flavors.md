# Environments and Flavors

The template ships three flavors — `dev`, `staging`, `prod` — wired through Flutter entrypoints, env files passed via `--dart-define-from-file`, and matching Android product flavors / iOS xcconfig files. The `Flavor` enum is the single source of truth on the Dart side; `AppConfig.fromEnvironment` validates the env file matches the entrypoint at compile time.

## Files

| File | Description |
| --- | --- |
| [`lib/src/core/env/flavor.dart`](../lib/src/core/env/flavor.dart) | `Flavor` enum (`dev`, `staging`, `prod`) + `isDev/isStaging/isProd` + case-insensitive `fromName`. |
| [`lib/src/core/env/app_config.dart`](../lib/src/core/env/app_config.dart) | Immutable `AppConfig` + `fromEnvironment(Flavor)` factory with mismatch and required-key validation. |
| [`lib/src/core/providers/app_config_provider.dart`](../lib/src/core/providers/app_config_provider.dart) | `Provider<AppConfig>` that throws unless overridden in `bootstrap()` / tests. |
| [`env/example.json`](../env/example.json) | Template env file. Keys committed; copy to `env/<flavor>.json` and fill in real values. |
| [`Makefile`](../Makefile) | `run-*` / `build-apk-*` / `build-ios-*` wrap the `--flavor` + `-t lib/main_<flavor>.dart` + `--dart-define-from-file=env/<flavor>.json` triple. |
| [`android/app/build.gradle.kts`](../android/app/build.gradle.kts) | Defines the `env` flavor dimension and the three product flavors. |
| [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml) | OAuth deep-link `intent-filter`. |
| [`ios/Flutter/Dev.xcconfig`](../ios/Flutter/Dev.xcconfig), [`Staging.xcconfig`](../ios/Flutter/Staging.xcconfig), [`Prod.xcconfig`](../ios/Flutter/Prod.xcconfig) | Per-flavor `PRODUCT_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME`, `ASSET_PREFIX`. |
| [`ios/Runner/Info.plist`](../ios/Runner/Info.plist) | `CFBundleURLTypes` (OAuth deep link), `CFBundleDisplayName = $(APP_DISPLAY_NAME)`. |

## `Flavor`

[`Flavor`](../lib/src/core/env/flavor.dart):

```dart
enum Flavor { dev, staging, prod }
```

Helpers:

- `bool get isDev / isStaging / isProd`
- `static Flavor fromName(String value)` — case-insensitive parse with aliases:
  - `dev` / `development`
  - `staging` / `stage`
  - `prod` / `production`
  - Anything else → `ArgumentError.value(...)` so misconfigured envs fail fast at boot.

Each enum value maps 1:1 with:

- A Flutter entrypoint (`lib/main_<flavor>.dart`).
- A Dart-define env file (`env/<flavor>.json`).
- An Android product flavor (`dev` / `staging` / `prod` under the `env` dimension).
- An iOS xcconfig (`ios/Flutter/<Flavor>.xcconfig`) and the matching Xcode scheme/configuration set you wire up by hand.

## `AppConfig`

[`AppConfig`](../lib/src/core/env/app_config.dart) is the typed, immutable view of `--dart-define-from-file` values. The factory `AppConfig.fromEnvironment(Flavor flavor)` is the **only** caller of `String.fromEnvironment` in the codebase — every other layer reads `AppConfig` from `appConfigProvider`.

### Fields

| Field | Source | Default |
| --- | --- | --- |
| `flavor` | Passed in by the entrypoint. | — |
| `appName` | `String.fromEnvironment('APP_NAME')` | `'App'` |
| `supabaseUrl` | `String.fromEnvironment('SUPABASE_URL')` | (none — required) |
| `supabaseAnonKey` | `String.fromEnvironment('SUPABASE_ANON_KEY')` | (none — required) |
| `sentryDsn` | `String.fromEnvironment('SENTRY_DSN')` | `''` (Sentry skipped when blank) |
| `apiBaseUrl` | `String.fromEnvironment('API_BASE_URL')` | (none) |
| `oauthRedirectUrl` | `String.fromEnvironment('OAUTH_REDIRECT_URL')` | `'com.example.app.auth://login-callback'` |

### Validation

Two fail-fast checks happen inside `fromEnvironment`:

1. **Flavor mismatch.** If `FLAVOR` in the env file is non-empty and parses to a different `Flavor` than the entrypoint passed in, throws `StateError`:
   > `Flavor mismatch: entrypoint expected <flavor> but env file declared <envFlavor>. Did you forget --dart-define-from-file=env/<flavor>.json?`
2. **Required Supabase keys.** If either `SUPABASE_URL` or `SUPABASE_ANON_KEY` is empty, throws `StateError` instructing you to populate `env/<flavor>.json`.

`bool get sentryEnabled => sentryDsn.isNotEmpty;` is read by [`bootstrap()`](../lib/bootstrap.dart) (Sentry init) and [`dioProvider`](../lib/src/core/network/dio_client.dart) (`dio.addSentry()`).

## `env/example.json`

The committed template, duplicated to `env/dev.json` / `env/staging.json` / `env/prod.json` (which are git-ignored).

```json
{
  "FLAVOR": "dev",
  "APP_NAME": "App (Dev)",
  "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "your-public-anon-key",
  "SENTRY_DSN": "",
  "API_BASE_URL": "https://api.dev.example.com",
  "OAUTH_REDIRECT_URL": "com.example.app.auth://login-callback"
}
```

| Key | What it controls |
| --- | --- |
| `FLAVOR` | Cross-checked against the entrypoint flavor inside `AppConfig.fromEnvironment` (parsed via `Flavor.fromName`). |
| `APP_NAME` | Used as `MaterialApp.title` and as Sentry `release`. Should match the platform display name (Android `app_name` resValue, iOS `APP_DISPLAY_NAME`). |
| `SUPABASE_URL` | Required. Used by `Supabase.initialize` and the auth repository. |
| `SUPABASE_ANON_KEY` | Required. Public anon key; safe to ship in client builds. |
| `SENTRY_DSN` | Optional. Empty disables Sentry across the app (`bootstrap`, Dio, `ErrorHandler`). |
| `API_BASE_URL` | Used as `BaseOptions.baseUrl` on the Dio client. |
| `OAUTH_REDIRECT_URL` | Deep link Supabase redirects back to after Google OAuth. **Must** match the Android intent-filter, the iOS `CFBundleURLSchemes`, and the Supabase dashboard allow-list. |

## `Makefile` targets

[`Makefile`](../Makefile) wraps the `--flavor` + `-t` + `--dart-define-from-file` trio so you don't have to type it. See [`tooling.md`](tooling.md) for the full target list. Run/build commands assume `env/<flavor>.json` exists — copy from `env/example.json` for the first run.

## Native flavor wiring

### Android

[`android/app/build.gradle.kts`](../android/app/build.gradle.kts) defines the `env` flavor dimension and three product flavors. Java/Kotlin target is 17.

| Flavor | `applicationId` | `versionNameSuffix` | `app_name` resource |
| --- | --- | --- | --- |
| `dev` | `com.example.app.dev` | `-dev` | `App (Dev)` |
| `staging` | `com.example.app.staging` | `-staging` | `App (Staging)` |
| `prod` | `com.example.app` | (none) | `App` |

The `release` build type is wired to **the debug signing config with a TODO** so `flutter run --release` works locally — replace this before shipping.

[`AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml) registers a single `MainActivity` (`singleTop`, `exported=true`) with a `MAIN`/`LAUNCHER` intent-filter and an OAuth deep-link `intent-filter` with `autoVerify=false` (custom-scheme, not App Links):

```xml
<data android:scheme="com.example.app.auth" android:host="login-callback"/>
```

### iOS

Per-flavor xcconfigs live under [`ios/Flutter/`](../ios/Flutter/). Each `#include "Generated.xcconfig"` and sets:

| Flavor | `PRODUCT_BUNDLE_IDENTIFIER` | `APP_DISPLAY_NAME` | `ASSET_PREFIX` |
| --- | --- | --- | --- |
| Dev | `com.example.app.dev` | `App (Dev)` | `AppIcon-Dev` |
| Staging | `com.example.app.staging` | `App (Staging)` | `AppIcon-Staging` |
| Prod | `com.example.app` | `App` | `AppIcon` |

[`ios/Runner/Info.plist`](../ios/Runner/Info.plist) reads these via Xcode variable substitution (`$(APP_DISPLAY_NAME)`, `$(PRODUCT_BUNDLE_IDENTIFIER)`) and registers the OAuth deep link in `CFBundleURLTypes`:

```xml
<key>CFBundleURLName</key>
<string>com.example.app.auth</string>
<key>CFBundleURLSchemes</key>
<array>
  <string>com.example.app.auth</string>
</array>
```

iOS scheme/configuration generation cannot be done safely from the CLI, so the template ships the xcconfig **templates** and you do the one-time Xcode wiring yourself (see the README's "iOS flavors" section).

## OAuth-redirect parity table

For Google OAuth (and any other provider that goes through Supabase deep-link callbacks) to work, **all four of these must agree on the same URL**:

| Where | What | Default value |
| --- | --- | --- |
| [`env/<flavor>.json`](../env/example.json) → `OAUTH_REDIRECT_URL` | Read into `AppConfig.oauthRedirectUrl`, passed as `redirectTo:` to `signInWithOAuth`. | `com.example.app.auth://login-callback` |
| [`AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml) | `<intent-filter>` `<data android:scheme="…" android:host="…"/>` | `com.example.app.auth` / `login-callback` |
| [`ios/Runner/Info.plist`](../ios/Runner/Info.plist) | `CFBundleURLTypes` → `CFBundleURLSchemes` | `com.example.app.auth` |
| Supabase dashboard | Authentication → URL Configuration → Redirect URLs | `com.example.app.auth://login-callback` |

If you change the bundle ID or scheme:

1. Update the scheme/host in `AndroidManifest.xml`.
2. Update `CFBundleURLSchemes` (and `CFBundleURLName`) in `Info.plist`.
3. Update `OAUTH_REDIRECT_URL` in every `env/<flavor>.json`.
4. Add the new URL to your Supabase project's redirect allow-list.

## CI compile hack

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs `cp env/example.json env/dev.json` before `flutter test`. CI doesn't have real Supabase credentials, but unit/widget tests **override `appConfigProvider`** with `testConfig` (see [`testing.md`](testing.md)) — the placeholder env file just keeps the `--dart-define-from-file` machinery happy at compile time.

## See also

- [`architecture.md`](architecture.md) — where `AppConfig.fromEnvironment` is called inside `bootstrap()`.
- [`auth.md`](auth.md) — how `oauthRedirectUrl` flows into the Google sign-in flow.
- [`network.md`](network.md) — `apiBaseUrl` is used as the Dio `BaseOptions.baseUrl`.
- [`observability.md`](observability.md) — `sentryEnabled` gates Sentry init in `bootstrap` and `dio.addSentry()`.
