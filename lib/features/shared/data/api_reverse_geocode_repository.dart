import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/reverse_geocode_result.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/reverse_geocode_repository.dart';

/// Real API repository for backend-brokered Google reverse geocoding
/// (/locations/reverse-geocode). Keeps the Google API key server-side.
class ApiReverseGeocodeRepository implements ReverseGeocodeRepository {
  final ApiClient _apiClient;

  ApiReverseGeocodeRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMessage) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        return ValidationFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMessage);
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<ReverseGeocodeResult>> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/locations/reverse-geocode',
        data: {'latitude': latitude, 'longitude': longitude},
      );
      return Success(
        ReverseGeocodeResult.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to reverse geocode location'));
    }
  }
}
