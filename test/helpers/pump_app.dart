import 'package:app/src/core/env/app_config.dart';
import 'package:app/src/core/env/flavor.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/providers/app_config_provider.dart';
import 'package:app/src/core/storage/prefs.dart';
import 'package:app/src/core/storage/secure_storage.dart';
import 'package:app/src/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// Test [AppConfig] with placeholder Supabase keys and Sentry disabled.
const testConfig = AppConfig(
  flavor: Flavor.dev,
  appName: 'App (Test)',
  supabaseUrl: 'https://test.supabase.co',
  supabaseAnonKey: 'test-anon-key',
  sentryDsn: '',
  apiBaseUrl: 'https://api.test.example.com',
  oauthRedirectUrl: 'com.example.app.auth://login-callback',
);

/// Build a [ProviderContainer] with sensible test defaults. Provide
/// additional [overrides] for specific providers under test.
Future<ProviderContainer> testContainer({
  List<Override> overrides = const [],
  AuthRepository? authRepository,
  SecureStorage? secureStorage,
  Map<String, Object>? prefsValues,
}) async {
  AppLogger.init(Flavor.dev);
  SharedPreferences.setMockInitialValues(prefsValues ?? const {});
  final prefs = await SharedPreferences.getInstance();

  return ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(testConfig),
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (secureStorage != null)
        secureStorageProvider.overrideWithValue(secureStorage),
      if (authRepository != null)
        authRepositoryProvider.overrideWithValue(authRepository),
      ...overrides,
    ],
  );
}

/// Pump a widget inside a fully-wired [ProviderScope] for widget tests.
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  AuthRepository? authRepository,
  SecureStorage? secureStorage,
  Map<String, Object>? prefsValues,
}) async {
  final container = await testContainer(
    overrides: overrides,
    authRepository: authRepository,
    secureStorage: secureStorage,
    prefsValues: prefsValues,
  );
  // UncontrolledProviderScope deliberately does NOT dispose its container
  // when removed from the tree, so we have to clean it up explicitly to
  // avoid leaks between tests.
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: child),
    ),
  );
  return container;
}

/// Common fake set used by widget tests that don't care about specific
/// auth scenarios beyond "user is unauthenticated".
({FakeAuthRepository auth, FakeSecureStorage storage}) defaultFakes() {
  return (auth: FakeAuthRepository(), storage: FakeSecureStorage());
}
