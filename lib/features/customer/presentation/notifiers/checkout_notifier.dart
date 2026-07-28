import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    String? deliveryZoneId,
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
        deliveryZoneId: deliveryZoneId,
        promoCode: promoCode,
        redeemRewardId: redeemRewardId,
        notes: notes,
        idempotencyKey: _idempotencyKey!,
      );

      return result.fold(
        (f) {
          state = AsyncError(f, StackTrace.current);
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
