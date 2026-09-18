import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/providers/polling_notifier_mixin.dart';
import 'package:kebda_zaman/features/admin/domain/models/order_notification.dart';

class AdminUnreadNotificationCountNotifier
    extends AutoDisposeAsyncNotifier<int> {
  @override
  Future<int> build() async {
    final repo = ref.read(adminOrderNotificationRepositoryProvider);
    final result = await repo.getUnreadCount();
    return result.fold((l) => throw l, (r) => r);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<int>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminOrderNotificationRepositoryProvider);
      final result = await repo.getUnreadCount();
      return result.fold((l) => throw l, (r) => r);
    });
  }
}

final adminUnreadNotificationCountProvider =
    AutoDisposeAsyncNotifierProvider<AdminUnreadNotificationCountNotifier, int>(
      () => AdminUnreadNotificationCountNotifier(),
    );

/// Polls `GET /admin/notifications` (same [PollingNotifierMixin] convention
/// used by Order Management/Kitchen Queue) so the new-order alert engine
/// (`AdminOrderAlertNotifier`, which keeps this provider alive by listening
/// to it for the whole admin session) reliably observes genuinely new
/// orders even when the FCM push that would otherwise trigger
/// `handleAdminNewOrderRefresh` never arrives — notably, on the Chrome web
/// build, which has no service worker/VAPID setup and therefore never
/// receives FCM at all. This also covers "reconnect": a dropped/restored
/// network connection just means the next tick's fetch succeeds again,
/// with no special-cased reconnect logic needed.
class AdminOrderNotificationNotifier
    extends AutoDisposeAsyncNotifier<List<OrderNotification>>
    with PollingNotifierMixin<List<OrderNotification>> {
  @override
  Future<List<OrderNotification>> build() async {
    final notifications = await fetchLatest();
    startPolling();
    return notifications;
  }

  @override
  Future<List<OrderNotification>> fetchLatest() async {
    final repo = ref.read(adminOrderNotificationRepositoryProvider);
    final result = await repo.getNotifications();
    return result.fold((l) => throw l, (r) => r);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<OrderNotification>>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminOrderNotificationRepositoryProvider);
      final result = await repo.getNotifications();
      return result.fold((l) => throw l, (r) => r);
    });
    ref.invalidate(adminUnreadNotificationCountProvider);
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> markAsRead(String id) async {
    final repo = ref.read(adminOrderNotificationRepositoryProvider);
    final currentNotifications = state.valueOrNull ?? [];

    OrderNotification? target;
    for (final n in currentNotifications) {
      if (n.id == id) {
        target = n;
        break;
      }
    }
    if (target == null || target.isRead) {
      // Already read, or not in the current list — nothing to do.
      return null;
    }

    // Optimistic update.
    state = AsyncData(
      currentNotifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );

    final result = await repo.markAsRead(id);
    return result.fold(
      (failure) {
        // Roll back — the server rejected the update.
        state = AsyncData(currentNotifications);
        return failure.message;
      },
      (updated) {
        // Reconcile with the authoritative notification returned by the server.
        final latest = state.valueOrNull ?? currentNotifications;
        state = AsyncData(latest.map((n) => n.id == id ? updated : n).toList());
        ref.invalidate(adminUnreadNotificationCountProvider);
        return null;
      },
    );
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> markAllAsRead() async {
    final repo = ref.read(adminOrderNotificationRepositoryProvider);
    final currentNotifications = state.valueOrNull ?? [];

    state = AsyncData(
      currentNotifications.map((n) => n.copyWith(isRead: true)).toList(),
    );

    final result = await repo.markAllAsRead();
    return result.fold(
      (failure) {
        state = AsyncData(currentNotifications);
        return failure.message;
      },
      (_) {
        ref.invalidate(adminUnreadNotificationCountProvider);
        return null;
      },
    );
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> clearAll() async {
    final repo = ref.read(adminOrderNotificationRepositoryProvider);
    final currentNotifications = state.valueOrNull ?? [];

    state = const AsyncData([]);

    final result = await repo.clearAll();
    return result.fold(
      (failure) {
        state = AsyncData(currentNotifications);
        return failure.message;
      },
      (_) {
        ref.invalidate(adminUnreadNotificationCountProvider);
        return null;
      },
    );
  }
}

final adminOrderNotificationProvider =
    AutoDisposeAsyncNotifierProvider<
      AdminOrderNotificationNotifier,
      List<OrderNotification>
    >(() => AdminOrderNotificationNotifier());
