import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/providers/polling_notifier_mixin.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';

/// Live kitchen queue — no push/SSE wired up on the backend for this yet,
/// so a background poll (via [PollingNotifierMixin], never overlapping
/// requests) is the only way to keep it current. `autoDispose` stops the
/// poll the moment the Kitchen Queue screen is left; a failed background
/// tick keeps showing the current queue instead of replacing it with an
/// error (only the explicit `refresh()` — pull-to-refresh — surfaces
/// errors).
class KitchenQueueNotifier extends AutoDisposeAsyncNotifier<List<KitchenOrder>>
    with PollingNotifierMixin<List<KitchenOrder>> {
  @override
  Future<List<KitchenOrder>> build() async {
    final orders = await fetchLatest();
    startPolling();
    return orders;
  }

  @override
  Future<List<KitchenOrder>> fetchLatest() async {
    final repo = ref.read(kitchenRepositoryProvider);
    final result = await repo.getQueue();
    return result.fold((f) => throw f, (data) => data);
  }

  /// Manual pull-to-refresh / retry — unlike a background poll tick, a
  /// failure here is allowed to surface as [AsyncError].
  Future<void> refresh() async {
    state = const AsyncLoading<List<KitchenOrder>>().copyWithPrevious(state);
    state = await AsyncValue.guard(fetchLatest);
  }

  /// Replaces one order in the current list in place — used right after a
  /// preparation-time mutation on [KitchenOrderNotifier] succeeds, so the
  /// queue reflects the change promptly instead of waiting up to 5s for the
  /// next background poll tick. A no-op if the queue hasn't loaded yet or
  /// no longer contains this order (e.g. it moved out of CONFIRMED/PREPARING).
  void applyOrderUpdate(KitchenOrder updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final order in current)
        if (order.id == updated.id) updated else order,
    ]);
  }
}

final kitchenQueueProvider =
    AutoDisposeAsyncNotifierProvider<KitchenQueueNotifier, List<KitchenOrder>>(
      KitchenQueueNotifier.new,
    );

/// Single ticket detail — fetched once per `id`, not polled: the backend
/// deliberately doesn't restrict this endpoint to CONFIRMED/PREPARING like
/// the queue, specifically so an already-open ticket keeps working (just
/// stops updating) once the order moves past that. Pull-to-refresh
/// (`refresh()`) covers the "check if it changed" case without needing a
/// background poll on a screen someone is actively reading.
///
/// Also owns the preparation-time mutation for this ticket — kept on the
/// same notifier as the fetch so a successful PATCH can set [state]
/// directly from the authoritative response, no extra re-fetch needed.
class KitchenOrderNotifier
    extends AutoDisposeFamilyAsyncNotifier<KitchenOrder, String> {
  @override
  Future<KitchenOrder> build(String orderId) => _fetch(orderId);

  Future<KitchenOrder> _fetch(String orderId) async {
    final repo = ref.read(kitchenRepositoryProvider);
    final result = await repo.getOrder(orderId);
    return result.fold((f) => throw f, (data) => data);
  }

  Future<void> refresh() async {
    try {
      final data = await _fetch(arg);
      state = AsyncData(data);
    } catch (f) {
      state = AsyncError(f, StackTrace.current);
    }
  }

  /// PATCH /kitchen/orders/:id/preparation-time. Returns `null` on success
  /// (state is updated with the authoritative response, including the
  /// backend-computed [KitchenOrder.estimatedDeliveryTime] — never
  /// fabricated client-side) or an error message on failure, leaving the
  /// current ticket untouched so the UI can keep showing it and retry.
  /// Callers own their own in-flight/duplicate-tap guard (matching this
  /// codebase's existing convention, e.g. [OrderReviewsNotifier]).
  Future<String?> setPreparationTime(int minutes) async {
    final repo = ref.read(kitchenRepositoryProvider);
    final result = await repo.setPreparationTime(arg, minutes);
    return result.fold((f) => f.message, (updated) {
      state = AsyncData(updated);
      // Best-effort: the queue notifier may not exist right now (queue
      // screen not mounted) — reading it here would needlessly keep it
      // alive, so only nudge it if it's already been built.
      if (ref.exists(kitchenQueueProvider)) {
        ref.read(kitchenQueueProvider.notifier).applyOrderUpdate(updated);
      }
      return null;
    });
  }
}

final kitchenOrderProvider =
    AutoDisposeAsyncNotifierProvider.family<
      KitchenOrderNotifier,
      KitchenOrder,
      String
    >(KitchenOrderNotifier.new);
