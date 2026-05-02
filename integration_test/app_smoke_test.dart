// Boot smoke test. Mounts the real `App` widget tree with a fake auth
// repository so we don't touch a live Supabase, and asserts the splash →
// sign-in transition completes.
//
// Run with:
//   flutter test integration_test/app_smoke_test.dart

import 'package:app/src/app/app.dart';
import 'package:app/src/core/env/app_config.dart';
import 'package:app/src/core/env/flavor.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/providers/app_config_provider.dart';
import 'package:app/src/core/storage/prefs.dart';
import 'package:app/src/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/fakes.dart';

const _smokeConfig = AppConfig(
  flavor: Flavor.dev,
  appName: 'App (Test)',
  supabaseUrl: 'https://test.supabase.co',
  supabaseAnonKey: 'test-anon-key',
  sentryDsn: '',
  apiBaseUrl: 'https://api.test.example.com',
);

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots into sign-in for unauthenticated users', (
    tester,
  ) async {
    AppLogger.init(Flavor.dev);
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    final fakeAuth = FakeAuthRepository();
    addTearDown(fakeAuth.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(_smokeConfig),
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(fakeAuth),
        ],
        child: const App(),
      ),
    );

    // Pump multiple frames to let the auth stream emit and the router
    // redirect from splash to sign-in.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sign in'), findsWidgets);
  });
}
