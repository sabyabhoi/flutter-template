import 'package:app/src/core/error/failure.dart';
import 'package:meta/meta.dart';

/// Lightweight `Either`-style result used by repositories.
///
/// We deliberately avoid pulling in `dartz`/`fpdart` — Dart 3's pattern
/// matching makes a sealed class ergonomic enough on its own:
///
/// ```dart
/// final result = await repo.signIn(email, password);
/// switch (result) {
///   case Ok(:final value): // value is the success type
///   case Err(:final failure): // failure is a Failure
/// }
/// ```
@immutable
sealed class Result<T> {
  const Result();

  /// Constructs a successful result.
  const factory Result.ok(T value) = Ok<T>;

  /// Constructs a failed result.
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Returns the success value or `null`.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// Returns the failure or `null`.
  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  /// Maps the success value, leaving failures untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Result.ok(transform(value)),
    Err<T>(:final failure) => Result.err(failure),
  };

  /// Folds both arms into a single value.
  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) => switch (this) {
    Ok<T>(:final value) => ok(value),
    Err<T>(:final failure) => err(failure),
  };
}

@immutable
final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

@immutable
final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Err<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Err($failure)';
}
