import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/payment.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/payment_repository.dart';

class ApiPaymentRepository implements PaymentRepository {
  final ApiClient _apiClient;

  ApiPaymentRepository(this._apiClient);

  /// Wraps [e] as a [PaymentFailure] carrying the original [ApiException]
  /// (with its `code`) as [Failure.cause], so callers can switch on
  /// `(failure.cause as ApiException?)?.code` for the specific error codes
  /// documented in the API contract (e.g. PAYMENT_VERIFICATION_FAILED,
  /// MOYASAR_UNAVAILABLE) rather than parsing the message string.
  static Failure _dioToFailure(DioException e, String fallbackMessage) {
    if (e.error is ApiException) {
      final apiEx = e.error as ApiException;
      return PaymentFailure(apiEx.message, apiEx);
    }
    return PaymentFailure(fallbackMessage, e);
  }

  @override
  Future<Result<PaymentIntent>> createIntent(String orderId) async {
    try {
      final response = await _apiClient.dio.post(
        '/payments/intent',
        data: {'orderId': orderId},
      );
      return Success(
        PaymentIntent.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Err(_dioToFailure(e, 'Failed to start payment'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error starting payment'));
    }
  }

  @override
  Future<Result<Payment>> confirmPayment({
    required String orderId,
    required String providerPaymentId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/payments/$orderId/confirm',
        data: {'providerPaymentId': providerPaymentId},
      );
      return Success(Payment.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(_dioToFailure(e, 'Failed to confirm payment'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error confirming payment'));
    }
  }

  @override
  Future<Result<Payment>> getPayment(String id) async {
    try {
      final response = await _apiClient.dio.get('/payments/$id');
      return Success(Payment.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(_dioToFailure(e, 'Failed to load payment'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading payment'));
    }
  }

  @override
  Future<Result<List<SavedCard>>> getSavedCards() async {
    try {
      final response = await _apiClient.dio.get('/payments/cards');
      final list = (response.data as List)
          .map((json) => SavedCard.fromJson(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Err(_dioToFailure(e, 'Failed to load saved cards'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading saved cards'));
    }
  }

  @override
  Future<Result<void>> deleteSavedCard(String cardId) async {
    try {
      await _apiClient.dio.delete('/payments/cards/$cardId');
      return const Success(null);
    } on DioException catch (e) {
      return Err(_dioToFailure(e, 'Failed to delete saved card'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error deleting saved card'));
    }
  }

  @override
  Future<Result<CardChargeResult>> chargeSavedCard({
    required String orderId,
    required String cardId,
    String? cvc,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/payments/$orderId/cards/$cardId/charge',
        data: {if (cvc != null && cvc.isNotEmpty) 'cvc': cvc},
      );
      return Success(
        CardChargeResult.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Err(_dioToFailure(e, 'Failed to charge saved card'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error charging saved card'));
    }
  }
}
