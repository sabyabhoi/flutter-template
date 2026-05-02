import 'dart:async';

import 'package:app/src/core/env/app_config.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Process-wide error handler.
///
/// Wires the three Flutter error sinks into Talker (always) and Sentry
/// (when [AppConfig.sentryEnabled]):
///
///  * `FlutterError.onError`              — synchronous framework errors.
///  * `PlatformDispatcher.instance.onError` — uncaught async errors.
///  * `runZonedGuarded` (in `bootstrap.dart`) — anything else.
class ErrorHandler {
  const ErrorHandler._();

  /// Install global error sinks. Must be called after [AppLogger.init] but
  /// can be called before or after Sentry — Sentry calls go through a
  /// runtime check so missing init is a no-op rather than a crash.
  static void install(AppConfig config) {
    final originalOnError = FlutterError.onError;

    FlutterError.onError = (details) {
      originalOnError?.call(details);
      AppLogger.instance.handle(
        details.exception,
        details.stack,
        'FlutterError: ${details.context?.toDescription() ?? "no context"}',
      );
      if (config.sentryEnabled) {
        unawaited(
          _safeCapture(
            details.exception,
            details.stack,
            source: 'FlutterError.onError',
          ),
        );
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.instance.handle(error, stack, 'PlatformDispatcher.onError');
      if (config.sentryEnabled) {
        unawaited(
          _safeCapture(error, stack, source: 'PlatformDispatcher.onError'),
        );
      }
      return true;
    };
  }

  /// Forward an explicitly-caught error from a controller / use-case layer.
  /// Prefer `ErrorMapper.guard` in repositories — this is for the rare
  /// cases where you've caught something but still want it on Sentry.
  static Future<void> report(
    Object error,
    StackTrace stackTrace, {
    String? context,
    Map<String, Object?> extras = const {},
  }) async {
    AppLogger.instance.handle(error, stackTrace, context);
    if (!Sentry.isEnabled) return;
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) async {
        if (context != null) await scope.setTag('context', context);
        for (final entry in extras.entries) {
          await scope.setContexts(entry.key, entry.value ?? '');
        }
      },
    );
  }

  static Future<void> _safeCapture(
    Object error,
    StackTrace? stack, {
    required String source,
  }) async {
    if (!Sentry.isEnabled) return;
    await Sentry.captureException(
      error,
      stackTrace: stack,
      withScope: (scope) => scope.setTag('source', source),
    );
  }
}
