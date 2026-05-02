import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI helpers on [AsyncValue] for consistent loading/error/data rendering.
extension AsyncValueX<T> on AsyncValue<T> {
  /// Renders [data], a centred spinner while loading, and a centred
  /// error widget on failure. Use this everywhere instead of duplicating
  /// `.when(loading: …, error: …, data: …)` blocks.
  Widget whenWidget({
    required Widget Function(T data) data,
    Widget Function()? loading,
    Widget Function(Object error, StackTrace? stackTrace)? error,
  }) {
    return when(
      data: data,
      loading:
          loading ?? () => const Center(child: CircularProgressIndicator()),
      error:
          error ??
          (err, st) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                err.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
    );
  }
}

/// Show a SnackBar on async error. Wire this into ref.listen() in screens
/// that perform mutations:
///
/// ```dart
/// ref.listen(authControllerProvider, (_, next) {
///   next.showSnackBarOnError(context);
/// });
/// ```
extension AsyncValueListenerX<T> on AsyncValue<T> {
  void showSnackBarOnError(BuildContext context) {
    if (!hasError || isLoading) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
