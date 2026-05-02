import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

/// Sample table — a key/value cache for arbitrary JSON payloads, intended
/// as a starting point. Replace with feature-specific tables as the app
/// grows; the singleton database is exposed via [appDatabaseProvider].
class CacheEntries extends Table {
  TextColumn get key => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [CacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory ctor used by tests. Pass e.g.
  /// `NativeDatabase.memory()` or any other [QueryExecutor].
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  Future<void> upsertCache(String key, String payload) {
    return into(cacheEntries).insertOnConflictUpdate(
      CacheEntriesCompanion.insert(
        key: key,
        payload: payload,
        fetchedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<CacheEntry?> readCache(String key) {
    return (select(
      cacheEntries,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  Future<int> clearCache() => delete(cacheEntries).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'app.sqlite'));
    if (Platform.isAndroid) {
      // Some old Android devices have a buggy bundled sqlite; force ours.
      // Function lives in `sqlite3_flutter_libs` (kept for the side effect
      // import above); we tolerate the runtime cost of the no-op on newer
      // Androids.
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    return NativeDatabase.createInBackground(dbFile);
  });
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
