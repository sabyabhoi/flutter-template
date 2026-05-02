import 'dart:async';

import 'package:app/src/app/app.dart';
import 'package:app/src/core/env/app_config.dart';
import 'package:app/src/core/env/flavor.dart';
import 'package:app/src/core/error/error_handler.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/providers/app_config_provider.dart';
import 'package:app/src/core/storage/prefs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

/// Single bootstrap routine reused by every `main_<flavor>.dart`.
///
/// Order matters:
///   1. Initialise Flutter bindings.
///   2. Build the typed [AppConfig] (fail fast on bad env).
///   3. Initialise Talker — every later step logs through it.
///   4. Initialise Supabase + SharedPreferences (concurrently).
///   5. Install global error handlers (so step 6's runApp is guarded).
///   6. Initialise Sentry (if DSN configured) and runApp inside its zone.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment(flavor);
  AppLogger.init(flavor);

  final prefs = await SharedPreferences.getInstance();
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
    debug: !flavor.isProd,
  );

  ErrorHandler.install(config);

  Widget appRunner() => ProviderScope(
    observers: [
      TalkerRiverpodObserver(talker: AppLogger.instance),
    ],
    overrides: [
      appConfigProvider.overrideWithValue(config),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const App(),
  );

  if (config.sentryEnabled) {
    await SentryFlutter.init(
      (o) => o
        ..dsn = config.sentryDsn
        ..environment = flavor.name
        ..release = config.appName
        ..tracesSampleRate = flavor.isProd ? 0.2 : 1.0
        ..attachStacktrace = true,
      appRunner: () => runApp(appRunner()),
    );
  } else {
    AppLogger.instance.info(
      'Sentry disabled (no DSN set for flavor=${flavor.name}).',
    );
    runZonedGuarded(
      () => runApp(appRunner()),
      (error, stack) =>
          AppLogger.instance.handle(error, stack, 'runZonedGuarded'),
    );
  }
}
