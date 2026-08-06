import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_quote.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/delivery_quote_repository.dart';

class ApiDeliveryQuoteRepository implements DeliveryQuoteRepository {
  final ApiClient _apiClient;

  ApiDeliveryQuoteRepository(this._apiClient);

  @override
  Future<Result<DeliveryQuote>> getQuote({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/delivery/quote',
        data: {'latitude': latitude, 'longitude': longitude},
      );
      return Success(
        DeliveryQuote.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to calculate delivery fee'));
    } catch (e) {
      return const Err(
        UnknownFailure('Unknown error calculating delivery fee'),
      );
    }
  }
}
