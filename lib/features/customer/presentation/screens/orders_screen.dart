import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../notifiers/orders_notifier.dart';
import '../notifiers/cart_notifier.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_order_status.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

/// Rebuilds a reorder's `selectedOptions` (`groupId -> [optionId, ...]`)
/// from [item]'s `variantRefId`/`addonRefIds` against [menuItem]'s *current*
/// modifier groups. The order response only carries each variant/addon's
/// own live id, not which group it belongs to, so that has to be
/// re-derived here rather than replayed from the order. A `refId` that no
/// longer matches any option on the live item (variant/addon since
/// discontinued or removed) is silently dropped, never surfaced as an
/// error — the reordered item still gets added, just without that one
/// customization. Only top-level groups are searched: the order response
/// doesn't expose refs for nested modifiers.
Map<String, List<String>> _reconstructSelectedOptions(
  MenuItem menuItem,
  OrderItem item,
) {
  String? groupIdFor(String optionId) {
    for (final group in menuItem.modifierGroups) {
      for (final option in group.options) {
        if (option.id == optionId) return group.id;
      }
    }
    return null;
  }

  final selected = <String, List<String>>{};
  for (final refId in [item.variantRefId, ...item.addonRefIds]) {
    if (refId == null) continue;
    final groupId = groupIdFor(refId);
    if (groupId == null) continue;
    selected.putIfAbsent(groupId, () => []).add(refId);
  }
  return selected;
}

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(ordersProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: KZ.surface, // #fcf9f5 (our brand background)
      body: ResponsiveContainer(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top Navigation Bar matching Menu, Cart, & Profile height (64px) ──
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: KZ.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'nav.orders'.tr(),
                      style: KZ.pageTitle.copyWith(
                        color: KZ.primary, // #8c2b00
                      ),
                    ),
                    InkWell(
                      onTap: () => context.go('/profile'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KZ.primaryFixed.withValues(alpha: 0.3),
                          border: Border.all(color: KZ.primary, width: 2),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: KZ.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Orders Content Area ──
              Expanded(
                child: AnimatedSwitcher(
                  duration: KZMotion.durationFor(context, KZMotion.standard),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: ordersAsync.when(
                    loading: () => const Center(
                      key: ValueKey('loading'),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(KZ.primary),
                      ),
                    ),
                    error: (e, st) => KZErrorState(
                      key: const ValueKey('error'),
                      message: 'orders.load_error'.tr(),
                      onRetry: () => ref.invalidate(ordersProvider),
                      retryLabel: 'common.retry'.tr(),
                    ),
                    data: (data) {
                      if (data.activeOrders.isEmpty &&
                          data.previousOrders.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return RefreshIndicator(
                        key: const ValueKey('data'),
                        color: KZ.primary,
                        onRefresh: () async => ref.invalidate(ordersProvider),
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                          children: [
                            if (data.activeOrders.isNotEmpty) ...[
                              Text(
                                'orders.active'.tr(),
                                style: KZ.sectionTitle,
                              ),
                              const SizedBox(height: 12),
                              ...data.activeOrders.map(
                                (o) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _OrderCard(order: o),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (data.previousOrders.isNotEmpty) ...[
                              Text(
                                'orders.previous'.tr(),
                                style: KZ.sectionTitle,
                              ),
                              const SizedBox(height: 12),
                              ...data.previousOrders.map(
                                (o) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _OrderCard(order: o),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      key: const ValueKey('empty'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KZEmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'orders.no_orders'.tr(),
              message: 'orders.no_orders_sub'.tr(),
              actionLabel: 'orders.start_ordering'.tr(),
              onAction: () => context.go('/menu'),
            ),
            const SizedBox(height: 16),
            KZButton(
              label: 'profile.my_favorites'.tr(),
              variant: KZButtonVariant.tertiary,
              onPressed: () => context.push('/profile/favorites'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _isReordering = false;

  Future<void> _handleReorder(BuildContext context, WidgetRef ref) async {
    if (_isReordering) return;
    setState(() => _isReordering = true);

    final menuRepo = ref.read(menuRepositoryProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('orders.checking_availability'.tr()),
        backgroundColor: KZ.primary,
      ),
    );

    int addedCount = 0;
    int unavailableCount = 0;
    int failedCount = 0;

    try {
      for (final item in widget.order.items) {
        // No live catalog id to look up — either this order predates the
        // backend exposing `menuItemId`, or the item was hard-deleted
        // since. Same treatment as a 404 below: unavailable, skip it.
        final menuItemId = item.menuItemId;
        if (menuItemId == null || menuItemId.isEmpty) {
          unavailableCount++;
          continue;
        }

        final res = await menuRepo.getMenuItemById(menuItemId);
        await res.fold(
          (f) async {
            unavailableCount++;
          },
          (menuItem) async {
            if (!menuItem.isAvailable) {
              unavailableCount++;
              return;
            }

            final basePrice = menuItem.discountPrice ?? menuItem.basePrice;

            final cartItem = CartItem(
              id: 'ci_${DateTime.now().millisecondsSinceEpoch}_$menuItemId',
              menuItemId: menuItemId,
              productName: menuItem.name,
              productImage: menuItem.imageUrl,
              basePrice: basePrice,
              quantity: item.quantity,
              // Reconstructed fresh against the live menu item rather than
              // carried over from the order: the order response only gives
              // each variant/addon's own live id (`refId`), not which
              // modifier group it belongs to, so the group has to be
              // looked up here. A `refId` that no longer matches any
              // current group/option (variant discontinued, addon removed)
              // is silently dropped — the item itself still gets added,
              // just without that customization, rather than failing the
              // whole reorder. Nested-modifier selections aren't
              // reconstructed: the order response doesn't expose refs for
              // those, only top-level variant/addon.
              selectedOptions: _reconstructSelectedOptions(menuItem, item),
              specialInstructions: item.specialInstructions,
              unitPrice: item.unitPrice,
              lineTotal: item.unitPrice * item.quantity,
            );

            try {
              await cartNotifier.addItem(cartItem);
              addedCount++;
            } catch (e) {
              failedCount++;
            }
          },
        );
      }
    } finally {
      if (mounted) setState(() => _isReordering = false);
    }

    if (!context.mounted) return;

    if (addedCount > 0) {
      final issues = <String>[];
      if (unavailableCount > 0) {
        issues.add(
          'orders.reorder_note_unavailable'.tr(
            namedArgs: {'count': '$unavailableCount'},
          ),
        );
      }
      if (failedCount > 0) {
        issues.add(
          'orders.reorder_note_failed'.tr(namedArgs: {'count': '$failedCount'}),
        );
      }
      final addedMsg = 'orders.added_to_cart'.tr(
        namedArgs: {'count': '$addedCount'},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            issues.isNotEmpty ? '$addedMsg (${issues.join(', ')})' : addedMsg,
          ),
          backgroundColor: KZ.primary,
        ),
      );
      context.go('/cart');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failedCount > 0
                ? 'orders.reorder_failed'.tr()
                : 'orders.reorder_none_available'.tr(),
          ),
          backgroundColor: KZ.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isActive = !order.status.isTerminal;
    final visual = orderStatusVisual(order.status);

    final dateStr =
        '${order.placedAt.day}/${order.placedAt.month}/${order.placedAt.year} ${order.placedAt.hour}:${order.placedAt.minute.toString().padLeft(2, '0')}';

    final orderNumDisplay = 'orders.order_num'.tr(
      namedArgs: {
        'id': order.orderNumber.isNotEmpty
            ? order.orderNumber
            : 'KZ-${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}',
      },
    );

    final fulfillmentLabel = order.fulfillmentType == FulfillmentType.pickup
        ? 'checkout.pickup'.tr()
        : 'checkout.delivery'.tr();
    final fulfillmentIcon = order.fulfillmentType == FulfillmentType.pickup
        ? Icons.storefront_rounded
        : Icons.delivery_dining_rounded;

    return KZPressableScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/orders/tracking/${order.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: KZ.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: KZ.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: order identity (strongest scan point) + status ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderNumDisplay,
                            style: KZ.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                fulfillmentIcon,
                                size: 12,
                                color: KZ.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '$dateStr · $fulfillmentLabel',
                                  style: KZ.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: KZMotion.durationFor(context, KZMotion.fast),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: KZStatusBadge(
                        key: ValueKey(order.status),
                        label: visual.label,
                        icon: visual.icon,
                        color: visual.color,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Bottom row: total + the one action for this card ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('orders.total_label'.tr(), style: KZ.caption),
                          const SizedBox(height: 1),
                          Text(
                            formatCurrency(
                              order.grandTotal,
                              locale: context.locale,
                            ),
                            style: KZ.price.copyWith(
                              color: isActive ? KZ.primary : KZ.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isActive)
                      KZButton(
                        label: 'orders.track'.tr(),
                        pill: true,
                        onPressed: () =>
                            context.push('/orders/tracking/${order.id}'),
                      )
                    else
                      KZButton(
                        label: 'orders.reorder'.tr(),
                        icon: Icons.history_rounded,
                        variant: KZButtonVariant.secondary,
                        pill: false,
                        loading: _isReordering,
                        onPressed: () => _handleReorder(context, ref),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
