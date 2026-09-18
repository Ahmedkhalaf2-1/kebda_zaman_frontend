import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/providers/polling_notifier_mixin.dart';
import 'package:kebda_zaman/features/driver/domain/models/driver_order.dart';
import 'package:kebda_zaman/features/driver/domain/repositories/driver_order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'driver_session_guard.dart';
import 'driver_tracking_coordinator.dart';

/// Live "current assigned orders" list — polls the same way Kitchen Queue
/// does ([PollingNotifierMixin]), since the backend has no push/SSE wired up
/// for this yet. `autoDispose` stops the poll the moment the driver leaves
/// this screen; a failed background tick keeps showing the current list
/// (only the explicit `refresh()` surfaces an error), except a session-
/// ending [AuthFailure] (deactivation), which always ends the session
/// immediately regardless of whether it happened on a background tick or an
/// explicit refresh.
class DriverActiveOrdersNotifier
    extends AutoDisposeAsyncNotifier<List<DriverOrder>>
    with PollingNotifierMixin<List<DriverOrder>> {
  @override
  Future<List<DriverOrder>> build() async {
    final orders = await fetchLatest();
    startPolling();
    return orders;
  }

  @override
  Future<List<DriverOrder>> fetchLatest() async {
    final repo = ref.read(driverOrderRepositoryProvider);
    final result = await repo.getActiveOrders();
    if (result.isFailure) {
      // Awaited (not fire-and-forget): the session must already be cleared
      // — `authNotifierProvider.isLoggedIn` already false, the router's
      // redirect guard already armed — by the time this throw propagates
      // and any caller (including a background poll tick) inspects auth
      // state. A fire-and-forget call here would leave a real window where
      // the app still looks logged in after a deactivation is detected.
      await endDriverSessionIfAuthFailure(ref, result.failure);
      throw result.failure;
    }
    ref
        .read(driverTrackingCoordinatorProvider)
        .syncFromActiveOrders(result.value);
    return result.value;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<DriverOrder>>().copyWithPrevious(state);
    state = await AsyncValue.guard(fetchLatest);
  }

  /// Replaces one order in the current list in place (or drops it if it's no
  /// longer active) — used right after a pickup/delivered mutation succeeds
  /// on [DriverOrderDetailNotifier], so the list reflects the change
  /// immediately instead of waiting for the next poll tick.
  void applyOrderUpdate(DriverOrder updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (updated.status.isTerminal) {
      state = AsyncData([
        for (final order in current)
          if (order.id != updated.id) order,
      ]);
      return;
    }
    state = AsyncData([
      for (final order in current)
        if (order.id == updated.id) updated else order,
    ]);
  }

  /// Drops an order from the active list without waiting for the next poll —
  /// used when a detail fetch discovers the order is no longer assigned to
  /// this driver (reassigned away mid-flight).
  void removeOrder(String orderId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final order in current)
        if (order.id != orderId) order,
    ]);
  }
}

final driverActiveOrdersProvider =
    AutoDisposeAsyncNotifierProvider<
      DriverActiveOrdersNotifier,
      List<DriverOrder>
    >(DriverActiveOrdersNotifier.new);

/// Completed-delivery history — a single page is enough for this phase (no
/// infinite-scroll UI requirement here); pull-to-refresh re-fetches it.
class DriverHistoryNotifier
    extends AutoDisposeAsyncNotifier<List<DriverOrder>> {
  @override
  Future<List<DriverOrder>> build() => _fetch();

  Future<List<DriverOrder>> _fetch() async {
    final repo = ref.read(driverOrderRepositoryProvider);
    final result = await repo.getHistory(limit: 50);
    if (result.isFailure) {
      await endDriverSessionIfAuthFailure(ref, result.failure);
      throw result.failure;
    }
    return result.value;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<DriverOrder>>().copyWithPrevious(state);
    state = await AsyncValue.guard(_fetch);
  }
}

final driverHistoryProvider =
    AutoDisposeAsyncNotifierProvider<DriverHistoryNotifier, List<DriverOrder>>(
      DriverHistoryNotifier.new,
    );

/// Single order detail — fetched once per id, not polled (mirrors
/// `KitchenOrderNotifier`). Also owns the pickup/delivered mutations so a
/// successful action can set [state] directly from the authoritative
/// response, and nudges [driverActiveOrdersProvider] so the list reflects it
/// without waiting for its next poll tick.
class DriverOrderDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<DriverOrder, String> {
  @override
  Future<DriverOrder> build(String orderId) => _fetch(orderId);

  Future<DriverOrder> _fetch(String orderId) async {
    final repo = ref.read(driverOrderRepositoryProvider);
    final result = await repo.getOrderById(orderId);
    if (result.isFailure) {
      final f = result.failure;
      await endDriverSessionIfAuthFailure(ref, f);
      // A 404 here (ORDER_NOT_ASSIGNED) means the order was reassigned away
      // or never belonged to this driver — drop any stale copy from the
      // active list so it can't be tapped back into from there either.
      if (f is NotFoundFailure && ref.exists(driverActiveOrdersProvider)) {
        ref.read(driverActiveOrdersProvider.notifier).removeOrder(orderId);
      }
      if (f is NotFoundFailure) {
        ref.read(driverTrackingCoordinatorProvider).stopTracking(orderId);
      }
      throw f;
    }
    return result.value;
  }

  Future<void> refresh() async {
    try {
      final data = await _fetch(arg);
      state = AsyncData(data);
    } catch (f) {
      state = AsyncError(f, StackTrace.current);
    }
  }

  /// PATCH /driver/orders/:id/pickup. Returns `null` on success (state
  /// already updated with the authoritative response) or a user-facing
  /// message on failure, leaving the current ticket untouched so the UI can
  /// keep showing it and retry. Callers own their own in-flight/duplicate-
  /// submission guard (same convention as `KitchenOrderNotifier`).
  Future<String?> pickup() => _mutate((repo) => repo.pickup(arg));

  /// PATCH /driver/orders/:id/delivered.
  Future<String?> delivered() => _mutate((repo) => repo.delivered(arg));

  Future<String?> _mutate(
    Future<Result<DriverOrder>> Function(DriverOrderRepository repo) call,
  ) async {
    final repo = ref.read(driverOrderRepositoryProvider);
    final result = await call(repo);
    if (result.isFailure) {
      final f = result.failure;
      await endDriverSessionIfAuthFailure(ref, f);
      return f.message;
    }
    final updated = result.value;
    state = AsyncData(updated);
    if (ref.exists(driverActiveOrdersProvider)) {
      ref.read(driverActiveOrdersProvider.notifier).applyOrderUpdate(updated);
    }
    final coordinator = ref.read(driverTrackingCoordinatorProvider);
    if (updated.status == OrderStatus.outForDelivery) {
      // Covers the pickup mutation: starts tracking immediately with the
      // authoritative assignmentVersion from this very response, rather
      // than waiting for the next active-orders poll tick.
      coordinator.onPickupConfirmed(updated);
    } else {
      // Covers the delivered mutation (and any other terminal transition):
      // stop uploading for this order right away.
      coordinator.stopTracking(updated.id);
    }
    return null;
  }
}

final driverOrderDetailProvider =
    AutoDisposeAsyncNotifierProvider.family<
      DriverOrderDetailNotifier,
      DriverOrder,
      String
    >(DriverOrderDetailNotifier.new);
