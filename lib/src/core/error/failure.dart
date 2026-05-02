import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Domain-level error type returned by repositories.
///
/// Repositories catch SDK-specific exceptions (`AuthException`,
/// `PostgrestException`, `DioException`, …) and translate them into one of
/// these variants so that the rest of the app never has to know which
/// backend produced the error.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Connectivity / DNS / timeout / 5xx-from-edge style problems.
  const factory Failure.network({
    required String message,
    int? statusCode,
    Object? cause,
    StackTrace? stackTrace,
  }) = NetworkFailure;

  /// Authentication / authorization problems (4xx auth, expired token, …).
  const factory Failure.auth({
    required String message,
    String? code,
    Object? cause,
    StackTrace? stackTrace,
  }) = AuthFailure;

  /// Backend returned a structured error (4xx/5xx with payload) that isn't
  /// auth-related.
  const factory Failure.server({
    required String message,
    int? statusCode,
    Object? cause,
    StackTrace? stackTrace,
  }) = ServerFailure;

  /// Local validation problem we can show inline next to a field.
  const factory Failure.validation({
    required String message,
    String? field,
  }) = ValidationFailure;

  /// Catch-all for unexpected exceptions. These should be reported to
  /// Sentry with the original [cause]/[stackTrace].
  const factory Failure.unknown({
    required String message,
    Object? cause,
    StackTrace? stackTrace,
  }) = UnknownFailure;

  /// Human-readable summary suitable for surfacing in a SnackBar.
  String get displayMessage => switch (this) {
    NetworkFailure(:final message) => message,
    AuthFailure(:final message) => message,
    ServerFailure(:final message) => message,
    ValidationFailure(:final message) => message,
    UnknownFailure(:final message) => message,
  };
}
