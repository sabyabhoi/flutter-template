# Networking

A single `Dio` instance is exposed via `dioProvider`. It is preconfigured with timeouts, a JSON content-type header, a Supabase-aware bearer-token interceptor, the shared Talker logger, and (when a Sentry DSN is set) the `sentry_dio` integration. A small hand-written `ApiException` is available for repos that need to throw a semantically-meaningful failure on top of a successful HTTP response.

## Files

| File | Description |
| --- | --- |
| [`lib/src/core/network/dio_client.dart`](../lib/src/core/network/dio_client.dart) | `dioProvider` (codegen via `@riverpod`) plus the private `_AuthInterceptor`. Generated `dio_client.g.dart`. |
| [`lib/src/core/network/api_exception.dart`](../lib/src/core/network/api_exception.dart) | `ApiException` for repo-level "200 with error payload" cases. |

## `dioProvider`

[`@riverpod Dio dio(Ref ref)`](../lib/src/core/network/dio_client.dart) builds a `Dio` from the current `AppConfig` and returns it. `ref.onDispose(dio.close)` ensures sockets/IO are released if the provider is ever rebuilt.

### `BaseOptions`

| Setting | Value |
| --- | --- |
| `baseUrl` | `config.apiBaseUrl` (from [`env/<flavor>.json`](../env/example.json)) |
| `connectTimeout` | 15 seconds |
| `receiveTimeout` | 30 seconds |
| `sendTimeout` | 30 seconds |
| Default headers | `{'content-type': 'application/json'}` |

### Interceptor stack (in order)

1. **`_AuthInterceptor`** — see below.
2. **`TalkerDioLogger(talker: AppLogger.instance)`** — pipes request/response/error events into the shared Talker log used by the in-app `TalkerScreen`. See [`observability.md`](observability.md).
3. **`dio.addSentry()`** (only if `config.sentryEnabled`) — captures failed requests as Sentry breadcrumbs / events via `sentry_dio`.

## `_AuthInterceptor`

```dart
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(options, handler) {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

The interceptor reads `Supabase.instance.client.auth.currentSession?.accessToken` per request and attaches it as a `Bearer` token. Suitable for talking to Supabase Edge Functions, or any backend that validates Supabase JWTs.

Non-obvious — **this interceptor does not refresh tokens itself.** It only snapshots the current Supabase session. Token refresh is handled inside `supabase_flutter`'s auth client; subsequent Dio requests automatically pick up the new `currentSession` once Supabase has rotated it. If you have non-Supabase auth, you'll need to add your own refresh logic (or replace this interceptor entirely).

## `ApiException`

[`api_exception.dart`](../lib/src/core/network/api_exception.dart) is a hand-written exception:

```dart
class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.payload});
  final String message;
  final int? statusCode;
  final Object? payload;
  // ...
}
```

Use it inside a repository when Dio returns a 200 but the **payload itself** indicates failure (e.g. `{"error": "..."}` envelopes). Throw it inside an `ErrorMapper.guard(...)` block; it will be caught by the `Object` arm of `ErrorMapper.guard` and wrapped as `Failure.unknown` with the message preserved. (If you want it to map to `Failure.server` instead, add a dedicated arm to [`ErrorMapper`](../lib/src/core/error/error_mapper.dart).)

## How error mapping looks end-to-end

Anything thrown inside a repo method that calls `dio.get/post/...` and is wrapped in `ErrorMapper.guard` ends up as a `Failure`:

| Source | `Failure` arm |
| --- | --- |
| Dio timeouts (connect/send/receive) | `Failure.network('Request timed out')` |
| Dio `connectionError` | `Failure.network('Connection error')` |
| Dio `badResponse` 401/403 | `Failure.auth('Not authorized')` |
| Dio `badResponse` other | `Failure.server(message: response.statusMessage ?? 'Server error', statusCode: status)` |
| Dio `cancel` | `Failure.unknown('Request cancelled')` |
| Dio `badCertificate` / `unknown` | `Failure.unknown(...)` |
| `SocketException` | `Failure.network('No internet connection')` |
| `TimeoutException` | `Failure.network('Request timed out')` |
| Hand-thrown `ApiException` | `Failure.unknown(message: e.toString())` (default arm) |

See [`error-handling.md`](error-handling.md) for the full mapping logic.

## See also

- [`auth.md`](auth.md) — `_AuthInterceptor` reads the same Supabase session that powers `AuthRepository`.
- [`env-and-flavors.md`](env-and-flavors.md) — `config.apiBaseUrl` and `config.sentryEnabled` come from there.
- [`observability.md`](observability.md) — what `TalkerDioLogger` / `dio.addSentry()` end up doing.
