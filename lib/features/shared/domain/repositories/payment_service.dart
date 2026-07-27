import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/payment.dart';

/// Payment service interface per md1 §22.
abstract class PaymentService {
  Future<Result<Payment>> initiatePayment({
    required Order order,
    required PaymentMethod method,
  });
  Future<Result<Payment>> confirmPayment(String paymentId);
  Future<Result<void>> cancelPayment(String paymentId);
  Future<Result<PaymentStatus>> verifyPayment(String paymentId);
}
