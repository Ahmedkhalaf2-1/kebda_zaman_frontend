import 'failures.dart';

/// A simple Result type using a sealed class instead of dartz/fpdart.
/// Keeps the project lightweight while enforcing explicit error handling (§29).
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Err<T>;

  T get value => (this as Success<T>).data;
  Failure get failure => (this as Err<T>).error;

  /// Fold pattern — forces caller to handle both success and failure.
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success(data: final d) => onSuccess(d),
      Err(error: final e) => onFailure(e),
    };
  }

  /// Map the success value.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final d) => Success(transform(d)),
      Err(error: final e) => Err(e),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Err<T> extends Result<T> {
  final Failure error;
  const Err(this.error);
}
