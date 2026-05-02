// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(dio)
final dioProvider = DioProvider._();

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

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
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
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'eb199a5b3a2c377691dedf86f8b48b785a39aa80';
