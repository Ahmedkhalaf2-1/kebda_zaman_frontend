import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/dashboard_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: stateAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: KZ.primary)),
          error: (e, st) => KZErrorState(
            message: 'common.something_wrong'.tr(),
            onRetry: () => ref.invalidate(dashboardProvider),
            retryLabel: 'common.retry'.tr(),
          ),
          data: (stats) {
            return RefreshIndicator(
              color: KZ.primary,
              onRefresh: () async => ref.invalidate(dashboardProvider),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  // Top AppBar
                  _buildAppBar(context),
                  const SizedBox(height: 20),

                  // Hero Welcome Section
                  _buildHeroHeader(),
                  const SizedBox(height: 20),

                  // Metrics Cards (Today's Orders, Active Orders, Revenue)
                  _buildMetricCards(stats),
                  const SizedBox(height: 28),

                  // Recent Orders Section (Chart section removed per user request)
                  _buildRecentOrdersHeader(context),
                  const SizedBox(height: 12),
                  _buildRecentOrdersList(context, stats.recentOrders),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: KZ.primary,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'app_name'.tr(),
              style: KZ.pageTitle.copyWith(color: KZ.primary),
            ),
          ],
        ),
        KZIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
          tooltip: 'admin.notifications'.tr(),
          background: KZ.surfaceContainerLow,
          foreground: KZ.primary,
        ),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'admin.greeting'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: KZ.secondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'admin.overview'.tr(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: KZ.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCards(stats) {
    return Column(
      children: [
        Row(
          children: [
            // Today's Orders
            Expanded(
              child: KZCard(
                padding: const EdgeInsets.all(KZ.sp16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(KZ.sp8),
                          decoration: BoxDecoration(
                            color: KZ.primaryFixed.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(KZ.radiusMd),
                          ),
                          child: const Icon(
                            Icons.shopping_basket_outlined,
                            color: KZ.primary,
                            size: KZ.iconControl,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KZ.sp6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: KZ.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(KZ.radiusSm),
                          ),
                          child: Text(
                            '+${stats.todaysOrders > 0 ? ((stats.todaysOrders * 5)).toString() : '0'}%',
                            style: KZ.caption.copyWith(
                              color: KZ.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KZ.sp12),
                    Text('admin.todays_orders'.tr(), style: KZ.bodySmall),
                    const SizedBox(height: KZ.sp4),
                    Text(
                      '${stats.todaysOrders}',
                      style: KZ.display.copyWith(fontSize: 26),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: KZ.sp14),

            // Active Orders
            Expanded(
              child: KZCard(
                padding: const EdgeInsets.all(KZ.sp16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(KZ.sp8),
                          decoration: BoxDecoration(
                            color: KZ.primaryContainer.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(KZ.radiusMd),
                          ),
                          child: const Icon(
                            Icons.pending_actions_rounded,
                            color: KZ.primaryContainer,
                            size: KZ.iconControl,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KZ.sp8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: KZ.primaryContainer.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(KZ.radiusMd),
                          ),
                          child: Text(
                            'admin.live'.tr(),
                            style: KZ.caption.copyWith(
                              color: KZ.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KZ.sp12),
                    Text('orders.active'.tr(), style: KZ.bodySmall),
                    const SizedBox(height: KZ.sp4),
                    Text(
                      '${stats.activeOrders}',
                      style: KZ.display.copyWith(fontSize: 26),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KZ.sp14),

        // Total Revenue Card (Full Width)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [KZ.primaryContainer, KZ.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: KZ.primary.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'admin.revenue_today'.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.todaysRevenue.toStringAsFixed(0)} ${'common.egp'.tr()}',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'admin.live'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'admin.recent_orders'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KZ.onSurface,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/admin/orders'),
          style: TextButton.styleFrom(foregroundColor: KZ.primary),
          child: Text(
            'home.view_all'.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersList(
    BuildContext context,
    List<Order> recentOrders,
  ) {
    if (recentOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KZ.outlineVariant.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              'admin.no_orders_today'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KZ.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'admin.no_orders_today_sub'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentOrders.map((order) {
        final timeAgo = _formatTimeAgo(order.placedAt);
        final statusColor = _getStatusColor(order.status);
        final statusLabel = order.status.name.toUpperCase();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: KZ.outlineVariant.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Status Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: KZ.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(order.status),
                  color: KZ.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Order Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: KZ.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 12, color: KZ.secondary),
                    ),
                  ],
                ),
              ),

              // Price & Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.grandTotal.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: KZ.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return Icons.receipt_long;
      case OrderStatus.preparing:
        return Icons.soup_kitchen_rounded;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      case OrderStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return KZ.error;
      case OrderStatus.confirmed:
        return const Color(0xFF00ACC1);
      case OrderStatus.preparing:
        return KZ.primaryContainer;
      case OrderStatus.outForDelivery:
        return Colors.blue.shade700;
      case OrderStatus.delivered:
        return KZ.tertiary;
      case OrderStatus.cancelled:
        return Colors.grey.shade700;
      case OrderStatus.unknown:
        return Colors.grey.shade500;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24)
      return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }
}
