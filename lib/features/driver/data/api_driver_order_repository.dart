import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/driver/domain/models/driver_order.dart';
import 'package:kebda_zaman/features/driver/domain/repositories/driver_order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

class ApiDriverOrderRepository implements DriverOrderRepository {
  final ApiClient _apiClient;

  ApiDriverOrderRepository(this._apiClient);

  /// Test-only seam onto the private mapping logic used by every endpoint on
  /// this repository, exercised against synthetic fixtures shaped like
  /// `DriverOrderResponseDto` (DRIVER_DELIVERY_API_CONTRACT.md) rather than
  /// a live backend.
  @visibleForTesting
  static DriverOrder mapDriverOrderForTesting(Map<String, dynamic> json) =>
      _mapDriverOrder(json);

  /// A genuine 401 here is either an ordinary expired access token (handled
  /// transparently by [AuthInterceptor]'s refresh-and-retry before this ever
  /// surfaces) or `DRIVER_DEACTIVATED` (refresh deliberately skipped — see
  /// the interceptor). Either way this maps to [AuthFailure], the same
  /// convention [ApiAuthRepository] uses, so callers (driver notifiers) can
  /// react uniformly by ending the local session — see `driverAuthGuard`.
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
        if (statusCode == 422 || statusCode == 409) {
          return ValidationFailure(apiEx.message, apiEx);
        }
        if (statusCode == 429) {
          return ValidationFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  static OrderStatus _mapStatusName(Object? name) => OrderStatus.values
      .firstWhere((e) => e.name == name, orElse: () => OrderStatus.unknown);

  static FulfillmentType _mapFulfillmentType(Object? value) {
    switch (value) {
      case 'PICKUP':
        return FulfillmentType.pickup;
      default:
        // Every driver order is DELIVERY by contract — default rather than
        // throw so an unexpected value never crashes the list.
        return FulfillmentType.delivery;
    }
  }

  /// Same `OrderItemResponseDto` shape every order endpoint returns —
  /// mirrors `ApiOrderRepository._mapOrderItem` (kept as a separate small
  /// copy rather than a shared export, since it's a few lines and this
  /// repository has no other dependency on that file).
  static OrderItem _mapOrderItem(Map<String, dynamic> json) {
    final menuItem = json['menuItem'] ?? {};
    final selectedVariant = json['selectedVariant'] as Map<String, dynamic>?;
    final selectedAddons = (json['selectedAddons'] as List?) ?? const [];
    return OrderItem(
      menuItemId: json['menuItemId'] as String?,
      variantRefId: selectedVariant?['refId'] as String?,
      addonRefIds: selectedAddons
          .map((a) => (a as Map<String, dynamic>?)?['refId'] as String?)
          .whereType<String>()
          .toList(),
      name: menuItem['nameEn'] ?? menuItem['nameAr'] ?? 'Unknown',
      imageUrl: menuItem['imageUrl'] ?? '',
      basePrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      lineTotal: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      specialInstructions: json['specialInstructions'] ?? '',
    );
  }

  static DriverOrder _mapDriverOrder(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?) ?? const [];
    final deliveryAddressJson =
        json['deliveryAddress'] as Map<String, dynamic>?;
    return DriverOrder(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: _mapStatusName(json['status']),
      items: itemsList
          .map((i) => _mapOrderItem(i as Map<String, dynamic>))
          .toList(),
      deliveryAddress: deliveryAddressJson != null
          ? OrderDeliveryAddress.fromBackendJson(deliveryAddressJson)
          : null,
      deliveryMethod: _mapFulfillmentType(json['deliveryMethod']),
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] as String?,
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      amountToCollect: (json['amountToCollect'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      assignmentVersion: (json['assignmentVersion'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<Result<List<DriverOrder>>> getActiveOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/driver/orders',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = (response.data as List)
          .map((json) => _mapDriverOrder(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to load orders'));
    }
  }

  @override
  Future<Result<List<DriverOrder>>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/driver/orders/history',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = (response.data as List)
          .map((json) => _mapDriverOrder(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to load delivery history'));
    }
  }

  @override
  Future<Result<DriverOrder>> getOrderById(String id) async {
    try {
      final response = await _apiClient.dio.get('/driver/orders/$id');
      return Success(_mapDriverOrder(response.data as Map<String, dynamic>));
    } catch (e) {
      return Err(_handleError(e, 'Failed to load order'));
    }
  }

  @override
  Future<Result<DriverOrder>> pickup(String id) async {
    try {
      final response = await _apiClient.dio.patch('/driver/orders/$id/pickup');
      return Success(_mapDriverOrder(response.data as Map<String, dynamic>));
    } catch (e) {
      return Err(_handleError(e, 'Failed to start delivery'));
    }
  }

  @override
  Future<Result<DriverOrder>> delivered(String id) async {
    try {
      final response = await _apiClient.dio.patch(
        '/driver/orders/$id/delivered',
      );
      return Success(_mapDriverOrder(response.data as Map<String, dynamic>));
    } catch (e) {
      return Err(_handleError(e, 'Failed to mark as delivered'));
    }
  }

  @override
  Future<Result<LocationUploadAck>> uploadLocation(
    String orderId, {
    required double latitude,
    required double longitude,
    required DateTime capturedAt,
    required int assignmentVersion,
    double? accuracyMeters,
    double? headingDegrees,
    double? speedMps,
  }) async {
    try {
      final body = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        // Always sent in UTC: the backend compares this against its own
        // clock (`LOCATION_TOO_OLD`/`LOCATION_TIMESTAMP_IN_FUTURE`), so a
        // local-time string here would corrupt that comparison by the
        // device's UTC offset.
        'capturedAt': capturedAt.toUtc().toIso8601String(),
        'assignmentVersion': assignmentVersion,
        // Each optional sensor value is validated against the contract's
        // own accepted range and simply omitted (never sent as a sentinel
        // like -1) when unavailable or out of range — an out-of-range
        // value would otherwise fail the backend's own validation and
        // reject the whole sample over a field that isn't even required.
        if (accuracyMeters != null &&
            accuracyMeters.isFinite &&
            accuracyMeters >= 0 &&
            accuracyMeters <= 10000)
          'accuracyMeters': accuracyMeters,
        if (headingDegrees != null &&
            headingDegrees.isFinite &&
            headingDegrees >= 0 &&
            headingDegrees < 360)
          'headingDegrees': headingDegrees,
        if (speedMps != null &&
            speedMps.isFinite &&
            speedMps >= 0 &&
            speedMps <= 100)
          'speedMps': speedMps,
      };
      final response = await _apiClient.dio.put(
        '/driver/orders/$orderId/location',
        data: body,
      );
      final data = response.data as Map<String, dynamic>;
      return Success(
        LocationUploadAck(
          accepted: data['accepted'] as bool? ?? false,
          assignmentVersion: (data['assignmentVersion'] as num).toInt(),
          receivedAt: DateTime.parse(data['receivedAt'] as String).toLocal(),
        ),
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429) {
        final retryAfterHeader = e.response?.headers.value('retry-after');
        return Err(
          RateLimitedFailure(
            (e.error is ApiException)
                ? (e.error as ApiException).message
                : 'Too many location updates — slowing down.',
            e.error is ApiException ? e.error as ApiException : null,
            retryAfterHeader != null ? int.tryParse(retryAfterHeader) : null,
          ),
        );
      }
      return Err(_handleError(e, 'Failed to upload location'));
    }
  }
}
