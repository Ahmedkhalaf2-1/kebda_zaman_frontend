import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Single admin order detail — fetched once per id. Also owns the driver
/// assignment mutations (assign/reassign/unassign) so a successful call can
/// set [state] directly from the authoritative `AdminOrderResponseDto`
/// (which always carries the current `driverId`) rather than trusting an
/// optimistic local update — the backend enforces delivery-only/terminal-
/// state rules and a concurrent-change race (`409 ASSIGNMENT_CHANGED`)
/// server-side, so this never shows a false success.
class AdminOrderDetailsNotifier
    extends AutoDisposeFamilyAsyncNotifier<Order, String> {
  @override
  Future<Order> build(String orderId) => _fetch(orderId);

  Future<Order> _fetch(String orderId) async {
    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.getAdminOrderById(orderId);
    return result.fold((f) => throw f, (data) => data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<Order>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  /// Returns `null` on success (state already updated with the
  /// authoritative response) or a user-facing message on failure, leaving
  /// the current order untouched so the UI can retry against the still-valid
  /// on-screen state rather than a value it can no longer trust.
  Future<String?> assignDriver(String driverId) async {
    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.assignDriver(arg, driverId);
    return result.fold((f) => f.message, (updated) {
      state = AsyncData(updated);
      return null;
    });
  }

  Future<String?> unassignDriver() async {
    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.unassignDriver(arg);
    return result.fold((f) => f.message, (updated) {
      state = AsyncData(updated);
      return null;
    });
  }
}

final adminOrderDetailsProvider =
    AutoDisposeAsyncNotifierProvider.family<
      AdminOrderDetailsNotifier,
      Order,
      String
    >(AdminOrderDetailsNotifier.new);
