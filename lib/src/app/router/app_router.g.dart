// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton [GoRouter] for the app.
///
/// Auth-aware via the [_GoRouterRefreshNotifier] below: any change to
/// [authControllerProvider] triggers `redirect`, which sends the user to
/// `/sign-in` when unauthenticated and away from auth routes when
/// authenticated.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Singleton [GoRouter] for the app.
///
/// Auth-aware via the [_GoRouterRefreshNotifier] below: any change to
/// [authControllerProvider] triggers `redirect`, which sends the user to
/// `/sign-in` when unauthenticated and away from auth routes when
/// authenticated.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Singleton [GoRouter] for the app.
  ///
  /// Auth-aware via the [_GoRouterRefreshNotifier] below: any change to
  /// [authControllerProvider] triggers `redirect`, which sends the user to
  /// `/sign-in` when unauthenticated and away from auth routes when
  /// authenticated.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'edbe57e8148868419867c18b8345fdae2867b456';
