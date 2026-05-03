# Local Storage

Three storage primitives are wired up out of the box: a `SecureStorage` interface backed by Keychain / EncryptedSharedPreferences for tokens, a `SharedPreferences` instance for non-sensitive UI flags, and a Drift (SQLite) database with a sample `CacheEntries` table to grow into.

## Files

| File | Description |
| --- | --- |
| [`lib/src/core/storage/secure_storage.dart`](../lib/src/core/storage/secure_storage.dart) | `SecureStorage` interface, `FlutterSecureStorageImpl`, `secureStorageProvider`. Generated `secure_storage.g.dart`. |
| [`lib/src/core/storage/prefs.dart`](../lib/src/core/storage/prefs.dart) | `sharedPreferencesProvider` (throws if not overridden) + `PrefsKeys`. |
| [`lib/src/core/storage/db/app_database.dart`](../lib/src/core/storage/db/app_database.dart) | Drift `AppDatabase` with the `CacheEntries` table + `appDatabaseProvider`. Generated `app_database.g.dart`. |

## SecureStorage

[`SecureStorage`](../lib/src/core/storage/secure_storage.dart) is a small abstract interface so feature code never depends on `flutter_secure_storage` directly. Faking in tests becomes a one-line Riverpod override (see [`testing.md`](testing.md) and `FakeSecureStorage`).

```dart
abstract class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}
```

### `FlutterSecureStorageImpl`

The default implementation:

| Platform | Backing store / options |
| --- | --- |
| Android | `EncryptedSharedPreferences` (`AndroidOptions(encryptedSharedPreferences: true)`) for resilience to backup/restore edge cases. |
| iOS | Keychain with `KeychainAccessibility.first_unlock`. |

`@visibleForTesting FlutterSecureStorageImpl.withStorage(this._storage)` is provided so a unit test can inject a mock `FlutterSecureStorage` if needed.

`@Riverpod(keepAlive: true) SecureStorage secureStorage(Ref) => FlutterSecureStorageImpl();`

## SharedPreferences

[`sharedPreferencesProvider`](../lib/src/core/storage/prefs.dart) is the standard pattern used throughout the project: declared with a throwing default, **overridden in [`bootstrap()`](../lib/bootstrap.dart)** after `SharedPreferences.getInstance()` resolves, and overridden again in tests via `pump_app.dart`'s `testContainer`.

Why the override pattern instead of a `FutureProvider`? So consumers can `ref.watch(sharedPreferencesProvider)` synchronously — for an in-memory store this is zero-cost and avoids dragging `AsyncValue` through every UI flag.

### `PrefsKeys`

Centralised list of preference keys to avoid stringly-typed typos:

```dart
abstract class PrefsKeys {
  static const themeMode = 'app.theme_mode';
  static const onboardingComplete = 'app.onboarding_complete';
  static const localeTag = 'app.locale_tag';
}
```

Currently only `themeMode` is read/written (by [`ThemeController`](../lib/src/core/theme/theme_controller.dart) — see [`theming.md`](theming.md)). The other two are reserved namespaces ready to be used.

## Drift database

[`AppDatabase`](../lib/src/core/storage/db/app_database.dart) is the singleton Drift database, exposed via `appDatabaseProvider`. It ships with a single sample table — replace with feature-specific tables as the app grows.

### Schema

`CacheEntries` — a key/value cache for arbitrary JSON payloads:

| Column | Type | Notes |
| --- | --- | --- |
| `key` | `text` | Primary key. |
| `payload` | `text` | Arbitrary string (intended for JSON). |
| `fetchedAt` | `dateTime` | UTC. Stored as text via `build.yaml` (`store_date_time_values_as_text: true`). |

`schemaVersion` is `1`. Bump it and add a `migrationStrategy` whenever you change the table set or columns; otherwise upgrades will fail at runtime.

### Methods

| Method | Description |
| --- | --- |
| `Future<void> upsertCache(String key, String payload)` | Upsert into `CacheEntries` with `fetchedAt = DateTime.now().toUtc()`. |
| `Future<CacheEntry?> readCache(String key)` | Single-row select, returns `null` if not found. |
| `Future<int> clearCache()` | Drops every row, returns the count. |

### Database location

`_openConnection()`:

1. `getApplicationDocumentsDirectory()` → `app.sqlite` in that directory.
2. On Android, calls `applyWorkaroundToOpenSqlite3OnOldAndroidVersions()` from `sqlite3_flutter_libs` (no-op on newer Android, fixes a buggy bundled sqlite on old devices).
3. Returns `NativeDatabase.createInBackground(dbFile)` wrapped in a `LazyDatabase`.

`AppDatabase.forTesting(super.e)` accepts any `QueryExecutor` (e.g. `NativeDatabase.memory()`) so tests can use an in-memory db without touching the filesystem.

`appDatabaseProvider` is `@Riverpod(keepAlive: true)` and registers `ref.onDispose(db.close)`.

## See also

- [`theming.md`](theming.md) — `ThemeController` is the only current reader of `PrefsKeys`.
- [`auth.md`](auth.md) — Supabase manages its own session storage internally; `SecureStorage` here is for **your** secrets.
- [`tooling.md`](tooling.md) — `build.yaml` settings (`store_date_time_values_as_text`, `named_parameters`) that shape Drift's generated code.
