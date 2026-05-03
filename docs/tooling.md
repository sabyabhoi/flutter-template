# Tooling, CI, and Build

The project's day-to-day developer experience runs through `make`. CI is a single GitHub Actions job that mirrors the same commands. Lints come from `very_good_analysis` with a few project-specific opt-outs, code generation is driven by `build_runner`, and the dependency tree is intentionally pinned in places to keep the analyzer / Talker / Windows-secure-storage triangle compatible.

## Files

| File | Description |
| --- | --- |
| [`Makefile`](../Makefile) | Developer entrypoints (`bootstrap`, `gen`, `format`, `analyze`, `test`, `run-*`, `build-*`, `clean`). |
| [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) | Single GitHub Actions job: format → analyze → test (with coverage). |
| [`analysis_options.yaml`](../analysis_options.yaml) | Lint config (`very_good_analysis` + opt-outs + analyzer excludes). |
| [`build.yaml`](../build.yaml) | `build_runner` options for `freezed`, `json_serializable`, `riverpod_generator`, `drift_dev`. |
| [`pubspec.yaml`](../pubspec.yaml) | Dependencies, dev_dependencies, Flutter config. |

## `Makefile` targets

[`Makefile`](../Makefile) is the official entrypoint for everything you do locally. `make help` greps the file for `# `-commented targets and prints them.

### Setup / codegen

| Target | Behavior |
| --- | --- |
| `make bootstrap` | `make get` then `make gen`. First-run convenience. |
| `make get` | `flutter pub get`. |
| `make gen` | `dart run build_runner build`. One-shot codegen for `freezed`, `json_serializable`, `riverpod`, `drift`. |
| `make gen-watch` | `dart run build_runner watch`. Keep this running while iterating. |
| `make gen-clean` | `dart run build_runner clean && build` — wipe + regenerate when stale outputs cause confusing errors. |

### Quality

| Target | Behavior |
| --- | --- |
| `make format` | `dart format lib test integration_test`. |
| `make analyze` | `flutter analyze`. Uses `very_good_analysis` + `riverpod_lint`. |
| `make test` | `flutter test`. Discovers tests under `test/`. |
| `make test-coverage` | `flutter test --coverage`. Outputs `coverage/lcov.info`. |

### Run / build (per flavor)

All run / build targets pass the `--flavor` + `-t lib/main_<flavor>.dart` + `--dart-define-from-file=env/<flavor>.json` triple. They assume `env/<flavor>.json` exists — copy from [`env/example.json`](../env/example.json) for the first run.

| Target | What it runs |
| --- | --- |
| `make run-dev` / `run-staging` / `run-prod` | `flutter run` for the named flavor. |
| `make build-apk-dev` | `flutter build apk --debug` for dev. |
| `make build-apk-staging` / `build-apk-prod` | `flutter build apk --release` for staging / prod. |
| `make build-ios-dev` | `flutter build ios --debug` for dev. (Requires the one-time Xcode wiring in the README.) |
| `make build-ios-staging` / `build-ios-prod` | `flutter build ios --release` for staging / prod. |

### Maintenance

| Target | Behavior |
| --- | --- |
| `make clean` | `flutter clean`. |

## CI

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) — a single job (`analyze-test`) on `ubuntu-latest`, `timeout-minutes: 20`, triggered on `push` and `pull_request` to `main`. No matrix.

Steps in order:

1. `actions/checkout@v4`.
2. `subosito/flutter-action@v2` — `channel: stable`, `cache: true`.
3. `flutter pub get`.
4. `dart run build_runner build` — codegen runs **before** `analyze` and `test`, so any failed generator breaks CI immediately.
5. `dart format --output=none --set-exit-if-changed lib test integration_test`.
6. `flutter analyze`.
7. `cp env/example.json env/dev.json` — see "Why CI copies the example env" below.
8. `flutter test --coverage --reporter=compact`.
9. `actions/upload-artifact@v4` — uploads `coverage/lcov.info` as the `coverage` artifact (`if: always()`, `if-no-files-found: ignore`).

> **Non-obvious:**
> - **No matrix** (single Ubuntu / stable channel). If you add macOS / Windows or beta channels, consider whether the pinned dependency versions in `pubspec.yaml` (Talker / win32 / secure storage) are compatible.
> - **`integration_test/app_smoke_test.dart` is not part of CI.** `flutter test` discovers `test/` only. If you want the smoke test on PRs, add an explicit `flutter test integration_test/app_smoke_test.dart` step.
> - **`Makefile` is not invoked by CI** — Actions calls `flutter` / `dart` directly. If you add a target the team relies on (e.g. a custom lint), wire it into both.

### Why CI copies the example env

CI doesn't have real Supabase credentials, but `--dart-define-from-file` is a **compile-time** mechanism, so unit/widget tests still need *some* env file present to build. Tests **override `appConfigProvider` with `testConfig`** (see [`testing.md`](testing.md)) — they never touch a real Supabase, so the placeholder values in `env/example.json` are safe.

## `analysis_options.yaml`

[`analysis_options.yaml`](../analysis_options.yaml) extends `package:very_good_analysis/analysis_options.yaml` and:

- **Excludes generated files** from analysis: `**/*.g.dart`, `**/*.freezed.dart`, `**/*.config.dart`, `lib/generated/**`, `build/**`.
- **`invalid_annotation_target: ignore`** — needed by `freezed` 3.x emitting `@JsonKey` on private constructors.
- **Lint opt-outs** (don't re-enable casually; the codebase intentionally doesn't follow these):
  - `public_member_api_docs: false` — no doc-comment requirement on every public symbol.
  - `lines_longer_than_80_chars: false` — wrap when readable, not by ruler.
  - `avoid_classes_with_only_static_members: false` — `AppLogger`, `ErrorHandler`, `AppRadii`, etc. all use this pattern.
  - `one_member_abstracts: false` — `SecureStorage` and `AuthRepository` are interfaces with one method on purpose.
  - `sort_pub_dependencies: false` — dependencies are grouped by role with comments.
