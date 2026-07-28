import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/admin/domain/models/customer_summary.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/customer_management_notifier.dart';

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
      backgroundColor: KZ.surface,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'customers.title'.tr(),
          style: const TextStyle(
            color: KZ.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'customers.search_hint'.tr(),
                prefixIcon: const Icon(Icons.search, color: KZ.primary),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: KZ.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: KZ.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterChip(
                  label: 'customers.filter_all'.tr(),
                  selected: listAsync.valueOrNull?.isActiveFilter == null,
                  onTap: () => ref
                      .read(customerListProvider.notifier)
                      .setActiveFilter(null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'customers.active'.tr(),
                  selected: listAsync.valueOrNull?.isActiveFilter == true,
                  onTap: () => ref
                      .read(customerListProvider.notifier)
                      .setActiveFilter(true),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'customers.inactive'.tr(),
                  selected: listAsync.valueOrNull?.isActiveFilter == false,
                  onTap: () => ref
                      .read(customerListProvider.notifier)
                      .setActiveFilter(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: KZ.primary),
              ),
              error: (e, st) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'common.something_wrong'.tr(),
                      style: const TextStyle(color: KZ.onSurface),
                    ),
                    const SizedBox(height: 12),
                    KZButton(
                      label: 'common.retry'.tr(),
                      onPressed: () => ref.invalidate(customerListProvider),
                    ),
                  ],
                ),
              ),
              data: (listState) {
                if (listState.customers.isEmpty) {
                  return Center(
                    child: Text(
                      'customers.empty'.tr(),
                      style: const TextStyle(color: KZ.secondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: KZ.primary,
                  onRefresh: () => ref.refresh(customerListProvider.future),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? KZ.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? KZ.primary
                : KZ.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : KZ.onSurface,
          ),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerSummary customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: KZ.onSurface,
                          ),
                        ),
                      ),
                      if (customer.isGuest) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: KZ.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'customers.guest'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: KZ.secondary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: (customer.isActive ? KZ.tertiary : KZ.error)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          customer.isActive
                              ? 'customers.active'.tr()
                              : 'customers.inactive'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: customer.isActive ? KZ.tertiary : KZ.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (customer.email != null)
                    Text(
                      customer.email!,
                      style: const TextStyle(fontSize: 13, color: KZ.secondary),
                    ),
                  if (customer.phone != null)
                    Text(
                      customer.phone!,
                      style: const TextStyle(fontSize: 13, color: KZ.secondary),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '${'customers.orders'.tr()}: ${customer.orderCount}  •  '
                    '${'customers.total_spent'.tr()}: ${formatCurrency(customer.totalSpent, locale: context.locale)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KZ.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: KZ.secondary),
          ],
        ),
      ),
    );
  }
}
