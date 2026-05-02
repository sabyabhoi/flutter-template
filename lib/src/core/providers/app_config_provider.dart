import 'package:app/src/core/env/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod handle on the global [AppConfig].
///
/// Always overridden in `bootstrap.dart` (and in tests via
/// `pump_app.dart`) — the default throw-on-read implementation enforces
/// that you can never accidentally use the config in a scope that hasn't
/// been bootstrapped.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError(
    'appConfigProvider must be overridden in main / tests.',
  ),
  name: 'appConfigProvider',
);
