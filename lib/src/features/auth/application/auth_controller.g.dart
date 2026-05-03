// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream of underlying auth events from the SDK. Wrapped as a Riverpod
/// `StreamProvider` so [AuthController] can `ref.listen` to it without
/// owning subscription lifecycle.

@ProviderFor(authEvents)
final authEventsProvider = AuthEventsProvider._();

/// Stream of underlying auth events from the SDK. Wrapped as a Riverpod
/// `StreamProvider` so [AuthController] can `ref.listen` to it without
/// owning subscription lifecycle.

final class AuthEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<sb.AuthState>,
          sb.AuthState,
          Stream<sb.AuthState>
        >
    with $FutureModifier<sb.AuthState>, $StreamProvider<sb.AuthState> {
  /// Stream of underlying auth events from the SDK. Wrapped as a Riverpod
  /// `StreamProvider` so [AuthController] can `ref.listen` to it without
  /// owning subscription lifecycle.
  AuthEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authEventsHash();

  @$internal
  @override
  $StreamProviderElement<sb.AuthState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<sb.AuthState> create(Ref ref) {
    return authEvents(ref);
  }
}

String _$authEventsHash() => r'1151212bf3e491421727fcff48d9dcd77bb1b9ba';

/// Single source of truth for "is the user signed in?" used by the router
/// guard and by feature controllers.
///
/// Resolves the initial auth state synchronously on `build`, then keeps
/// it in sync with [authEventsProvider]. Mutations (`signIn`/`signUp`/
/// `signOut`) drive the state explicitly so the UI shows loading/error
/// states promptly.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Single source of truth for "is the user signed in?" used by the router
/// guard and by feature controllers.
///
/// Resolves the initial auth state synchronously on `build`, then keeps
/// it in sync with [authEventsProvider]. Mutations (`signIn`/`signUp`/
/// `signOut`) drive the state explicitly so the UI shows loading/error
/// states promptly.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AuthState> {
  /// Single source of truth for "is the user signed in?" used by the router
  /// guard and by feature controllers.
  ///
  /// Resolves the initial auth state synchronously on `build`, then keeps
  /// it in sync with [authEventsProvider]. Mutations (`signIn`/`signUp`/
  /// `signOut`) drive the state explicitly so the UI shows loading/error
  /// states promptly.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'de6f745a72c1b835d7fc0b3c3d821ec1c764287a';

/// Single source of truth for "is the user signed in?" used by the router
/// guard and by feature controllers.
///
/// Resolves the initial auth state synchronously on `build`, then keeps
/// it in sync with [authEventsProvider]. Mutations (`signIn`/`signUp`/
/// `signOut`) drive the state explicitly so the UI shows loading/error
/// states promptly.

abstract class _$AuthController extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
