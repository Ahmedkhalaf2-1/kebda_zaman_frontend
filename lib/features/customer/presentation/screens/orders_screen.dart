import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../notifiers/orders_notifier.dart';
import '../notifiers/cart_notifier.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

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
                    // Changed from Kebda Zaman to Orders exactly as requested!
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
                child: ordersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(KZ.primary),
                    ),
                  ),
                  error: (e, st) => KZErrorState(
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
                      color: KZ.primary,
                      onRefresh: () async => ref.invalidate(ordersProvider),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        children: [
                          if (data.activeOrders.isNotEmpty) ...[
                            Text(
                              'orders.active'.tr(),
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: KZ.onSurface,
                              ),
                            ),
                            const SizedBox(height: 14),
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
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: KZ.onSurface,
                              ),
                            ),
                            const SizedBox(height: 14),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
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

class _OrderCard extends ConsumerWidget {
  final Order order;
  const _OrderCard({required this.order});

  Future<void> _handleReorder(BuildContext context, WidgetRef ref) async {
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

    for (final item in order.items) {
      final res = await menuRepo.getMenuItemById(item.menuItemId);
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
            id: 'ci_${DateTime.now().millisecondsSinceEpoch}_${item.menuItemId}',
            menuItemId: item.menuItemId,
            productName: menuItem.name,
            productImage: menuItem.imageUrl,
            basePrice: basePrice,
            quantity: item.quantity,
            selectedOptions: item.selectedOptions,
            nestedSelections: item.nestedSelections,
            extraQuantities: item.extraQuantities,
            removedIngredients: item.removedIngredients,
            specialInstructions: 'Reordered from previous order',
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive =
        order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;

    final dateStr =
        '${order.placedAt.day}/${order.placedAt.month}/${order.placedAt.year} ${order.placedAt.hour}:${order.placedAt.minute.toString().padLeft(2, '0')}';

    final orderNumDisplay = order.orderNumber.isNotEmpty
        ? 'Order #${order.orderNumber}'
        : 'Order #KZ-${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/orders/tracking/${order.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: KZ.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: KZ.primary.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Order ID & Date on left, Pill Status Badge on right ──
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
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: KZ.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: KZ.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusPill(order.status),
                ],
              ),

              const SizedBox(height: 14),
              Divider(
                height: 1,
                thickness: 1,
                color: KZ.outlineVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 14),

              // ── Bottom Row: Total Price on left, Action Button on right ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'orders.total_label'.tr(),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: KZ.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.grandTotal.toStringAsFixed(0)} EGP',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isActive ? KZ.primary : KZ.secondary,
                        ),
                      ),
                    ],
                  ),
                  if (isActive)
                    ElevatedButton(
                      onPressed: () =>
                          context.push('/orders/tracking/${order.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KZ.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: KZ.primary.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        'orders.track'.tr(),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _handleReorder(context, ref),
                      icon: const Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: KZ.onSurface,
                      ),
                      label: Text(
                        'orders.reorder'.tr(),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KZ.onSurface,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: KZ.outlineVariant,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(OrderStatus status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String labelText;

    switch (status) {
      case OrderStatus.pending:
        bgColor = KZ.primaryFixed.withValues(alpha: 0.4);
        textColor = KZ.primary;
        icon = Icons.schedule_rounded;
        labelText = 'orders.status.pending'.tr();
        break;
      case OrderStatus.confirmed:
        bgColor = KZ.primaryFixed.withValues(alpha: 0.4);
        textColor = KZ.primary;
        icon = Icons.task_alt_rounded;
        labelText = 'orders.status.confirmed'.tr();
        break;
      case OrderStatus.preparing:
        bgColor = KZ.primaryFixed.withValues(alpha: 0.4);
        textColor = KZ.primary;
        icon = Icons.soup_kitchen_rounded;
        labelText = 'orders.status.preparing'.tr();
        break;
      case OrderStatus.outForDelivery:
        bgColor = KZ.primaryFixed.withValues(alpha: 0.4);
        textColor = KZ.primary;
        icon = Icons.delivery_dining_rounded;
        labelText = 'orders.status.out_for_delivery'.tr();
        break;
      case OrderStatus.delivered:
        bgColor = const Color(0xFFE8F5E9); // green-50/100 tint from HTML
        textColor = const Color(0xFF1B5E20); // green-700 from HTML
        icon = Icons.check_circle_rounded;
        labelText = 'orders.status.delivered'.tr();
        break;
      case OrderStatus.cancelled:
        bgColor = const Color(0xFFFEE2E2);
        textColor = KZ.error;
        icon = Icons.cancel_rounded;
        labelText = 'orders.status.cancelled'.tr();
        break;
      case OrderStatus.unknown:
        bgColor = KZ.surfaceContainerHigh;
        textColor = KZ.onSurfaceVariant;
        icon = Icons.help_outline_rounded;
        labelText = 'orders.status.unknown'.tr();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            labelText,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
