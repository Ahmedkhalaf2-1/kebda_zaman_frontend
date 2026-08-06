import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/orders_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/loyalty_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:uuid/uuid.dart';

class CheckoutNotifier extends AutoDisposeAsyncNotifier<void> {
  String? _idempotencyKey;

  @override
  Future<void> build() async {
    _idempotencyKey = const Uuid().v4();
  }

  /// Refreshes the idempotency key (e.g. if the user changes cart or wants to start a completely new attempt intentionally)
  void refreshIdempotencyKey() {
    _idempotencyKey = const Uuid().v4();
  }

  Future<Order?> placeOrder({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(orderRepositoryProvider);

      final result = await repo.checkout(
        deliveryMethod: deliveryMethod,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        promoCode: promoCode,
        redeemRewardId: redeemRewardId,
        notes: notes,
        idempotencyKey: _idempotencyKey!,
      );

      return result.fold(
        (f) {
          state = AsyncError(f, StackTrace.current);
          // The promo was valid when the cart displayed it, but the backend
          // re-validates at checkout and may reject it there (e.g. the
          // per-user limit was hit by another concurrent request/device) —
          // refetch the server cart so the now-stale applied-promo/discount
          // shown on cart/checkout is cleared rather than left dangling.
          final cause = f.cause;
          if (cause is ApiException && cause.code == 'PROMO_ALREADY_USED') {
            ref.invalidate(cartProvider);
          }
          return null;
        },
        (order) async {
          // Clear cart ONLY after successful order creation — checkout clears it
          // server-side, so invalidating just refetches the now-empty cart.
          ref.invalidate(cartProvider);
          // New order should appear in "My Orders" without a manual pull-to-refresh.
          ref.invalidate(ordersProvider);
          // A redeemed loyalty reward spent points server-side inside the same
          // transaction as order creation — refresh the cached balance/history.
          if (order.loyaltyRedemption != null) {
            ref.invalidate(loyaltyProvider);
          }

          state = const AsyncData(null);
          return order;
        },
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final checkoutProvider =
    AutoDisposeAsyncNotifierProvider<CheckoutNotifier, void>(
      () => CheckoutNotifier(),
    );
