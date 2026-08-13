import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';

/// Live kitchen queue — no push/SSE wired up on the backend for this yet,
/// so a plain sequential poll (never overlapping requests) is the only way
/// to keep it current. `ref.refresh(kitchenQueueProvider)` also gives the
/// screen manual pull-to-refresh on top of this for free. Not autoDispose,
/// matching `orderTrackingProvider`'s convention elsewhere in this app.
final kitchenQueueProvider = StreamProvider<List<KitchenOrder>>((ref) async* {
  final repo = ref.watch(kitchenRepositoryProvider);
  while (true) {
    final result = await repo.getQueue();
    yield result.fold((f) => throw f, (data) => data);
    await Future.delayed(const Duration(seconds: 10));
  }
});

/// Single ticket detail — fetched once per `id`, not polled: the backend
/// deliberately doesn't restrict this endpoint to CONFIRMED/PREPARING like
/// the queue, specifically so an already-open ticket keeps working (just
/// stops updating) once the order moves past that. Pull-to-refresh
/// (`ref.invalidate`) covers the "check if it changed" case without
/// needing a background poll on a screen someone is actively reading.
final kitchenOrderProvider =
    FutureProvider.autoDispose.family<KitchenOrder, String>((ref, id) async {
      final repo = ref.watch(kitchenRepositoryProvider);
      final result = await repo.getOrder(id);
      return result.fold((f) => throw f, (data) => data);
    });
