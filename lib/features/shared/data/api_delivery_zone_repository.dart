import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_zone.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/delivery_zone_repository.dart';

class ApiDeliveryZoneRepository implements DeliveryZoneRepository {
  final ApiClient _apiClient;

  ApiDeliveryZoneRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (apiEx.code == 'DELIVERY_ZONE_NOT_FOUND' ||
            e.response?.statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  List<DeliveryZone> _mapList(dynamic data) {
    return (data as List)
        .map((e) => DeliveryZone.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Result<List<DeliveryZone>>> getPublicZones() async {
    try {
      final response = await _apiClient.dio.get('/delivery-zones');
      return Success(_mapList(response.data));
    } catch (e) {
      return Err(_handleError(e, 'Failed to load delivery zones'));
    }
  }

  @override
  Future<Result<List<DeliveryZone>>> getAdminZones() async {
    try {
      final response = await _apiClient.dio.get('/admin/delivery-zones');
      return Success(_mapList(response.data));
    } catch (e) {
      return Err(_handleError(e, 'Failed to load delivery zones'));
    }
  }

  @override
  Future<Result<DeliveryZone>> createZone({
    required String nameAr,
    required String nameEn,
    required double deliveryFee,
    required double minimumOrder,
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/admin/delivery-zones',
        data: {
          'nameAr': nameAr,
          'nameEn': nameEn,
          'deliveryFee': deliveryFee,
          'minimumOrder': minimumOrder,
          'isActive': isActive,
          'sortOrder': sortOrder,
        },
      );
      return Success(
        DeliveryZone.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to create delivery zone'));
    }
  }

  @override
  Future<Result<DeliveryZone>> updateZone(
    String id, {
    required String nameAr,
    required String nameEn,
    required double deliveryFee,
    required double minimumOrder,
    required bool isActive,
    required int sortOrder,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '/admin/delivery-zones/$id',
        data: {
          'nameAr': nameAr,
          'nameEn': nameEn,
          'deliveryFee': deliveryFee,
          'minimumOrder': minimumOrder,
          'isActive': isActive,
          'sortOrder': sortOrder,
        },
      );
      return Success(
        DeliveryZone.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to update delivery zone'));
    }
  }

  @override
  Future<Result<void>> deleteZone(String id) async {
    try {
      await _apiClient.dio.delete('/admin/delivery-zones/$id');
      return const Success(null);
    } catch (e) {
      return Err(_handleError(e, 'Failed to delete delivery zone'));
    }
  }
}
