import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/home_widget/home_widget_service.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/loyalty_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/orders_notifier.dart';

/// Keeps the Android home-screen widget in sync with the customer's active
/// orders and loyalty points for as long as the app process is alive.
/// Watched once from app.dart (same pattern as sessionLifecycleProvider) so
/// [ordersProvider]/[loyaltyProvider] stay alive and every state change is
/// forwarded to [HomeWidgetService] without any screen needing to know the
/// widget exists.
final homeWidgetSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<OrdersData>>(ordersProvider, (previous, next) {
    next.whenData(
      (data) => HomeWidgetService.instance.syncActiveOrders(data.activeOrders),
    );
  }, fireImmediately: true);

  ref.listen<AsyncValue<LoyaltyData>>(loyaltyProvider, (previous, next) {
    next.whenData(
      (data) =>
          HomeWidgetService.instance.syncLoyaltyPoints(data.account.pointsBalance),
    );
  }, fireImmediately: true);
});
