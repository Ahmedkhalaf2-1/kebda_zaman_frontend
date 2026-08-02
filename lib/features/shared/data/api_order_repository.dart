import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';

/// Injectable delay seam for [ApiOrderRepository]'s polling/retry loop, so
/// tests can run the real retry/backoff control flow without waiting on
/// real multi-second [Future.delayed] calls.
typedef OrderPollDelayFn = Future<void> Function(Duration duration);

class ApiOrderRepository implements OrderRepository {
  final ApiClient _apiClient;
  final OrderPollDelayFn _delay;

  /// The [delay] parameter is a test-only seam (Fix 14): production code
  /// never passes it and always gets the default [Future.delayed]. It is
  /// never wired to any UI/env configuration.
  ApiOrderRepository(this._apiClient, {OrderPollDelayFn? delay})
    : _delay = delay ?? Future.delayed;

  /// Test-only seam onto the private order-mapping logic used by every
  /// endpoint in this repository (customer list/detail, checkout, admin
  /// list/status-update). Avoids duplicating the mapping rules in tests.
  @visibleForTesting
  static Order mapOrderForTesting(Map<String, dynamic> json) => _mapOrder(json);

  /// Test-only seam onto the transient/permanent failure classification
  /// used by [watchOrder]'s retry policy (Fix 14).
  @visibleForTesting
  static bool isTransientDioErrorForTesting(DioException e) =>
      _isTransientDioError(e);

  /// Test-only seam onto the bounded-backoff delay curve used between
  /// consecutive transient failures within a single fetch/poll attempt
  /// (Fix 14): 2s -> 4s -> 8s -> 8s -> 8s (capped).
  @visibleForTesting
  static Duration retryDelayForTesting(int consecutiveFailures) =>
      _retryDelayFor(consecutiveFailures);

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
    String? deliveryZoneId,
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
      // Required for DELIVERY, ignored (and never sent) for PICKUP — the
      // backend re-reads the zone fresh from the DB; there is nowhere to put
      // a client-supplied fee (CheckoutDto has no such field at all).
      if (deliveryMethod == FulfillmentType.delivery &&
          deliveryZoneId != null &&
          deliveryZoneId.isNotEmpty) {
        payload['deliveryZoneId'] = deliveryZoneId;
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

  // ---------------------------------------------------------------------
  // Fix 14: resilient order-tracking polling.
  //
  // Production timing (kept private/named per Fix 14 — never configurable
  // through UI or environment files):
  //   - normal poll interval:            10s
  //   - retry after 1st transient fail:   2s
  //   - retry after 2nd transient fail:   4s
  //   - retry after 3rd+ transient fail:  8s (capped)
  //   - max consecutive transient fails:  5 (then surface one failure)
  // ---------------------------------------------------------------------
  static const Duration _pollInterval = Duration(seconds: 10);
  static const List<Duration> _retryDelays = [
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
  ];
  static const int _maxConsecutiveFailures = 5;

  static const Set<int> _transientStatusCodes = {500, 502, 503, 504};

  /// Bounded exponential backoff curve, capped at the last entry of
  /// [_retryDelays]: 2s -> 4s -> 8s -> 8s -> 8s -> ...
  static Duration _retryDelayFor(int consecutiveFailures) {
    final idx = (consecutiveFailures - 1).clamp(0, _retryDelays.length - 1);
    return _retryDelays[idx];
  }

  /// Classifies a [DioException] as transient/retryable vs.
  /// permanent/non-retryable, per Fix 14's failure classification.
  ///
  /// Transient: connection/send/receive timeouts, connection errors, and
  /// temporary 5xx (500/502/503/504) — including when the auth/retry
  /// interceptors have already wrapped the error in an [ApiException]
  /// (e.g. the OFFLINE 503 produced by [RetryInterceptor]).
  ///
  /// Permanent (never retried): 400/401/403/404/409/422 and anything else
  /// not explicitly recognized as transient — including malformed payloads,
  /// which are never DioExceptions and so never reach this classifier.
  static bool _isTransientDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        break;
    }

