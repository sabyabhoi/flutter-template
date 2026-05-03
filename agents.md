# Agents Guide

## What this project is

A production-ready Flutter template with batteries included:

- **State management** — Riverpod v3 (`flutter_riverpod`) with code generation (`riverpod_generator`, `riverpod_lint`).
- **Routing** — `go_router` with an auth-aware `redirect`, an `AppRoute` enum, and a `StatefulShellRoute` for tab navigation under a custom floating nav bar.
- **Models / serialization** — `freezed` sealed classes + `json_serializable`.
- **Auth** — `supabase_flutter` (email/password + Google OAuth) wrapped behind a `Result<T, Failure>` repository.
- **HTTP** — `dio` with a Supabase-bearer interceptor + Talker logger + (optional) Sentry interceptor.
- **Local data** — `drift` (SQLite) cache, `flutter_secure_storage` for tokens, `shared_preferences` for UI flags.
- **Logging / observability** — `talker_flutter` (in-app log viewer at `TalkerScreen`), `talker_riverpod_logger`, `talker_dio_logger`, `sentry_flutter` (auto-skipped when no DSN is set).
- **Error handling** — sealed `Failure` type, `ErrorMapper.guard` wrapper, global `FlutterError` / `PlatformDispatcher` / zone hooks, plus `AsyncValueX.whenWidget` for the UI.
- **Theming** — Material 3 enabled, but the palette is explicit ShadCN-style tokens (no `ColorScheme.fromSeed`); a persisted `ThemeMode`.
- **Environments** — `dev`, `staging`, `prod` flavors with Android product flavors, iOS xcconfig templates, `--dart-define-from-file` for keys.

## Where to read first

1. [`README.md`](README.md) — user-facing quickstart.
2. [`docs/README.md`](docs/README.md) — index of per-area docs.
3. The doc most relevant to your task. Quick map:
   - Adding/changing routes? → [`docs/routing-and-shell.md`](docs/routing-and-shell.md)
   - Touching auth or OAuth? → [`docs/auth.md`](docs/auth.md)
   - Need to call an API? → [`docs/network.md`](docs/network.md) and [`docs/error-handling.md`](docs/error-handling.md)
   - Storing something locally? → [`docs/storage.md`](docs/storage.md)
   - Theming / styling? → [`docs/theming.md`](docs/theming.md)
   - Env / flavor / native config? → [`docs/env-and-flavors.md`](docs/env-and-flavors.md)
   - Logging / Sentry? → [`docs/observability.md`](docs/observability.md)
   - Writing tests? → [`docs/testing.md`](docs/testing.md)
   - CI / Makefile / lint / build? → [`docs/tooling.md`](docs/tooling.md)
   - Big picture? → [`docs/architecture.md`](docs/architecture.md)

## Run / build / test cheatsheet

Everything goes through [`Makefile`](Makefile) — see [`docs/tooling.md`](docs/tooling.md) for the full list.

```sh
make bootstrap           # pub get + one-shot codegen
make gen-watch           # keep this running while iterating on @riverpod / @freezed / Drift

make format              # dart format lib test integration_test
make analyze             # flutter analyze (very_good_analysis + riverpod_lint)
make test                # flutter test
make test-coverage       # writes coverage/lcov.info

make run-dev             # flutter run --flavor dev with env/dev.json
make build-apk-prod      # release APK for prod
```

Per-flavor commands assume `env/<flavor>.json` exists. Copy from `env/example.json` for the first run — see [`docs/env-and-flavors.md`](docs/env-and-flavors.md).

## Conventions you must follow

### Errors stay inside the data layer

Repositories wrap every SDK call in [`ErrorMapper.guard`](lib/src/core/error/error_mapper.dart) and return `Result<T, Failure>`. Controllers and UI **never** see raw `AuthException` / `PostgrestException` / `DioException` / `SocketException` / `TimeoutException`. The full mapping table lives in [`docs/error-handling.md`](docs/error-handling.md).

### State via Riverpod codegen

Use `@riverpod` (functional) and `@Riverpod(keepAlive: true) class XController extends _$XController` (notifier) — never hand-write a `Notifier` subclass. Watch the controller from the UI with `ConsumerWidget` / `ConsumerStatefulWidget` and render via `AsyncValueX.whenWidget`. Surface mutation errors with `AsyncValueListenerX.showSnackBarOnError(context)` inside `ref.listen`.

### Sealed unions via Freezed

Use `@freezed sealed class X with _$X` for sum types ([`AuthState`](lib/src/features/auth/application/auth_state.dart), [`Failure`](lib/src/core/error/failure.dart)). Pattern match with Dart 3 `switch` expressions, not `.when` callbacks.

### JSON via json_serializable

DTOs use snake_case field names by default — see [`build.yaml`](build.yaml). `explicit_to_json: true` so nested models serialize correctly. `include_if_null: false` strips nulls.

### Re-run codegen after annotation / schema changes

After editing any `@riverpod`, `@freezed`, `@JsonSerializable`, or Drift table source — and **always** when you create a new `*.g.dart` / `*.freezed.dart` source — run:

```sh
make gen
# or, while iterating:
make gen-watch
```

If something looks stale, `make gen-clean` does a wipe + rebuild.

### Lint exemptions are intentional

