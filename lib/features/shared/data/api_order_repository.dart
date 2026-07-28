import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';

class ApiOrderRepository implements OrderRepository {
  final ApiClient _apiClient;

  ApiOrderRepository(this._apiClient);

  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.dio.get(
        '/orders',
        queryParameters: queryParams,
      );
      final List data = response.data;
      return Success(data.map((json) => _mapOrder(json)).toList());
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load orders'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading orders'));
    }
  }

  @override
  Future<Result<Order>> getOrderById(String id) async {
    try {
      final response = await _apiClient.dio.get('/orders/$id');
      return Success(_mapOrder(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load order'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading order'));
    }
  }

  @override
  Future<Result<Order>> checkout({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
    required String idempotencyKey,
  }) async {
    try {
      final payload = <String, dynamic>{
        'deliveryMethod': deliveryMethod == FulfillmentType.delivery
            ? 'DELIVERY'
            : 'PICKUP',
        'paymentMethod': paymentMethod, // 'CASH', 'CARD', 'WALLET'
      };

      if (deliveryMethod == FulfillmentType.delivery &&
          deliveryAddress != null) {
        payload['deliveryAddress'] = deliveryAddress;
      }
      // promoCode and redeemRewardId are mutually exclusive server-side
      // (422 PROMO_AND_LOYALTY_MUTUALLY_EXCLUSIVE if both are sent) — the
      // checkout UI never selects both at once, so at most one is ever set here.
      if (redeemRewardId != null && redeemRewardId.isNotEmpty) {
        payload['redeemRewardId'] = redeemRewardId;
      } else if (promoCode != null && promoCode.isNotEmpty) {
        payload['promoCode'] = promoCode;
      }
      if (notes != null && notes.isNotEmpty) {
        payload['notes'] = notes;
      }

      final response = await _apiClient.dio.post(
        '/checkout',
        data: payload,
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );

      return Success(_mapOrder(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to checkout'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error during checkout'));
    }
  }

  @override
  Future<Result<Order>> createOrder(Order order) async {
    // Only used by mock/admin flows currently, not used in Phase 5 customer checkout.
    throw UnimplementedError('Use checkout() for customer order creation.');
  }

  @override
  @override
  Stream<Order> watchOrder(String id) async* {
    Order? currentOrder;
    try {
      final orderResult = await getOrderById(id);
      currentOrder = orderResult.fold((f) => null, (o) => o);
    } catch (_) {}

    if (currentOrder != null) {
      yield currentOrder;
    }

    while (currentOrder != null) {
      if (currentOrder.status == OrderStatus.delivered ||
          currentOrder.status == OrderStatus.cancelled) {
        break; // Terminal state, stop polling
      }

      await Future.delayed(const Duration(seconds: 10));
      try {
        final response = await _apiClient.dio.get('/orders/$id/status');
        final data = response.data;

        final statusStr = data['status'] as String? ?? 'pending';
        final status = OrderStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => OrderStatus.unknown,
        );

        final statusHistoryList = (data['statusHistory'] as List?) ?? [];
        final statusHistory = statusHistoryList.map((item) {
          final itemStatus = OrderStatus.values.firstWhere(
            (e) => e.name == item['status'],
            orElse: () => OrderStatus.unknown,
          );
          return OrderStatusEntry(
            status: itemStatus,
            timestamp: item['changedAt'] != null
                ? DateTime.parse(item['changedAt']).toLocal()
                : DateTime.now(),
          );
        }).toList();

        currentOrder = currentOrder.copyWith(
          status: status,
          statusHistory: statusHistory,
          estimatedTime: data['estimatedDeliveryTime']?.toString(),
        );
        yield currentOrder;
      } on DioException catch (e) {
        if (e.error is ApiException) {
          yield* Stream.error(
            NetworkFailure((e.error as ApiException).message, e.error as ApiException),
          );
        } else {
          yield* Stream.error(const NetworkFailure('Network error'));
        }
      } catch (e) {
        yield* Stream.error(UnknownFailure(e.toString()));
        break;
      }
    }
  }

  @override
  Future<Result<List<Order>>> getAllOrders() async {
    try {
      final response = await _apiClient.dio.get('/admin/orders');
      final list = (response.data as List)
          .map((json) => _mapOrder(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load admin orders'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading admin orders'));
    }
  }

  @override
  Future<Result<Order>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '/admin/orders/$orderId/status',
        data: {'status': status.name},
      );
      return Success(_mapOrder(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to update order status'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error updating order status'));
    }
  }

  Order _mapOrder(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final status = OrderStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => OrderStatus.unknown,
    );

    final itemsList = (json['items'] as List?) ?? [];

    final loyaltyRedemptionJson =
        json['loyaltyRedemption'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;

    return Order(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      userId: json['userId'] ?? userJson?['id'] ?? '',
      customerName: userJson?['name'] as String?,
      items: itemsList.map((i) => _mapOrderItem(i)).toList(),
      fulfillmentType: json['deliveryMethod'] == 'PICKUP'
          ? FulfillmentType.pickup
          : FulfillmentType.delivery,
      status: status,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (json['discount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'], // Order model has paymentStatus.
      placedAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      loyaltyRedemption: loyaltyRedemptionJson != null
          ? LoyaltyRedemptionInfo(
              rewardId: loyaltyRedemptionJson['rewardId'] ?? '',
              rewardName: loyaltyRedemptionJson['rewardName'] ?? '',
              pointsRedeemed:
                  (loyaltyRedemptionJson['pointsRedeemed'] as num?)?.toInt() ??
                  0,
            )
          : null,
      statusHistory:
          [], // If we got status history from /orders/:id/status, it would go here. But /orders/:id doesn't return history.
      estimatedTime: json['estimatedDeliveryTime'],
    );
  }

  OrderItem _mapOrderItem(Map<String, dynamic> json) {
    final menuItem = json['menuItem'] ?? {};
    return OrderItem(
      menuItemId: json['id'] ?? '',
      name: menuItem['nameEn'] ?? menuItem['nameAr'] ?? 'Unknown',
      imageUrl: menuItem['imageUrl'] ?? '',
      basePrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      lineTotal: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      specialInstructions: json['specialInstructions'] ?? '',
    );
  }
}
