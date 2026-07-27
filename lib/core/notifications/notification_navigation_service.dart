import 'package:go_router/go_router.dart';
import 'notification_model.dart';

class NotificationNavigationService {
  static final NotificationNavigationService instance =
      NotificationNavigationService._();
  NotificationNavigationService._();

  GoRouter? _router;
  AppNotificationPayload? _pendingPayload;

  /// Register GoRouter instance once ready
  void setRouter(GoRouter router) {
    _router = router;
    if (_pendingPayload != null) {
      final payload = _pendingPayload!;
      _pendingPayload = null;
      handleNotificationTap(payload);
    }
  }

  /// Process notification tap payload and navigate to correct target screen
  void handleNotificationTap(AppNotificationPayload payload) {
    if (_router == null) {
      _pendingPayload = payload;
      return;
    }

    final router = _router!;

    // 1. Direct explicit route in payload if provided
    if (payload.route != null && payload.route!.isNotEmpty) {
      try {
        router.push(payload.route!);
        return;
      } catch (_) {}
    }

    // 1b. Admin NEW_ORDER push — navigation target comes only from the raw
    // `data` payload (orderId), never parsed out of the title/body text.
    // This is independent of the customer-facing NotificationType switch
    // below, since the backend sends `data.type: "NEW_ORDER"`, which
    // NotificationType.fromString() would otherwise map to `unknown`.
    if (payload.rawData['type'] == 'NEW_ORDER') {
      final orderId = payload.rawData['orderId']?.toString();
      if (orderId != null && orderId.isNotEmpty) {
        final targetPath = '/admin/orders/$orderId';
        // router.state reflects the top of the current match stack (what's
        // actually displayed); routerDelegate.currentConfiguration.uri and
        // routeInformationProvider.value.uri both instead reflect the base
        // of the stack, not the topmost pushed page, so they're unsuitable
        // for "what's on screen right now".
        final currentPath = router.state.uri.path;
        // Already viewing this exact order's details — do nothing rather
        // than push a duplicate page for a repeat tap on the same order.
        if (currentPath == targetPath) return;
        router.push(targetPath);
      } else {
        router.push('/admin/order-notifications');
      }
      return;
    }

    // 2. Dynamic route based on notification type & entityId
    final entityId = payload.entityId;

    switch (payload.type) {
      case NotificationType.promotion:
      case NotificationType.offer:
        if (entityId != null && entityId.isNotEmpty) {
          router.push('/item/$entityId');
        } else {
          router.go('/menu');
        }
        break;

      case NotificationType.newProduct:
        if (entityId != null && entityId.isNotEmpty) {
          router.push('/item/$entityId');
        } else {
          router.go('/menu');
        }
        break;

      case NotificationType.category:
        router.go('/menu');
        break;

      case NotificationType.orderCreated:
      case NotificationType.orderConfirmed:
      case NotificationType.orderPreparing:
      case NotificationType.orderReady:
      case NotificationType.orderOutForDelivery:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
        if (entityId != null && entityId.isNotEmpty) {
          router.push('/orders/tracking/$entityId');
        } else {
          router.go('/orders');
        }
        break;

      case NotificationType.paymentSuccess:
      case NotificationType.paymentFailed:
        if (entityId != null && entityId.isNotEmpty) {
          router.push('/orders/tracking/$entityId');
        } else {
          router.go('/orders');
        }
        break;

      case NotificationType.general:
      case NotificationType.unknown:
        router.go('/home');
        break;
    }
  }
}
