import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/domain/models/customer_summary.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/customer_management_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_person_card.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends ConsumerState<CustomerManagementScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(customerListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(customerListProvider.notifier).setQuery(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(customerListProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('customers.title'.tr(), style: KZ.pageTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: KZ.searchInputDecoration(
                hint: 'customers.search_hint'.tr(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: KZ.sp8,
              runSpacing: KZ.sp8,
              children: [
                KZChip(
                  label: 'customers.filter_all'.tr(),
                  selected: listAsync.valueOrNull?.isActiveFilter == null,
                  onTap: () => ref
                      .read(customerListProvider.notifier)
                      .setActiveFilter(null),
                ),
                KZChip(
                  label: 'customers.active'.tr(),
                  selected: listAsync.valueOrNull?.isActiveFilter == true,
                  onTap: () => ref
                      .read(customerListProvider.notifier)
                      .setActiveFilter(true),
                ),
                KZChip(
                  label: 'customers.inactive'.tr(),
                  selected: listAsync.valueOrNull?.isActiveFilter == false,
                  onTap: () => ref
                      .read(customerListProvider.notifier)
                      .setActiveFilter(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: KZ.sp8),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: KZ.primary),
              ),
              error: (e, st) => KZErrorState(
                message: 'common.something_wrong'.tr(),
                retryLabel: 'common.retry'.tr(),
                onRetry: () => ref.invalidate(customerListProvider),
              ),
              data: (listState) {
                if (listState.customers.isEmpty) {
                  return KZEmptyState(
                    icon: Icons.groups_outlined,
                    title: 'customers.empty'.tr(),
                  );
                }
                return RefreshIndicator(
                  color: KZ.primary,
                  onRefresh: () => ref.refresh(customerListProvider.future),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount:
                        listState.customers.length +
                        (listState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= listState.customers.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: KZ.primary,
                              ),
                            ),
                          ),
                        );
                      }
                      final customer = listState.customers[index];
                      return _CustomerCard(
                        customer: customer,
                        onTap: () =>
                            context.push('/admin/customers/${customer.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Priority fields per the People-management brief: name, phone, order
/// count, spend. Email was dropped from this compact row (it's not on the
/// requested priority list and every card already opens the full Customer
/// Details screen, unchanged, where it's still shown) — that's the "move
/// secondary details to the detail flow" trim.
class _CustomerCard extends StatelessWidget {
  final CustomerSummary customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AdminPersonCard(
      name: customer.name,
      onTap: onTap,
      badges: [
        if (customer.isGuest)
          AdminStatusPill(
            label: 'customers.guest'.tr(),
            color: KZ.secondary,
          ),
        AdminStatusPill(
          label: customer.isActive
              ? 'customers.active'.tr()
              : 'customers.inactive'.tr(),
          color: customer.isActive ? KZ.tertiary : KZ.error,
        ),
      ],
      subtitle: customer.phone,
      metaLine: Text(
        '${'customers.orders'.tr()}: ${customer.orderCount}  ·  '
        '${'customers.total_spent'.tr()}: ${formatCurrency(customer.totalSpent, locale: context.locale)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: KZ.label,
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: KZ.outline,
      ),
    );
  }
}
