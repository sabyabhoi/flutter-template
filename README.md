# Flutter Template

A production-ready Flutter starter with batteries included:

- **State management** — `flutter_riverpod` v3 + code generation (`riverpod_generator`, `riverpod_lint`).
- **Routing** — `go_router` with typed route names and auth-aware redirects.
- **Models / serialization** — `freezed` sealed classes + `json_serializable`.
- **Auth** — `supabase_flutter` (email/password + OAuth-ready), wrapped behind a `Result<T, Failure>` repository so the rest of the app stays SDK-agnostic.
- **HTTP** — `dio` with a shared Talker logger interceptor and a Supabase-aware auth interceptor.
- **Local data** — `drift` (SQLite) for relational cache, `flutter_secure_storage` for tokens, `shared_preferences` for UI flags.
- **Logging & observability** — `talker_flutter` (in-app log viewer), `talker_riverpod_logger`, `talker_dio_logger`, and `sentry_flutter` (auto-skipped when no DSN is set).
- **Error handling** — sealed `Failure` type, `ErrorMapper.guard` translating SDK exceptions, global `FlutterError.onError` + `PlatformDispatcher.onError` hooks, plus an `AsyncValueX.whenWidget` extension for the UI.
- **Theming** — Material 3 with a seeded colour scheme and a persisted `ThemeMode` controller.
- **Environments** — three flavors (`dev`, `staging`, `prod`) with native Android product flavors, iOS xcconfig templates, and `--dart-define-from-file` for keys/secrets.
- **Tests** — unit tests (auth controller, theme controller, error mapper), a widget test for sign-in, and an integration smoke test, all running against fakes via Riverpod overrides.
- **Tooling** — `Makefile`, GitHub Actions CI (`format` + `analyze` + `test --coverage`), `very_good_analysis` lints, `riverpod_lint` (auto-enabled via the new analysis-server-plugin API — no `custom_lint` needed).

## Quick start

```sh
# 1. Install deps + run codegen.
make bootstrap

# 2. Copy the env template and fill in your Supabase keys.
cp env/example.json env/dev.json     # then edit env/dev.json
cp env/example.json env/staging.json # ditto
cp env/example.json env/prod.json    # ditto

# 3. Run the dev flavor.
make run-dev
```

> `env/dev.json`, `env/staging.json`, `env/prod.json` are git-ignored — only `env/example.json` is committed.

## Common commands

| Command                 | What it does                                                |
| ----------------------- | ----------------------------------------------------------- |
| `make bootstrap`        | `pub get` + one-shot codegen.                               |
| `make gen` / `gen-watch`| Run `build_runner` once / in watch mode.                    |
| `make format`           | `dart format` lib/test/integration_test.                    |
| `make analyze`          | `flutter analyze` (very_good_analysis + riverpod_lint).     |
| `make test`             | Unit + widget tests.                                        |
| `make test-coverage`    | Same with `--coverage` (writes `coverage/lcov.info`).       |
| `make run-dev`          | `flutter run` for the dev flavor with the matching env.     |
| `make run-staging`      | Same for staging.                                           |
| `make run-prod`         | Same for prod.                                              |
| `make build-apk-<env>`  | Build an APK (debug for `dev`, release for `staging`/`prod`).|
| `make build-ios-<env>`  | Build an iOS app — see "iOS flavors" below for one-time setup. |

## Architecture

```
lib/
  main_dev.dart / main_staging.dart / main_prod.dart   # entrypoints
  bootstrap.dart                                       # shared init
  src/
    app/                  # router + MaterialApp.router
    core/
      env/                # Flavor + AppConfig (typed dart-define)
      logging/            # Talker singleton
      error/              # Failure, Result, ErrorMapper, ErrorHandler
      network/            # Dio with Talker + Sentry interceptors
      storage/            # SecureStorage, SharedPreferences, Drift DB
      theme/              # Material 3 + persisted ThemeMode
      providers/          # Cross-feature Riverpod handles
    features/
      auth/{data, application, presentation}
      home/presentation
      settings/presentation
test/
  helpers/                # pump_app, fakes (FakeAuthRepository, ...)
  core/...                # unit tests
  features/auth/...       # controller + screen tests
integration_test/         # boot smoke test
env/                      # *.json env files (gitignored except example)
```

### Bootstrap pipeline

```
main_<flavor>.dart  ─►  bootstrap(Flavor)
                          │
                          ├─ AppConfig.fromEnvironment(flavor)   # fail-fast on bad env
                          ├─ AppLogger.init(flavor)              # Talker singleton
                          ├─ SharedPreferences.getInstance()
                          ├─ Supabase.initialize(...)
                          ├─ ErrorHandler.install(config)        # FlutterError + PlatformDispatcher
                          └─ SentryFlutter.init(...) → runApp(ProviderScope(App()))
```

### Auth + routing redirect

`authControllerProvider` is the single source of truth. `go_router.refreshListenable` is wired to it, so any sign-in / sign-out triggers `redirect`:

- Loading → splash.
- Authenticated → away from `/sign-in` & `/sign-up`, land on `/home`.
- Unauthenticated → `/sign-in`.

`AuthRepository` returns `Result<T, Failure>` — controllers/UI never see raw `AuthException`/`PostgrestException`/`DioException`.

### Google OAuth

Both auth screens ship a "Continue with Google" button that calls `AuthController.signInWithGoogle()` → `AuthRepository.signInWithGoogle()` → `supabase.auth.signInWithOAuth(OAuthProvider.google)`. The flow is:

