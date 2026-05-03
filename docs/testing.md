# Testing

The template ships with a small but representative test suite: a unit test for `ErrorMapper`, a unit + behavior test for `ThemeController`, controller tests for `AuthController` (including the Google OAuth deep-link round-trip), a widget test for `SignInScreen`, and an integration smoke test that boots the real `App` widget tree against fakes. All tests use Riverpod overrides instead of mocks for SDK dependencies.

## Files

| File | Description |
| --- | --- |
| [`test/helpers/pump_app.dart`](../test/helpers/pump_app.dart) | `testConfig`, `testContainer`, `pumpApp`, `defaultFakes`. The shared scaffolding for every test. |
| [`test/helpers/fakes.dart`](../test/helpers/fakes.dart) | `FakeAuthRepository`, `FakeSecureStorage`, `fakeAuthFailure(...)`. |
| [`test/core/error/error_mapper_test.dart`](../test/core/error/error_mapper_test.dart) | Unit tests for the `ErrorMapper.guard` mapping table. |
| [`test/core/theme/theme_controller_test.dart`](../test/core/theme/theme_controller_test.dart) | Unit tests for default, hydration, persistence, and `toggle` cycle. |
| [`test/features/auth/auth_controller_test.dart`](../test/features/auth/auth_controller_test.dart) | `AuthController` lifecycle, sign-in success/failure, sign-out, Google OAuth deep-link simulation. |
| [`test/features/auth/sign_in_screen_test.dart`](../test/features/auth/sign_in_screen_test.dart) | Widget test using fake auth, key-based finders, validation copy, submission. |
| [`integration_test/app_smoke_test.dart`](../integration_test/app_smoke_test.dart) | Integration smoke: real `App` widget + `FakeAuthRepository` → asserts splash → sign-in transition. |

## Test scaffolding (`pump_app.dart`)

### `testConfig`

A precomputed `AppConfig` with placeholder Supabase keys, Sentry disabled, and `Flavor.dev`. Used as the default override for `appConfigProvider` in every test.

### `testContainer({overrides, authRepository?, secureStorage?, prefsValues?})`

Builds a `ProviderContainer` with sensible defaults:

