import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/kitchen_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

class ApiKitchenRepository implements KitchenRepository {
  final ApiClient _apiClient;

  ApiKitchenRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        return NetworkFailure((e.error as ApiException).message);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<List<KitchenOrder>>> getQueue() async {
    try {
      final response = await _apiClient.dio.get('/kitchen/orders');
      final list = (response.data as List)
          .map((json) => _mapKitchenOrder(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to load kitchen queue'));
    }
  }

  @override
  Future<Result<KitchenOrder>> getOrder(String id) async {
    try {
      final response = await _apiClient.dio.get('/kitchen/orders/$id');
      return Success(
        _mapKitchenOrder(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load order'));
    }
  }

  static OrderStatus _mapStatus(Object? value) => OrderStatus.values
      .firstWhere((s) => s.name == value, orElse: () => OrderStatus.unknown);

  /// Mirrors `ApiOrderRepository._mapFulfillmentType` — deliberately never
  /// defaults an unexpected value to [FulfillmentType.delivery], since that
  /// could silently misrepresent a pickup ticket to kitchen staff.
  static FulfillmentType _mapDeliveryMethod(Object? value) {
    switch (value) {
      case 'DELIVERY':
        return FulfillmentType.delivery;
      case 'PICKUP':
        return FulfillmentType.pickup;
      default:
        throw const FormatException('Unknown kitchen order delivery method');
    }
  }

  static KitchenOrder _mapKitchenOrder(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?) ?? const [];
    return KitchenOrder(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      status: _mapStatus(json['status']),
      deliveryMethod: _mapDeliveryMethod(json['deliveryMethod']),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      items: itemsList
          .map((i) => _mapKitchenOrderItem(i as Map<String, dynamic>))
          .toList(),
    );
  }

  static KitchenOrderItem _mapKitchenOrderItem(Map<String, dynamic> json) {
    final menuItem = json['menuItem'] as Map<String, dynamic>? ?? const {};
    final selectedVariant =
        json['selectedVariant'] as Map<String, dynamic>?;
    final selectedAddons = (json['selectedAddons'] as List?) ?? const [];
    return KitchenOrderItem(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String?,
      nameAr: menuItem['nameAr'] as String? ?? '',
      nameEn: menuItem['nameEn'] as String? ?? '',
      imageUrl: menuItem['imageUrl'] as String?,
      selectedVariant: selectedVariant == null
          ? null
          : _mapCustomizationSnapshot(selectedVariant),
      selectedAddons: selectedAddons
          .map(
            (a) => _mapCustomizationSnapshot(a as Map<String, dynamic>),
          )
          .toList(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      specialInstructions: json['specialInstructions'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static KitchenCustomizationSnapshot _mapCustomizationSnapshot(
    Map<String, dynamic> json,
  ) {
    return KitchenCustomizationSnapshot(
      id: json['id'] as String,
      refId: json['refId'] as String?,
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      priceSnapshot: (json['priceSnapshot'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