    int? statusCode = e.response?.statusCode;
    if (statusCode == null && e.error is ApiException) {
      statusCode = (e.error as ApiException).statusCode;
    }
    return statusCode != null && _transientStatusCodes.contains(statusCode);
  }

  static Failure _dioToFailure(DioException e, String fallbackMessage) {
    if (e.error is ApiException) {
      final apiEx = e.error as ApiException;
      return NetworkFailure(apiEx.message, apiEx);
    }
    return NetworkFailure(fallbackMessage, e);
  }

  /// Raw (unwrapped) `GET /orders/:id` fetch used by [watchOrder]'s retry
  /// loop — reuses the exact same strict [_mapOrder] logic as every other
  /// endpoint, but lets the original [DioException]/mapping exception
  /// propagate so the caller can classify and retry it, instead of folding
  /// it into a [Result] (which would make transient/permanent
  /// classification impossible).
  Future<Order> _fetchOrderRaw(String id) async {
    final response = await _apiClient.dio.get('/orders/$id');
    return _mapOrder(response.data as Map<String, dynamic>);
  }

  /// Raw `GET /orders/:id/status` poll fetch, merged onto [base] using the
  /// same strict status-poll mapper as before.
  Future<Order> _fetchStatusPollRaw(String id, Order base) async {
    final response = await _apiClient.dio.get('/orders/$id/status');
    final data = response.data as Map<String, dynamic>;
    final polled = _mapStatusPollResponse(data);
    return base.copyWith(
      status: polled.status,
      statusHistory: polled.statusHistory,
      estimatedTime: data['estimatedDeliveryTime']?.toString(),
    );
  }

  /// Runs [fetch] with the Fix 14 bounded-backoff retry policy:
  ///   - transient [DioException]s are retried with [_retryDelayFor]
  ///     backoff, up to [_maxConsecutiveFailures] consecutive failures,
  ///     after which one meaningful [NetworkFailure] is returned;
  ///   - permanent [DioException]s (4xx, unrecognized) are returned
  ///     immediately, never retried;
  ///   - any other exception (malformed payload / mapping failure) is
  ///     treated as a permanent failure immediately, never retried as if
  ///     it were a network interruption.
  ///
  /// Never leaves overlapping requests in flight: each attempt is awaited
  /// sequentially before the next one starts.
  Future<({Order? order, Failure? failure})> _fetchWithRetry(
    Future<Order> Function() fetch,
  ) async {
    int consecutiveFailures = 0;
    while (true) {
      try {
        final order = await fetch();
        return (order: order, failure: null);
      } on DioException catch (e) {
        if (!_isTransientDioError(e)) {
          return (order: null, failure: _dioToFailure(e, 'Network error'));
        }
        consecutiveFailures++;
        if (consecutiveFailures >= _maxConsecutiveFailures) {
          return (
            order: null,
            failure: NetworkFailure(
              'Unable to reach the server after multiple attempts.',
              e.error is ApiException ? e.error as ApiException : e,
            ),
          );
        }
        await _delay(_retryDelayFor(consecutiveFailures));
      } catch (e) {
        return (order: null, failure: UnknownFailure(e.toString()));
      }
    }
  }

  /// True when any tracking-relevant field changed, so [watchOrder] never
  /// emits a duplicate/unchanged order to subscribers.
  ///
  /// [statusHistory] is deliberately compared element-by-element rather
  /// than with plain `!=` — two freshly-mapped, logically-identical (e.g.
  /// both empty) lists are always different object instances, so a plain
  /// `List` `!=` would treat every unchanged poll as "changed".
  static bool _hasTrackingChange(Order previous, Order updated) {
    return previous.status != updated.status ||
        previous.estimatedTime != updated.estimatedTime ||
        !_statusHistoryEquals(previous.statusHistory, updated.statusHistory);
  }

  static bool _statusHistoryEquals(
    List<OrderStatusEntry> a,
    List<OrderStatusEntry> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Stream<Order> watchOrder(String id) async* {
    // ---- Initial load: retry transient failures, surface permanent ones ----
    final initialOutcome = await _fetchWithRetry(() => _fetchOrderRaw(id));
    if (initialOutcome.failure != null) {
      // Exactly one stream error, then terminate — no silent empty stream.
      throw initialOutcome.failure!;
    }

    Order currentOrder = initialOutcome.order!;
    yield currentOrder;

    if (currentOrder.status.isTerminal) {
      // Already terminal (delivered/pickedUp/cancelled) — emit once, never
      // call the status polling endpoint.
      return;
    }

    // ---- Poll loop: sequential await, never overlapping requests ----
    while (true) {
      await _delay(_pollInterval);

      final order = currentOrder;
      final pollOutcome = await _fetchWithRetry(
        () => _fetchStatusPollRaw(id, order),
      );
      if (pollOutcome.failure != null) {
        // Permanent failure, or transient retries exhausted — exactly one
        // stream error, then terminate. The last successfully-emitted
        // order is never overwritten with an error state.
        throw pollOutcome.failure!;
      }

      final updated = pollOutcome.order!;
      final changed = _hasTrackingChange(currentOrder, updated);
      currentOrder = updated;
      if (changed) {
        yield currentOrder;
      }

      if (currentOrder.status.isTerminal) {
        // Transitioned to terminal — already emitted above (status always
        // changes when becoming terminal), stop without another delay.
        return;
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

  /// Maps the backend `deliveryMethod` wire value ('DELIVERY' | 'PICKUP').
  ///
  /// Deliberately does NOT default missing/malformed/unknown values to
  /// [FulfillmentType.delivery] — silently doing so could misrepresent a
  /// pickup order or hide an API-contract regression. Any unexpected value
  /// is surfaced as an error instead.
  static FulfillmentType _mapFulfillmentType(Object? value) {
    switch (value) {
      case 'DELIVERY':
        return FulfillmentType.delivery;
      case 'PICKUP':
        return FulfillmentType.pickup;
      default:
        throw const FormatException('Unknown order delivery method');
    }
  }

  static const _validPaymentStatuses = {
    'PENDING',
    'PAID',
    'FAILED',
    'REFUNDED',
  };

  /// Maps the backend `paymentStatus` wire value. The wire format
  /// ('PENDING' | 'PAID' | 'FAILED' | 'REFUNDED') is preserved as-is: the
  /// only current UI call site (admin order details) just interpolates the
  /// raw value for display, so there is no lowercase/enum expectation to
  /// satisfy — but a missing or unrecognized value from a live API response
  /// is rejected rather than silently passed through, since no legacy/mock
  /// path currently feeds JSON through this repository's mapper.
  static String _mapPaymentStatus(Object? value) {
    if (value is String && _validPaymentStatuses.contains(value)) {
      return value;
    }
    throw const FormatException('Unknown order payment status');
  }

  /// Test-only seam onto the lighter-weight status-polling mapper used by
  /// `GET /orders/:id/status` (via [watchOrder]) — separate from the full
  /// [_mapOrder] used by every other endpoint, since the status endpoint
  /// only ever returns a status + statusHistory, not a full order payload.
  @visibleForTesting
  static ({OrderStatus status, List<OrderStatusEntry> statusHistory})
  mapStatusPollResponseForTesting(Map<String, dynamic> data) =>
      _mapStatusPollResponse(data);

  static OrderStatus _mapStatusName(Object? name) => OrderStatus.values
      .firstWhere((e) => e.name == name, orElse: () => OrderStatus.unknown);

  static ({OrderStatus status, List<OrderStatusEntry> statusHistory})
  _mapStatusPollResponse(Map<String, dynamic> data) {
    final status = _mapStatusName(data['status'] as String? ?? 'pending');

    final statusHistoryList = (data['statusHistory'] as List?) ?? [];
    final statusHistory = statusHistoryList.map((item) {
      final itemStatus = _mapStatusName(item['status']);
      return OrderStatusEntry(
        status: itemStatus,
        timestamp: item['changedAt'] != null
            ? DateTime.parse(item['changedAt']).toLocal()
            : DateTime.now(),
      );
    }).toList();

    return (status: status, statusHistory: statusHistory);
  }

  static Order _mapOrder(Map<String, dynamic> json) {
    final status = _mapStatusName(json['status'] as String? ?? 'pending');

    final itemsList = (json['items'] as List?) ?? [];

    final loyaltyRedemptionJson =
        json['loyaltyRedemption'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;
    final deliveryAddressJson =
        json['deliveryAddress'] as Map<String, dynamic>?;

    return Order(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      userId: json['userId'] ?? userJson?['id'] ?? '',
      customerName: userJson?['name'] as String?,
      items: itemsList.map((i) => _mapOrderItem(i)).toList(),
      fulfillmentType: _mapFulfillmentType(json['deliveryMethod']),
      deliveryAddress: deliveryAddressJson != null
          ? OrderDeliveryAddress.fromBackendJson(deliveryAddressJson)
          : null,
      status: status,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (json['discount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: _mapPaymentStatus(json['paymentStatus']),
      paymentMethod: json['paymentMethod'],
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

  static OrderItem _mapOrderItem(Map<String, dynamic> json) {
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
