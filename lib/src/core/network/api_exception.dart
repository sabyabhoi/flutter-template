/// Exception thrown by hand-written API client wrappers.
///
/// Dio's own [`DioException`] is fine for low-level interception, but this
/// type lets feature-level repos throw something semantically meaningful
/// when the response payload itself indicates failure (e.g. a 200 with
/// `{"error": "..."}` body).
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.payload,
  });

  final String message;
  final int? statusCode;
  final Object? payload;

  @override
  String toString() =>
      'ApiException(${statusCode ?? '-'}, $message${payload == null ? '' : ', $payload'})';
}
