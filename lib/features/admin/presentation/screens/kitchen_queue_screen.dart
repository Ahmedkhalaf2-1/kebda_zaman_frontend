import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_order_status.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/kitchen_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// KITCHEN role's one and only screen — a pure "what do I need to cook"
/// display. No status-change controls, no customer/payment/address data:
/// the backend's /kitchen/orders endpoints never return any of that (see
/// kitchen_order.dart's doc comment). Live queue via
/// [kitchenQueueProvider]'s poll, plus pull-to-refresh for an immediate
/// manual check.
class KitchenQueueScreen extends ConsumerWidget {
  const KitchenQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(kitchenQueueProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('kitchen.queue_title'.tr(), style: KZ.pageTitle),
        actions: [
          IconButton(
            tooltip: 'profile.logout'.tr(),
            icon: const Icon(Icons.logout_rounded, color: KZ.onSurfaceVariant),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: KZ.primary,
        onRefresh: () => ref.refresh(kitchenQueueProvider.future),
        child: queueAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: KZ.primary),
          ),
          error: (e, st) => KZErrorState(
            message: 'common.something_wrong'.tr(),
            retryLabel: 'common.retry'.tr(),
            onRetry: () => ref.invalidate(kitchenQueueProvider),
          ),
          data: (orders) {
            if (orders.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: KZEmptyState(
                      icon: Icons.soup_kitchen_outlined,
                      title: 'kitchen.empty_title'.tr(),
                      message: 'kitchen.empty_sub'.tr(),
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
                return _TicketCard(
                  order: order,
                  onTap: () => context.push('/admin/kitchen/${order.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final KitchenOrder order;
  final VoidCallback onTap;

  const _TicketCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visual = adminOrderStatusVisual(order.status);
    final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.quantity);
    final lang = context.locale.languageCode;

    return Padding(
      padding: const EdgeInsets.only(bottom: KZ.sp12),
      child: KZCard(
        onTap: onTap,
        padding: const EdgeInsets.all(KZ.sp16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.orderNumber}',
                    style: KZ.itemTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: visual.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KZ.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(visual.icon, size: 14, color: visual.color),
                      const SizedBox(width: 4),
                      Text(
                        visual.label,
                        style: KZ.caption.copyWith(
                          color: visual.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: KZ.sp8),
            Row(
              children: [
                Icon(
                  order.deliveryMethod == FulfillmentType.pickup
                      ? Icons.storefront_rounded
                      : Icons.delivery_dining_rounded,
                  size: 16,
                  color: KZ.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  order.deliveryMethod == FulfillmentType.pickup
                      ? 'checkout.pickup'.tr()
                      : 'checkout.delivery'.tr(),
                  style: KZ.bodySmall,
                ),
                const SizedBox(width: KZ.sp12),
                Icon(
                  Icons.restaurant_rounded,
                  size: 16,
                  color: KZ.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'kitchen.item_count'.tr(namedArgs: {'count': '$itemCount'}),
                  style: KZ.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: KZ.sp10),
            const Divider(height: 1, color: KZ.outlineVariant),
            const SizedBox(height: KZ.sp10),
            for (final item in order.items) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(KZ.radiusSm),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: KZFoodImage(imageUrl: item.imageUrl ?? ''),
                      ),
                    ),
                    const SizedBox(width: KZ.sp8),
                    Expanded(
                      child: Text(
                        '${item.quantity}× ${item.localizedName(lang)}',
                        style: KZ.bodySmall.copyWith(color: KZ.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
