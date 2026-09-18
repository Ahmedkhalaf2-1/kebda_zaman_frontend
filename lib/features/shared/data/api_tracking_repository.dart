import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order_tracking.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/tracking_repository.dart';

class ApiTrackingRepository implements TrackingRepository {
  final ApiClient _apiClient;

  ApiTrackingRepository(this._apiClient);

  /// Test-only seam onto the private mapping logic, exercised against
  /// synthetic fixtures shaped like `OrderTrackingResponseDto`
  /// (DRIVER_DELIVERY_API_CONTRACT.md Phase 2) rather than a live backend.
  @visibleForTesting
  static OrderTracking mapTrackingForTesting(
    String orderId,
    Map<String, dynamic> json,
  ) => _mapTracking(orderId, json);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (statusCode == 401) {
          return AuthFailure(apiEx.message, apiEx);
        }
        if (statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  static OrderTracking _mapTracking(String orderId, Map<String, dynamic> json) {
    final locationJson = json['location'] as Map<String, dynamic>?;
    return OrderTracking(
      orderId: json['orderId'] as String? ?? orderId,
      state: trackingStateFromWire(json['state'] as String?),
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      location: locationJson == null
          ? null
          : TrackingLocationSample(
              latitude: (locationJson['latitude'] as num).toDouble(),
              longitude: (locationJson['longitude'] as num).toDouble(),
              accuracyMeters: (locationJson['accuracyMeters'] as num?)
                  ?.toDouble(),
              headingDegrees: (locationJson['headingDegrees'] as num?)
                  ?.toDouble(),
              speedMps: (locationJson['speedMps'] as num?)?.toDouble(),
              capturedAt: DateTime.parse(
                locationJson['capturedAt'] as String,
              ).toLocal(),
              receivedAt: DateTime.parse(
                locationJson['receivedAt'] as String,
              ).toLocal(),
            ),
      locationAgeSeconds: (json['locationAgeSeconds'] as num?)?.toInt(),
    );
  }

  @override
  Future<Result<OrderTracking>> getCustomerTracking(String orderId) async {
    try {
      final response = await _apiClient.dio.get('/orders/$orderId/tracking');
      return Success(
        _mapTracking(orderId, response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load driver location'));
    }
  }

  @override
  Future<Result<OrderTracking>> getAdminTracking(String orderId) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/orders/$orderId/tracking',
      );
      return Success(
        _mapTracking(orderId, response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load driver location'));
    }
  }
}