1. The native browser opens the Supabase-hosted Google consent page.
2. After consent, Supabase redirects to `OAUTH_REDIRECT_URL` (a custom-scheme deep link).
3. The OS reopens the app via the registered intent-filter / `CFBundleURLScheme`, and `supabase_flutter`'s built-in deep-link listener exchanges the code for a session.
4. `authEventsProvider` emits `signedIn`, `AuthController` flips to `Authenticated`, and the router redirects to `/home`.

Three things must agree on the same URL:

| Where                                                  | What                                                       |
| ------------------------------------------------------ | ---------------------------------------------------------- |
| `env/<flavor>.json` → `OAUTH_REDIRECT_URL`             | `com.example.app.auth://login-callback` (template default) |
| `android/app/src/main/AndroidManifest.xml`             | `<data android:scheme=… android:host=…/>` intent-filter    |
| `ios/Runner/Info.plist` → `CFBundleURLTypes`           | `CFBundleURLSchemes` array                                 |
| Supabase dashboard → Authentication → URL Configuration | Add the same URL to the redirect allow-list                |

To use a different scheme (recommended once you change the bundle ID):

1. Update the scheme/host in `AndroidManifest.xml`.
2. Update `CFBundleURLSchemes` (and `CFBundleURLName`) in `Info.plist`.
3. Update `OAUTH_REDIRECT_URL` in every `env/<flavor>.json`.
4. Add the new URL to your Supabase project's allow-listed redirect URLs.
5. Enable the Google provider under Authentication → Providers and paste your Google Cloud OAuth client ID/secret.

The repository is SDK-agnostic — swapping in `google_sign_in` + `signInWithIdToken` later is a one-method change in `SupabaseAuthRepository`.

## Environments & flavors

The template ships three flavors. Each one is identified by:

1. A Flutter entrypoint: `lib/main_<flavor>.dart`.
2. An env file: `env/<flavor>.json` — passed via `--dart-define-from-file`.
3. A native build flavor — Android product flavor and (after the manual Xcode wiring below) an iOS scheme.

Run/build commands:

```sh
flutter run --flavor dev      -t lib/main_dev.dart      --dart-define-from-file=env/dev.json
flutter run --flavor staging  -t lib/main_staging.dart  --dart-define-from-file=env/staging.json
flutter run --flavor prod     -t lib/main_prod.dart     --dart-define-from-file=env/prod.json
```

The `Makefile` wraps these as `make run-dev` / `run-staging` / `run-prod`.

### Android flavors

Already wired in `android/app/build.gradle.kts`:

| Flavor   | applicationId            | App label    |
| -------- | ------------------------ | ------------ |
| dev      | `com.example.app.dev`    | App (Dev)    |
| staging  | `com.example.app.staging`| App (Staging)|
| prod     | `com.example.app`        | App          |

Update `applicationId`, `namespace`, and the launcher icons (`android/app/src/main/res/mipmap-*/ic_launcher.png`) to suit your product. Per-flavor icons can be added under e.g. `android/app/src/dev/res/mipmap-*/`.

### iOS flavors

iOS scheme/configuration generation cannot be done safely from the CLI, so the template ships the xcconfig **templates** and you do the one-time Xcode wiring yourself.

Per-flavor xcconfigs live in `ios/Flutter/`:

- `Dev.xcconfig`     — `com.example.app.dev`
- `Staging.xcconfig` — `com.example.app.staging`
- `Prod.xcconfig`    — `com.example.app`

`ios/Runner/Info.plist` already reads `$(APP_DISPLAY_NAME)` for `CFBundleDisplayName`. The default `Debug.xcconfig` and `Release.xcconfig` include `Dev.xcconfig` and `Prod.xcconfig` respectively, so a vanilla `flutter run` / `flutter build ios --release` works out of the box with sensible defaults.

For a full multi-flavor setup:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **Project → Info → Configurations**: duplicate Debug/Release/Profile six times (`Debug-Dev`, `Release-Dev`, `Profile-Dev`, `Debug-Staging`, …) and point each one's xcconfig at the matching `Flutter/<Flavor>.xcconfig`.
3. **Product → Scheme → Manage Schemes**: create `Dev`, `Staging`, `Prod` schemes pointing at the matching configurations.
4. (Optional) Add per-flavor app icons by creating `AppIcon-Dev`/`AppIcon-Staging` asset catalogs and pointing each xcconfig's `ASSET_PREFIX` to them.

## Adding a new feature

1. `lib/src/features/<name>/data/<name>_repository.dart` — wraps any SDK calls in `ErrorMapper.guard`, returns `Result<T, Failure>`.
2. `lib/src/features/<name>/application/<name>_controller.dart` — `@riverpod class XController extends _$XController { Future<XState> build() async { ... } ... }`.
3. `lib/src/features/<name>/presentation/<name>_screen.dart` — `ConsumerWidget` watching the controller, using `AsyncValueX.whenWidget` for loading/error/data UI.
4. Wire a route in `lib/src/app/router/{routes,app_router}.dart`.
5. Add tests in `test/features/<name>/` using the helpers in `test/helpers/`.

After any annotation/Drift change, re-run `make gen` (or keep `make gen-watch` running).

## Out of scope (for the template)

The following are common but opinionated additions left out so the template stays slim — wire them in as your product needs them:

- Push notifications (`firebase_messaging` / `flutter_local_notifications`).
- Deep / universal links beyond the basic `go_router` setup.
- Localization beyond the `flutter_localizations` baseline.
- Analytics SDK (Firebase Analytics, PostHog, Mixpanel, …).
- CI signing for release builds (`fastlane` or `flutter build` with proper keystores).
- Per-flavor app icons / splash screens (`flutter_launcher_icons`, `flutter_native_splash`).
- In-app purchases.