- **`custom_lint:`** is present but empty. `riverpod_lint` 3.1.3+ uses the new `analysis_server_plugin` API directly (no `custom_lint` dep) — see the comment in [`pubspec.yaml`](../pubspec.yaml).

## `build.yaml`

[`build.yaml`](../build.yaml) tweaks the code generators:

| Builder | Option | Value | Why |
| --- | --- | --- | --- |
| `freezed` | `generic_argument_factories` | `false` | Default `copyWith`/`==`/`hashCode`/`toString` only. |
| `json_serializable` | `explicit_to_json` | `true` | Forces `toJson()` to be called explicitly so nested models serialize correctly. |
| `json_serializable` | `field_rename` | `snake` | DTO fields use `snake_case` to match typical backend payloads. |
| `json_serializable` | `create_to_json` | `true` | Generate `toJson` even if you only currently use `fromJson`. |
| `json_serializable` | `include_if_null` | `false` | Drops null fields from generated JSON output. |
| `riverpod_generator` | `provider_family_name` | `Provider` | The generated family-mode provider gets the suffix `Provider` (e.g. `myProvider`). |
| `drift_dev` | `store_date_time_values_as_text` | `true` | `DateTime` columns persist as ISO-8601 text rather than int microseconds — round-trips timezone info correctly. |
| `drift_dev` | `named_parameters` | `true` | Generated companion / insert constructors use named params for readability. |

## `pubspec.yaml` dependency map

[`pubspec.yaml`](../pubspec.yaml) is intentionally grouped by role (with comments) and **does not** sort alphabetically (see `sort_pub_dependencies: false`).

### Runtime

| Group | Packages |
| --- | --- |
| State management | `flutter_riverpod ^3.3.1`, `riverpod_annotation ^4.0.2` |
| Routing | `go_router ^17.2.3` |
| Models / serialization | `freezed_annotation ^3.1.0`, `json_annotation ^4.11.0`, `meta ^1.16.0` |
| Auth backend | `supabase_flutter ^2.12.4` |
| Networking | `dio ^5.9.2` |
| Local data (SQLite) | `drift >=2.30.0 <2.32.0`, `sqlite3_flutter_libs ^0.5.40`, `path_provider ^2.1.5`, `path ^1.9.0` |
| Local data (key/value) | `flutter_secure_storage ^9.2.4`, `shared_preferences ^2.5.5` |
| Logging | `talker_flutter >=5.1.14 <5.1.17`, `talker_riverpod_logger >=5.1.14 <5.1.17`, `talker_dio_logger >=5.1.14 <5.1.17` |
| Crash reporting | `sentry_flutter ^9.19.0`, `sentry_dio ^9.19.0` |
| Typography | `google_fonts ^6.2.1` |

### Dev / test / lint

| Group | Packages |
| --- | --- |
| Test runners | `flutter_test`, `integration_test` |
| Test utilities | `mocktail ^1.0.5` |
| Lints | `very_good_analysis ^10.2.0`, `riverpod_lint ^3.1.3` |
| Codegen | `build_runner ^2.15.0`, `freezed ^3.2.5`, `json_serializable >=6.13.0 <6.13.2`, `riverpod_generator ^4.0.3`, `drift_dev >=2.31.0 <2.32.0` |

### Pin reasoning

A few packages are constrained more tightly than `^x.y.z` would suggest. The `pubspec.yaml` comments explain in detail; the short version:

- **`drift >=2.30.0 <2.32.0` / `drift_dev >=2.31.0 <2.32.0`.** Pinned so the codegen toolchain's `analyzer` constraint stays compatible with `riverpod_lint` and `freezed`.
- **`sqlite3_flutter_libs ^0.5.40`.** The `0.6.0` series is an EOL no-op; we still need `0.5.x` native libs for `drift 2.31.x`.
- **`flutter_secure_storage ^9.2.4` (no 10+).** 10+ pulls a Windows-specific `flutter_secure_storage_windows` 4.x → `win32` 6.x, which clashes with Talker's transitive `share_plus` → `win32` 5.x dep on Windows.
- **`talker_* >=5.1.14 <5.1.17`.** 5.1.17+ bumps `share_plus` to a `win32 ^6.0.0`-using version, same Windows-side conflict as above.
- **`json_serializable >=6.13.0 <6.13.2`.** Keeps the `analyzer` versions across `riverpod_lint`, `riverpod_generator`, `freezed`, and itself mutually compatible.

If you bump any of these, expect to verify the Windows secure-storage path and the codegen toolchain still resolve.

### `flutter:` block

```yaml
flutter:
  uses-material-design: true
  generate: true
```

`generate: true` enables Flutter's tooling for things like `flutter_localizations` codegen if/when an `l10n.yaml` is added. There are **no** `assets:` entries today — env files live under `env/` and are not bundled (they're compile-time `--dart-define-from-file`).

## See also

- [`env-and-flavors.md`](env-and-flavors.md) — what the per-flavor `make run-*` targets actually pass to `flutter`.
- [`testing.md`](testing.md) — what `make test` runs and how the helpers are structured.
- [`storage.md`](storage.md) — what the Drift `build.yaml` settings control.
- [`error-handling.md`](error-handling.md) and [`auth.md`](auth.md) — codegen targets (`freezed`, `riverpod_generator`) that depend on the `build.yaml` settings above.
