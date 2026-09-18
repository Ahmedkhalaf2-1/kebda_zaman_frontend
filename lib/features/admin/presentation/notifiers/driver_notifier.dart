import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/driver_account.dart';

const _kPageLimit = 20;

class DriverListState {
  final List<DriverAccount> drivers;
  final String query;
  final bool? isActiveFilter;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const DriverListState({
    required this.drivers,
    this.query = '',
    this.isActiveFilter,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  DriverListState copyWith({
    List<DriverAccount>? drivers,
    String? query,
    bool? isActiveFilter,
    bool clearIsActiveFilter = false,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DriverListState(
      drivers: drivers ?? this.drivers,
      query: query ?? this.query,
      isActiveFilter: clearIsActiveFilter
          ? null
          : (isActiveFilter ?? this.isActiveFilter),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Same array-response, no-total-count pagination convention as
/// [CustomerListNotifier] (`/admin/drivers` — DRIVER_DELIVERY_API_CONTRACT.md
/// confirms a plain array, no envelope) — `hasMore` is inferred from
/// whether a full page came back, never a server-reported total.
class DriverListNotifier extends AutoDisposeAsyncNotifier<DriverListState> {
  @override
  Future<DriverListState> build() async {
    return _fetchPage(query: '', isActiveFilter: null, page: 1);
  }

  Future<DriverListState> _fetchPage({
    required String query,
    required bool? isActiveFilter,
    required int page,
  }) async {
    final repo = ref.read(driverRepositoryProvider);
    final result = await repo.getDrivers(
      query: query.isEmpty ? null : query,
      isActive: isActiveFilter,
      page: page,
      limit: _kPageLimit,
    );
    final list = result.fold((f) => throw f, (data) => data);
    return DriverListState(
      drivers: list,
      query: query,
      isActiveFilter: isActiveFilter,
      page: page,
      hasMore: list.length == _kPageLimit,
    );
  }

  Future<void> setQuery(String query) async {
    final current = state.valueOrNull;
    final filter = current?.isActiveFilter;
    state = const AsyncLoading<DriverListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => _fetchPage(query: query, isActiveFilter: filter, page: 1),
    );
  }

  Future<void> setActiveFilter(bool? isActiveFilter) async {
    final current = state.valueOrNull;
    final query = current?.query ?? '';
    state = const AsyncLoading<DriverListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => _fetchPage(query: query, isActiveFilter: isActiveFilter, page: 1),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await ref
        .read(driverRepositoryProvider)
        .getDrivers(
          query: current.query.isEmpty ? null : current.query,
          isActive: current.isActiveFilter,
          page: nextPage,
          limit: _kPageLimit,
        );

    result.fold(
      (f) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (more) {
        state = AsyncData(
          current.copyWith(
            drivers: [...current.drivers, ...more],
            page: nextPage,
            hasMore: more.length == _kPageLimit,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<Failure?> createDriver({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final repo = ref.read(driverRepositoryProvider);
    final result = await repo.createDriver(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    return result.fold((f) => f, (driver) {
      ref.invalidateSelf();
      return null;
    });
  }

  Future<Failure?> updateDriver(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? password,
    bool? isActive,
  }) async {
    final repo = ref.read(driverRepositoryProvider);
    final result = await repo.updateDriver(
      id,
      name: name,
      email: email,
      phone: phone,
      password: password,
      isActive: isActive,
    );
    return result.fold((f) => f, (driver) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            drivers: [
              for (final d in current.drivers)
                if (d.id == id) driver else d,
            ],
          ),
        );
      }
      return null;
    });
  }
}

final driverListProvider =
    AutoDisposeAsyncNotifierProvider<DriverListNotifier, DriverListState>(
      DriverListNotifier.new,
    );

/// Single active-driver directory used by the order-assignment picker on
/// Admin Order Details — a single page (limit 100) is enough for this
/// phase's expected driver-fleet size, and re-fetches every time the picker
/// opens rather than sharing [driverListProvider]'s (filterable/paginated)
/// state.
final activeDriversForAssignmentProvider =
    FutureProvider.autoDispose<List<DriverAccount>>((ref) async {
      final repo = ref.watch(driverRepositoryProvider);
      final result = await repo.getDrivers(isActive: true, page: 1, limit: 100);
      return result.fold((f) => throw f, (data) => data);
    });
