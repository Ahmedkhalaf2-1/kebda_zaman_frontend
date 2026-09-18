import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_page_header.dart';
import 'package:kebda_zaman/features/driver/presentation/notifiers/driver_orders_notifier.dart';
import 'package:kebda_zaman/features/driver/presentation/widgets/driver_order_card.dart';

/// Completed-delivery history — DELIVERED/CANCELLED orders still currently
/// assigned to this driver. `customerPhone` is always null here (backend
/// strips it once the delivery is over), which the detail screen already
/// handles by hiding the call action when absent.
class DriverHistoryScreen extends ConsumerWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(driverHistoryProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            AdminPageHeader(title: 'driver_app.history_title'.tr()),
            Expanded(
              child: RefreshIndicator(
                color: KZ.primary,
                onRefresh: () =>
                    ref.read(driverHistoryProvider.notifier).refresh(),
                child: historyAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: KZ.primary),
                  ),
                  error: (e, st) => LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: KZErrorState(
                          message: 'common.something_wrong'.tr(),
                          retryLabel: 'common.retry'.tr(),
                          onRetry: () => ref.invalidate(driverHistoryProvider),
                        ),
                      ),
                    ),
                  ),
                  data: (orders) {
                    if (orders.isEmpty) {
                      return LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: KZEmptyState(
                                  icon: Icons.history_outlined,
                                  title: 'driver_app.history_empty_title'.tr(),
                                ),
                              ),
                            ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return DriverOrderCard(
                          order: order,
                          onTap: () =>
                              context.push('/driver/history/${order.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
