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
}

final kitchenQueueProvider =
    AutoDisposeAsyncNotifierProvider<KitchenQueueNotifier, List<KitchenOrder>>(
      KitchenQueueNotifier.new,
    );

/// Single ticket detail — fetched once per `id`, not polled: the backend
/// deliberately doesn't restrict this endpoint to CONFIRMED/PREPARING like
/// the queue, specifically so an already-open ticket keeps working (just
/// stops updating) once the order moves past that. Pull-to-refresh
/// (`ref.invalidate`) covers the "check if it changed" case without
/// needing a background poll on a screen someone is actively reading.
final kitchenOrderProvider = FutureProvider.autoDispose
    .family<KitchenOrder, String>((ref, id) async {
      final repo = ref.watch(kitchenRepositoryProvider);
      final result = await repo.getOrder(id);
      return result.fold((f) => throw f, (data) => data);
    });
