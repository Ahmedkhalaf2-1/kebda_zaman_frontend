import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/features/admin/domain/models/order_notification.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_notification_notifier.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

class AdminNotificationCenterScreen extends ConsumerWidget {
  const AdminNotificationCenterScreen({super.key});

  static const Color primaryColor = KZ.primary;
  static const Color surfaceBg = KZ.surface;
  static const Color onSurfaceColor = KZ.onSurface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(adminOrderNotificationProvider);

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: primaryColor),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: primaryColor),
            onSelected: (value) async {
              final notifier = ref.read(
                adminOrderNotificationProvider.notifier,
              );
              String? error;
              if (value == 'mark_all_read') {
                error = await notifier.markAllAsRead();
              } else if (value == 'clear_all') {
                error = await notifier.clearAll();
              }
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed: $error')));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Mark All as Read'),
              ),
              PopupMenuItem(value: 'clear_all', child: Text('Clear All')),
            ],
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: primaryColor)),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Could not load notifications',
                style: TextStyle(color: onSurfaceColor, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: () =>
                    ref.read(adminOrderNotificationProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (notifications) {
          final sorted = [...notifications]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (sorted.isEmpty) {
            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () =>
                  ref.read(adminOrderNotificationProvider.notifier).refresh(),
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () =>
                ref.read(adminOrderNotificationProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: sorted.length,
              itemBuilder: (context, index) =>
                  _NotificationCard(notification: sorted[index]),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final OrderNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final error = await ref
            .read(adminOrderNotificationProvider.notifier)
            .markAsRead(notification.id);
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to mark as read: $error')),
          );
        }
        if (context.mounted) {
          context.push('/admin/orders/${notification.orderId}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFFFF3EE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? KZ.outlineVariant.withValues(alpha: 0.25)
                : AdminNotificationCenterScreen.primaryColor.withValues(
                    alpha: 0.25,
                  ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.isRead
                    ? Colors.transparent
                    : AdminNotificationCenterScreen.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.customerName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: AdminNotificationCenterScreen.onSurfaceColor,
                          ),
                        ),
                      ),
                      Text(
                        formatRelativeTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: KZ.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'New order #${notification.orderNumber} • ${notification.totalAmount.toStringAsFixed(0)} EGP',
                    style: const TextStyle(fontSize: 13, color: KZ.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