1. `AppLogger.init(Flavor.dev)` — Talker is required by error code paths; init is idempotent across tests.
2. `SharedPreferences.setMockInitialValues(prefsValues ?? {})` and grab the resulting prefs instance.
3. Default overrides:
   - `appConfigProvider.overrideWithValue(testConfig)`
   - `sharedPreferencesProvider.overrideWithValue(prefs)`
   - `secureStorageProvider.overrideWithValue(secureStorage)` if provided
   - `authRepositoryProvider.overrideWithValue(authRepository)` if provided
   - `...overrides` (caller's additional overrides last so they win)

Pure-Dart tests use `testContainer` directly, then `addTearDown(container.dispose)`.

### `pumpApp(tester, child, {overrides, authRepository?, secureStorage?, prefsValues?})`

Builds `testContainer(...)`, registers `addTearDown(container.dispose)`, and pumps:

```dart
UncontrolledProviderScope(
  container: container,
  child: MaterialApp(home: child),
)
```

Returns the container so the test can `container.read(...)` if needed.

> **Non-obvious:** `UncontrolledProviderScope` does **not** dispose its container when removed from the tree — that's why the helper explicitly calls `addTearDown(container.dispose)`. Without that you'd leak providers between tests.

### `defaultFakes()`

Convenience returning `({FakeAuthRepository auth, FakeSecureStorage storage})` for tests that don't care about specific scenarios beyond "user is unauthenticated".

## Fakes (`fakes.dart`)

### `FakeAuthRepository`

Implements `AuthRepository` entirely in-memory. Highlights:

- **Broadcast auth stream.** `onAuthStateChange` is a `StreamController<sb.AuthState>.broadcast()`.
- **`emit(user, {event})`** — push a synthetic Supabase auth event; mutates `currentUser` to match. Builds a `sb.Session(accessToken: 'fake-token', tokenType: 'bearer', user: user)` so listeners see realistic shape. Used by tests to simulate the post-deep-link Google OAuth callback.
- **Scripted next results** — `nextSignInResult`, `nextSignUpResult`, `nextSignOutResult`, `nextGoogleResult`. If set, the next call consumes it (single-shot); otherwise the fake performs the default behavior (e.g. mint a fake user with the supplied email).
- **`googleSignInCount`** — counter, useful for asserting the OAuth flow was launched without spinning up a real browser.
- **`signOut`** by default `emit(null, event: signedOut)` and returns `Ok(null)`.
- **`sendPasswordReset`** always returns `Ok(null)`.

`fakeAuthFailure(message)` is a one-liner for `Failure.auth(message: message)` to use as `Result.err(...)`.

### `FakeSecureStorage`

Implements `SecureStorage` over a private `Map<String, String>`. No persistence between tests because each test builds a fresh instance.

## Existing tests at a glance

### `ErrorMapper` (unit)

[`error_mapper_test.dart`](../test/core/error/error_mapper_test.dart) covers each arm of the mapping table:

- `Ok` happy path.
- Supabase `AuthException` → `AuthFailure`.
- Dio `connectionTimeout` → `NetworkFailure`.
- Dio 401 → `AuthFailure`.
- Dio 500 → `ServerFailure`.
- `SocketException` → `NetworkFailure`.
- Any other (`StateError`) → `UnknownFailure`.

`setUpAll(() => AppLogger.init(Flavor.dev))` is required because `guard` logs every catch via Talker.

### `ThemeController` (unit)

[`theme_controller_test.dart`](../test/core/theme/theme_controller_test.dart) covers:

- Defaults to `ThemeMode.system` when no preference is stored.
- Hydrates from a mocked `SharedPreferences` (`{PrefsKeys.themeMode: 'dark'}`).
- `set` persists to prefs (asserted via `prefs.getString(PrefsKeys.themeMode)`).
- `toggle` cycles **light → dark → system → light**.

### `AuthController` (controller)

[`auth_controller_test.dart`](../test/features/auth/auth_controller_test.dart) covers:

- Initial state is `Unauthenticated` when `currentUser` is null.
- `signIn` happy path → `Authenticated`.
- `signIn` failure → `state.hasError`.
- `signOut` happy path → back to `Unauthenticated`.
- `signInWithGoogle`:
  - Increments `googleSignInCount`.
  - **Stays `Unauthenticated`** immediately after a successful launch (because the actual session is delivered later via the auth stream).
  - Calling `fake.emit(user)` simulates the deep-link callback; the controller transitions to `Authenticated`.
- `signInWithGoogle` failure → `state.hasError`.

### `SignInScreen` (widget)

[`sign_in_screen_test.dart`](../test/features/auth/sign_in_screen_test.dart) uses `pumpApp` + `FakeAuthRepository`. Asserts:

- Email / password / submit fields render via key finders (`signIn.email` / `signIn.password` / `signIn.submit`).
- Tapping submit on empty form shows `Email is required` / `Password is required`.
- Filling fields + tapping submit calls the fake repo (`fake.currentUser.email == 'a@b.com'`).

`tester.ensureVisible(submit)` is used because the default 600×800 test viewport can push the submit button off-screen.

### Integration smoke

[`integration_test/app_smoke_test.dart`](../integration_test/app_smoke_test.dart) boots the real `App` with `IntegrationTestWidgetsFlutterBinding`, overrides `appConfigProvider` (`_smokeConfig`), `sharedPreferencesProvider`, and `authRepositoryProvider` with a `FakeAuthRepository`, then pumps a couple of frames and asserts `Sign in` text appears. Run with:

```sh
flutter test integration_test/app_smoke_test.dart
```

> **Non-obvious:** the integration test imports the fake from `../test/helpers/fakes.dart`. It is **not wired into CI** — `.github/workflows/ci.yml` only runs `flutter test` (which discovers `test/`). If you want it on CI, add an explicit step.

## Conventions

- **Fakes over mocks.** `mocktail` is in `pubspec.yaml` but the existing tests use hand-written fakes. Pattern: write `Fake<X>` implementing the interface, then override the provider via `testContainer(authRepository: fake)`.
- **Provider override over global mocking.** Don't reach into `Supabase.instance` from a test — override `authRepositoryProvider` or any other repo provider with a fake.
- **Stable widget keys.** Use `Key('feature.thing')` (e.g. `signIn.email`). Widget tests find by key, not by text, so copy changes don't break them.
- **`addTearDown` everything.** Both `pumpApp`'s container and any fake with a `StreamController` (`FakeAuthRepository`) need explicit cleanup.
- **`AppLogger.init(Flavor.dev)`** before any test that exercises code paths calling `AppLogger.instance.handle(...)` — `pump_app.dart` does this for you, but pure-Dart tests like `error_mapper_test.dart` need a `setUpAll`.

## Adding a new test

1. Need a `ProviderContainer` only? `final container = await testContainer(...);` + `addTearDown(container.dispose);`.
2. Need to pump a widget? `await pumpApp(tester, MyScreen(), authRepository: fake, prefsValues: {...});`.
3. Need a fake repository? Build one matching the interface, store it in a `setUp` variable, override via the helper, and `addTearDown` its dispose if it owns a `StreamController`.

## See also

- [`tooling.md`](tooling.md) — `make test` / `make test-coverage` and the GitHub Actions test step.
- [`auth.md`](auth.md) — what the controller / repo / screens look like.
- [`error-handling.md`](error-handling.md) — the mapping table that `error_mapper_test.dart` covers.
- [`theming.md`](theming.md) — the controller behavior the theme tests validate.
