import 'dart:io';

import 'package:app/src/core/env/flavor.dart';
import 'package:app/src/core/error/error_mapper.dart';
import 'package:app/src/core/error/failure.dart';
import 'package:app/src/core/error/result.dart';
import 'package:app/src/core/logging/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

void main() {
  setUpAll(() => AppLogger.init(Flavor.dev));

  const mapper = ErrorMapper();

  group('ErrorMapper.guard', () {
    test('returns Ok on success', () async {
      final result = await mapper.guard(() async => 42);
      expect(result, isA<Ok<int>>());
      expect(result.valueOrNull, 42);
    });

    test('maps Supabase AuthException → AuthFailure', () async {
      final result = await mapper.guard<int>(() async {
        throw const sb.AuthException('bad creds', code: '400');
      });
      expect(result, isA<Err<int>>());
      expect(result.failureOrNull, isA<AuthFailure>());
    });

    test('maps DioException timeout → NetworkFailure', () async {
      final result = await mapper.guard<int>(() async {
        throw DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionTimeout,
        );
      });
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('maps Dio 401 → AuthFailure', () async {
      final result = await mapper.guard<int>(() async {
        throw DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 401,
          ),
        );
      });
      expect(result.failureOrNull, isA<AuthFailure>());
    });

    test('maps Dio 500 → ServerFailure', () async {
      final result = await mapper.guard<int>(() async {
        throw DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 500,
            statusMessage: 'kaboom',
          ),
        );
      });
      expect(result.failureOrNull, isA<ServerFailure>());
    });

    test('maps SocketException → NetworkFailure', () async {
      final result = await mapper.guard<int>(() async {
        throw const SocketException('no net');
      });
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('maps anything else → UnknownFailure', () async {
      final result = await mapper.guard<int>(() async {
        throw StateError('boom');
      });
      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });
}
