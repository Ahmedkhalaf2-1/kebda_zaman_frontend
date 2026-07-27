/// Sealed failure type per md1 §29.
/// All repository methods return Either<Failure, T> instead of throwing.
sealed class Failure {
  final String message;
  final Object? cause;
  const Failure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error', super.cause]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error', super.cause]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found', super.cause]);
}

class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Payment error', super.cause]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error', super.cause]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error', super.cause]);
}
