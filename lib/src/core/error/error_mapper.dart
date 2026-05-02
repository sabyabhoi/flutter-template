import 'dart:async';
import 'dart:io';

import 'package:app/src/core/error/failure.dart';
import 'package:app/src/core/error/result.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Translates exceptions thrown by SDKs (Supabase, Dio, …) into [Failure]s
/// and logs them to Talker.
///
/// Repositories should wrap their async work with [guard] so the rest of
/// the app only ever has to deal with `Result`/`Failure`.
class ErrorMapper {
  const ErrorMapper();

  /// Run [body] and translate any thrown error into a [Failure] / [Err].
  Future<Result<T>> guard<T>(Future<T> Function() body) async {
    try {
      return Result<T>.ok(await body());
    } on AuthException catch (e, st) {
      AppLogger.instance.handle(e, st, 'Supabase AuthException');
      return Result<T>.err(
        Failure.auth(
          message: e.message,
          code: e.statusCode,
          cause: e,
          stackTrace: st,
        ),
      );
    } on PostgrestException catch (e, st) {
      AppLogger.instance.handle(e, st, 'Supabase PostgrestException');
      return Result<T>.err(
        Failure.server(
          message: e.message,
          statusCode: int.tryParse(e.code ?? ''),
          cause: e,
          stackTrace: st,
        ),
      );
    } on DioException catch (e, st) {
      AppLogger.instance.handle(e, st, 'DioException');
      return Result<T>.err(_mapDio(e, st));
    } on SocketException catch (e, st) {
      AppLogger.instance.handle(e, st, 'SocketException');
      return Result<T>.err(
        Failure.network(
          message: 'No internet connection',
          cause: e,
          stackTrace: st,
        ),
      );
    } on TimeoutException catch (e, st) {
      AppLogger.instance.handle(e, st, 'TimeoutException');
      return Result<T>.err(
        Failure.network(message: 'Request timed out', cause: e, stackTrace: st),
      );
    } on Object catch (e, st) {
      AppLogger.instance.handle(e, st, 'Unhandled exception in repository');
      return Result<T>.err(
        Failure.unknown(message: e.toString(), cause: e, stackTrace: st),
      );
    }
  }

  Failure _mapDio(DioException e, StackTrace st) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Failure.network(
          message: 'Request timed out',
          cause: e,
          stackTrace: st,
        );
      case DioExceptionType.connectionError:
        return Failure.network(
          message: 'Connection error',
          cause: e,
          stackTrace: st,
        );
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        if (status == 401 || status == 403) {
          return Failure.auth(
            message: 'Not authorized',
            code: status.toString(),
            cause: e,
            stackTrace: st,
          );
        }
        return Failure.server(
          message: e.response?.statusMessage ?? 'Server error',
          statusCode: status,
          cause: e,
          stackTrace: st,
        );
      case DioExceptionType.cancel:
        return Failure.unknown(
          message: 'Request cancelled',
          cause: e,
          stackTrace: st,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return Failure.unknown(
          message: e.message ?? 'Unknown network error',
          cause: e,
          stackTrace: st,
        );
    }
  }
}
