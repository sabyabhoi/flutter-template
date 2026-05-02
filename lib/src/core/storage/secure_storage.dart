import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

/// Thin wrapper around [`FlutterSecureStorage`] so feature code never
/// depends on the underlying plugin directly. Makes it trivial to fake in
/// tests via a Riverpod override.
abstract class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// Default implementation backed by `flutter_secure_storage`.
///
/// On Android we opt into encrypted shared preferences for better
/// resilience to backup/restore edge cases.
class FlutterSecureStorageImpl implements SecureStorage {
  FlutterSecureStorageImpl()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );

  @visibleForTesting
  FlutterSecureStorageImpl.withStorage(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}

@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) => FlutterSecureStorageImpl();
