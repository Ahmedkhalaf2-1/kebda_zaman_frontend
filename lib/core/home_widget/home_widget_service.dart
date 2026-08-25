import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kebda_zaman/core/widgets/kz_order_status.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Bridges live order status and loyalty points into the Android home-screen
/// widget (`KebdaHomeWidgetProvider` + `res/layout/kebda_widget.xml`).
///
/// Android-only for now: `HomeWidget.updateWidget` is a no-op on platforms
/// without a registered provider, so every call here is safe to leave in
/// place if/when an iOS widget extension is added later — [_androidOnly]
/// just avoids paying the channel round-trip on other platforms today.
///
/// There is no background refresh: Android's widget update period floor is
/// 30 minutes, and this app has no push/background-fetch service. The
/// widget only reflects the last state observed while the app was in the
/// foreground (on launch, on the Orders list, and live every ~10s while
/// Order Tracking is open) — acceptable for v1, not real-time in the
/// background.
class HomeWidgetService {
  HomeWidgetService._();
  static final HomeWidgetService instance = HomeWidgetService._();

  static const _androidProviderName = 'KebdaHomeWidgetProvider';

  static const _keyMode = 'widget_mode';
  static const _keyOrderId = 'order_id';
  static const _keyOrderStatusLabel = 'order_status_label';
  static const _keyOrderEta = 'order_eta';
  static const _keyOrderProgress = 'order_progress';
  static const _keyOrderIsPickup = 'order_is_pickup';
  static const _keyLoyaltyPoints = 'loyalty_points';

  bool get _androidOnly => !kIsWeb && Platform.isAndroid;

  /// Call with the customer's active orders (non-terminal). Shows the most
  /// recently placed one; falls back to [syncNoActiveOrder] when empty.
  Future<void> syncActiveOrders(List<Order> activeOrders) async {
    if (!_androidOnly) return;
    if (activeOrders.isEmpty) {
      await syncNoActiveOrder();
      return;
    }
    final sorted = [...activeOrders]
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    await syncOrder(sorted.first);
  }

  /// Pushes a single order's live status into the widget (used both by the
  /// orders-list sync above and by Order Tracking's ~10s poll for a more
  /// real-time update while that screen is open).
  Future<void> syncOrder(Order order) async {
    if (!_androidOnly) return;
    final sequence = order.fulfillmentType.statusSequence;
    final stepIndex = sequence.indexOf(order.status);
    final progress = stepIndex < 0 ? 0 : stepIndex;
    final eta = order.estimatedTime?.trim() ?? '';

    await HomeWidget.saveWidgetData<String>(_keyMode, 'order');
    await HomeWidget.saveWidgetData<String>(_keyOrderId, order.id);
    await HomeWidget.saveWidgetData<String>(
      _keyOrderStatusLabel,
      orderStatusVisual(order.status).label,
    );
    await HomeWidget.saveWidgetData<String>(_keyOrderEta, eta);
    await HomeWidget.saveWidgetData<int>(_keyOrderProgress, progress);
    await HomeWidget.saveWidgetData<int>(
      _keyOrderIsPickup,
      order.fulfillmentType == FulfillmentType.pickup ? 1 : 0,
    );
    await _requestUpdate();
  }

  /// Switches the widget back to the loyalty-points face — no active order.
  Future<void> syncNoActiveOrder() async {
    if (!_androidOnly) return;
    await HomeWidget.saveWidgetData<String>(_keyMode, 'loyalty');
    await _requestUpdate();
  }

  Future<void> syncLoyaltyPoints(int points) async {
    if (!_androidOnly) return;
    await HomeWidget.saveWidgetData<int>(_keyLoyaltyPoints, points);
    await _requestUpdate();
  }

  Future<void> _requestUpdate() {
    return HomeWidget.updateWidget(androidName: _androidProviderName)
        .then((_) {})
        .catchError((_) {});
  }

  /// Routes a widget tap (`kebdazaman://widget/<path>`) to the matching
  /// in-app screen. Registered once from app.dart, mirroring how
  /// NotificationNavigationService handles push-notification taps.
  void handleWidgetUri(Uri? uri, GoRouter router) {
    if (uri == null) return;
    final path = uri.path;
    if (path.isEmpty) return;
    router.push(path);
  }
}
