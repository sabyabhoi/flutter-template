import 'package:app/src/core/logging/app_logger.dart';
import 'package:app/src/core/providers/app_config_provider.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

part 'dio_client.g.dart';

/// Provides a configured [Dio] instance.
///
/// Interceptors:
///  * `_AuthInterceptor` — attaches the current Supabase access token
///     (if any) as a `Bearer` token. Suitable for talking to Supabase
///     edge functions or your own backend that validates Supabase JWTs.
///  * `TalkerDioLogger` — pipes request/response/error events into the
///     shared Talker log used by the in-app log viewer.
///  * `Sentry` — captures failed requests as breadcrumbs / events when
///     Sentry is enabled.
@riverpod
Dio dio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final dio =
      Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: const {'content-type': 'application/json'},
          ),
        )
        ..interceptors.addAll([
          _AuthInterceptor(),
          TalkerDioLogger(talker: AppLogger.instance),
        ]);

  if (config.sentryEnabled) {
    dio.addSentry();
  }

  ref.onDispose(dio.close);
  return dio;
}

/// Attaches the Supabase access token to every outgoing request.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
