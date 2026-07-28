import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/customer_summary.dart';

const _kPageLimit = 20;

class CustomerListState {
  final List<CustomerSummary> customers;
  final String query;
  final bool? isActiveFilter;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const CustomerListState({
    required this.customers,
    this.query = '',
    this.isActiveFilter,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  CustomerListState copyWith({
    List<CustomerSummary>? customers,
    String? query,
    bool? isActiveFilter,
    bool clearIsActiveFilter = false,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CustomerListState(
      customers: customers ?? this.customers,
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

class CustomerListNotifier extends AutoDisposeAsyncNotifier<CustomerListState> {
  @override
  Future<CustomerListState> build() async {
    return _fetchPage(query: '', isActiveFilter: null, page: 1);
  }

  Future<CustomerListState> _fetchPage({
    required String query,
    required bool? isActiveFilter,
    required int page,
  }) async {
    final repo = ref.read(customerRepositoryProvider);
    final result = await repo.getCustomers(
      query: query.isEmpty ? null : query,
      isActive: isActiveFilter,
      page: page,
      limit: _kPageLimit,
    );
    final list = result.fold((f) => throw f, (data) => data);
    return CustomerListState(
      customers: list,
      query: query,
      isActiveFilter: isActiveFilter,
      page: page,
      hasMore: list.length == _kPageLimit,
    );
  }

  Future<void> setQuery(String query) async {
    final current = state.valueOrNull;
    final filter = current?.isActiveFilter;
    state = const AsyncLoading<CustomerListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => _fetchPage(query: query, isActiveFilter: filter, page: 1),
    );
  }

  Future<void> setActiveFilter(bool? isActiveFilter) async {
    final current = state.valueOrNull;
    final query = current?.query ?? '';
    state = const AsyncLoading<CustomerListState>().copyWithPrevious(state);
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
        .read(customerRepositoryProvider)
        .getCustomers(
          query: current.query.isEmpty ? null : current.query,
          isActive: current.isActiveFilter,
          page: nextPage,
          limit: _kPageLimit,
        );

    result.fold(
      (f) {
        // Preserve current data on failure — just stop the loading spinner.
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (moreCustomers) {
        state = AsyncData(
          current.copyWith(
            customers: [...current.customers, ...moreCustomers],
            page: nextPage,
            hasMore: moreCustomers.length == _kPageLimit,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<Failure?> updateCustomerStatus(String id, bool isActive) async {
    final repo = ref.read(customerRepositoryProvider);
    final result = await repo.updateCustomerStatus(id, isActive: isActive);
    return result.fold((f) => f, (detail) {
      final current = state.valueOrNull;
      if (current == null) return null;
      state = AsyncData(
        current.copyWith(
          customers: [
            for (final c in current.customers)
              if (c.id == id) detail.summary else c,
          ],
        ),
      );
      return null;
    });
  }
}

final customerListProvider =
    AutoDisposeAsyncNotifierProvider<CustomerListNotifier, CustomerListState>(
      () => CustomerListNotifier(),
    );

final customerDetailProvider = FutureProvider.autoDispose
    .family<CustomerDetail, String>((ref, id) async {
      final repo = ref.watch(customerRepositoryProvider);
      final result = await repo.getCustomerDetail(id);
      return result.fold((f) => throw f, (data) => data);
    });
