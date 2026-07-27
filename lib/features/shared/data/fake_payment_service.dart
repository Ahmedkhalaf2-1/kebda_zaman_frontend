import 'dart:math';

import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/payment.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/payment_service.dart';

/// Mock payment service per md1 §22.
class FakePaymentService implements PaymentService {
  final _random = Random();
  final double failureRate;
  final Map<String, Payment> _payments = {};

  FakePaymentService({this.failureRate = 0.0});

  Future<void> _simulateDelay() async {
    final ms = 500 + _random.nextInt(1500);
    await Future.delayed(Duration(milliseconds: ms));
  }

  @override
  Future<Result<Payment>> initiatePayment({
    required Order order,
    required PaymentMethod method,
  }) async {
    await _simulateDelay();
    final payment = Payment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      method: method,
      amount: order.grandTotal,
      status: PaymentStatus.pending,
      provider: PaymentProvider.mock,
      transactionRef:
          'MOCK_${_random.nextInt(999999).toString().padLeft(6, '0')}',
      createdAt: DateTime.now(),
    );
    _payments[payment.id] = payment;
    return Success(payment);
  }

  @override
  Future<Result<Payment>> confirmPayment(String paymentId) async {
    await _simulateDelay();
    final payment = _payments[paymentId];
    if (payment == null) {
      return Err(NotFoundFailure('Payment $paymentId not found'));
    }
    if (_random.nextDouble() < failureRate) {
      final failed = payment.copyWith(
        status: PaymentStatus.failed,
        updatedAt: DateTime.now(),
      );
      _payments[paymentId] = failed;
      return const Err(PaymentFailure('Payment failed (simulated)'));
    }
    final confirmed = payment.copyWith(
      status: PaymentStatus.success,
      updatedAt: DateTime.now(),
    );
    _payments[paymentId] = confirmed;
    return Success(confirmed);
  }

  @override
  Future<Result<void>> cancelPayment(String paymentId) async {
    await _simulateDelay();
    final payment = _payments[paymentId];
    if (payment == null) {
      return Err(NotFoundFailure('Payment $paymentId not found'));
    }
    _payments[paymentId] = payment.copyWith(
      status: PaymentStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    return const Success(null);
  }

  @override
  Future<Result<PaymentStatus>> verifyPayment(String paymentId) async {
    await _simulateDelay();
    final payment = _payments[paymentId];
    if (payment == null) {
      return Err(NotFoundFailure('Payment $paymentId not found'));
    }
    return Success(payment.status);
  }
}
