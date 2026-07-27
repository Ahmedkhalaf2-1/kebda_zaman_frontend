import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/settings_repository.dart';

class ApiSettingsRepository implements SettingsRepository {
  final ApiClient _apiClient;

  ApiSettingsRepository(this._apiClient);

  @override
  Future<Result<RestaurantSettings>> getSettings() async {
    try {
      final response = await _apiClient.dio.get('/settings');
      return Success(_mapSettings(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load settings'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading settings'));
    }
  }

  @override
  Future<Result<RestaurantSettings>> getAdminSettings() async {
    try {
      final response = await _apiClient.dio.get('/admin/settings');
      return Success(_mapSettings(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load settings'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading settings'));
    }
  }

  @override
  Future<Result<void>> updateSettings(RestaurantSettings settings) async {
    try {
      final payload = <String, dynamic>{
        'restaurantName': settings.name,
        'phone': settings.phone,
        'addressText': settings.address.isNotEmpty
            ? settings.address
            : 'Cairo, Egypt',
        'taxRatePercent': settings.taxRatePercent,
        'deliveryFee': settings.deliveryFee,
        'minOrderAmount': settings.minOrderValue,
        'currency': settings.currency,
        'workingHours': {
          'open': settings.workingHoursOpen,
          'close': settings.workingHoursClose,
        },
        'isMaintenanceMode': !settings.isOpen,
      };
      await _apiClient.dio.put('/admin/settings', data: payload);
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to update settings'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error updating settings'));
    }
  }

  RestaurantSettings _mapSettings(Map<String, dynamic> json) {
    final workingHours = json['workingHours'] as Map<String, dynamic>?;
    return RestaurantSettings(
      name: json['restaurantName'] ?? json['name'] ?? 'Kebda Zaman',
      logoUrl: json['logoUrl'] ?? '',
      address: json['addressText'] ?? json['address'] ?? '',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 15.0,
      minOrderValue:
          (json['minOrderAmount'] as num?)?.toDouble() ??
          (json['minOrderValue'] as num?)?.toDouble() ??
          50.0,
      isOpen: json['isOpen'] ?? !(json['isMaintenanceMode'] ?? false),
      phone: json['phone'] ?? '01000000000',
      taxRatePercent: (json['taxRatePercent'] as num?)?.toDouble() ?? 14.0,
      currency: json['currency'] ?? 'EGP',
      workingHoursOpen: workingHours?['open'] ?? '09:00',
      workingHoursClose: workingHours?['close'] ?? '23:00',
    );
  }
}
