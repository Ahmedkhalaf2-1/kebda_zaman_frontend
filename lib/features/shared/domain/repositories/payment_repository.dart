import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/payment.dart';

/// Real Moyasar-backed payment repository. Every method here is a thin
/// pass-through to the backend, which is the only source of truth for
/// payment/order status — nothing here ever marks a payment as final
/// locally; [confirmPayment] is what persists the backend's own
/// independently-re-verified result.
abstract class PaymentRepository {
  Future<Result<PaymentIntent>> createIntent(String orderId);

  Future<Result<Payment>> confirmPayment({
    required String orderId,
    required String providerPaymentId,
  });

  Future<Result<Payment>> getPayment(String id);

  Future<Result<List<SavedCard>>> getSavedCards();

  Future<Result<void>> deleteSavedCard(String cardId);

  Future<Result<CardChargeResult>> chargeSavedCard({
    required String orderId,
    required String cardId,
    String? cvc,
  });
}