[`analysis_options.yaml`](analysis_options.yaml) disables a few `very_good_analysis` rules (`public_member_api_docs`, `lines_longer_than_80_chars`, `avoid_classes_with_only_static_members`, `one_member_abstracts`, `sort_pub_dependencies`). Match the existing style; don't fight the lints (and don't re-enable them in passing).

### File / folder layout

Per-feature: `lib/src/features/<name>/{data,application,presentation}/`. Cross-cutting: `lib/src/core/{env,logging,error,network,storage,theme,providers}/`. App shell + router: `lib/src/app/`. See [`docs/architecture.md`](docs/architecture.md).

### Token / spacing values

Read colors via the `AppColors` `ThemeExtension` (`context.appColors.<token>`) or the M3 `ColorScheme` (`Theme.of(context).colorScheme.<role>`). Use [`AppRadii`](lib/src/core/theme/tokens/app_radii.dart) and [`AppSpacing`](lib/src/core/theme/tokens/app_spacing.dart) instead of raw doubles. Never inline `Color(0xFF…)` outside the token files. See [`docs/theming.md`](docs/theming.md).

## Adding a new feature

1. **`lib/src/features/<name>/data/<name>_repository.dart`** — wrap any SDK calls in `ErrorMapper.guard`, return `Result<T, Failure>`. If you depend on `AppConfig`, declare a `@Riverpod(keepAlive: true)` provider that watches `appConfigProvider`.
2. **`lib/src/features/<name>/application/<name>_controller.dart`** — `@riverpod class XController extends _$XController { Future<XState> build() async { ... } ... }`. `ref.listen` on streams; explicit mutations set `state` to `AsyncLoading` / `AsyncData` / `AsyncError`.
3. **`lib/src/features/<name>/presentation/<name>_screen.dart`** — `ConsumerWidget` (or `ConsumerStatefulWidget`) watching the controller. Render via `AsyncValueX.whenWidget`. Use `ref.listen(controllerProvider, (_, n) => n.showSnackBarOnError(context))` for mutation errors.
4. **Wire a route.** Add an `AppRoute` enum value in [`lib/src/app/router/routes.dart`](lib/src/app/router/routes.dart), then a `GoRoute` in [`lib/src/app/router/app_router.dart`](lib/src/app/router/app_router.dart). Decide whether it lives at the top level or under one of the four shell branches.
5. **Add tests.** `test/features/<name>/` using the helpers in [`test/helpers/`](test/helpers/). Build a `FakeXRepository` if needed; override the provider via `pumpApp(... authRepository: fake)` or `testContainer(overrides: [...])`. See [`docs/testing.md`](docs/testing.md).
6. **Re-run codegen** (`make gen`).

## Pitfalls / things that bite

- **Don't run `lib/main.dart` directly** — it throws `UnsupportedError`. Always pair `--flavor`, `-t lib/main_<flavor>.dart`, and `--dart-define-from-file=env/<flavor>.json`. Or just `make run-<flavor>`.
- **OAuth redirect URL** must match in **four** places: [`env/<flavor>.json`](env/example.json), [`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) intent-filter, [`Info.plist`](ios/Runner/Info.plist) `CFBundleURLTypes`, and the Supabase dashboard allow-list. Parity table in [`docs/env-and-flavors.md`](docs/env-and-flavors.md).
- **`_AuthInterceptor` does not refresh tokens itself** — it snapshots `Supabase.instance.client.auth.currentSession?.accessToken` per request. Refresh is handled inside `supabase_flutter`. If you add non-Supabase auth, write your own refresh.
- **Bump `AppDatabase.schemaVersion`** when changing Drift tables and add a `migrationStrategy`. Schema version is currently `1`.
- **`SharedPreferences.setMockInitialValues` order matters** — call it before `SharedPreferences.getInstance()`. The test helpers do this for you.
- **`integration_test/app_smoke_test.dart` is not run in CI.** `make test` and CI both only run `test/`. Add an explicit `flutter test integration_test/...` step if you need it on PRs.
- **Don't call `String.fromEnvironment` outside [`AppConfig.fromEnvironment`](lib/src/core/env/app_config.dart).** That's the single point where env values are read and validated.
- **Don't instantiate `Talker()` ad hoc.** Always use `AppLogger.instance` so all logs land in the same in-app viewer.

## Per-area deep dives

| Topic | Doc |
| --- | --- |
| Layering + bootstrap pipeline | [`docs/architecture.md`](docs/architecture.md) |
| GoRouter, redirects, shell | [`docs/routing-and-shell.md`](docs/routing-and-shell.md) |
| Auth feature end-to-end | [`docs/auth.md`](docs/auth.md) |
| Failures, Result, error mapper | [`docs/error-handling.md`](docs/error-handling.md) |
| Dio + interceptors | [`docs/network.md`](docs/network.md) |
| SecureStorage, prefs, Drift | [`docs/storage.md`](docs/storage.md) |
| Theme + tokens + controller | [`docs/theming.md`](docs/theming.md) |
| Flavors + env + native config | [`docs/env-and-flavors.md`](docs/env-and-flavors.md) |
| Talker + Sentry | [`docs/observability.md`](docs/observability.md) |
| Test helpers + fakes + suite | [`docs/testing.md`](docs/testing.md) |
| Make + CI + lint + build | [`docs/tooling.md`](docs/tooling.md) |
