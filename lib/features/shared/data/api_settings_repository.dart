import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/settings_repository.dart';

class ApiSettingsRepository implements SettingsRepository {
  final ApiClient _apiClient;

  ApiSettingsRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        return NetworkFailure((e.error as ApiException).message, e.error);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<RestaurantSettings>> getSettings() async {
    try {
      final response = await _apiClient.dio.get('/settings');
      return Success(
        RestaurantSettings.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load settings'));
    }
  }

  @override
  Future<Result<RestaurantSettings>> getAdminSettings() async {
    try {
      final response = await _apiClient.dio.get('/admin/settings');
      return Success(
        RestaurantSettings.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load settings'));
    }
  }

  @override
  Future<Result<void>> updateSettings(RestaurantSettings settings) async {
    try {
      await _apiClient.dio.put('/admin/settings', data: settings.toJson());
      return const Success(null);
    } catch (e) {
      return Err(_handleError(e, 'Failed to update settings'));
    }
  }
}
