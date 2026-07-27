import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

class DashboardStats {
  final int todaysOrders;
  final double todaysRevenue;
  final int pendingOrders;
  final int activeOrders;
  final int completedOrders;
  final List<Order> recentOrders;
  final List<MenuItemStats> bestSellingItems;
  final List<MenuItemStats> lowPerformingItems;
  final List<MenuItem> notYetOrderedItems;

  DashboardStats({
    required this.todaysOrders,
    required this.todaysRevenue,
    required this.pendingOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.recentOrders,
    required this.bestSellingItems,
    required this.lowPerformingItems,
    required this.notYetOrderedItems,
  });
}

class MenuItemStats {
  final MenuItem item;
  final int quantitySold;

  MenuItemStats(this.item, this.quantitySold);
}

class AdminAnalyticsRepository {
  final Ref ref;

  AdminAnalyticsRepository(this.ref);

  Future<DashboardStats> getDashboardStats() async {
    final orderRepo = ref.read(orderRepositoryProvider);
    final menuRepo = ref.read(menuRepositoryProvider);

    final ordersResult = await orderRepo.getAllOrders();
    final itemsResult = await menuRepo.getMenuItems();

    final allOrders = ordersResult.fold((f) => throw f, (r) => r);
    final allItems = itemsResult.fold((l) => <MenuItem>[], (r) => r);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int todaysOrders = 0;
    double todaysRevenue = 0.0;
    int pendingCount = 0;
    int activeCount = 0;
    int completedCount = 0;

    for (var order in allOrders) {
      final orderDate = DateTime(
        order.placedAt.year,
        order.placedAt.month,
        order.placedAt.day,
      );
      final isToday = orderDate.isAtSameMomentAs(today);

      if (isToday) {
        todaysOrders++;
        if (order.status != OrderStatus.cancelled) {
          todaysRevenue += order.grandTotal;
        }
      }

      if (order.status == OrderStatus.pending) {
        pendingCount++;
      }

      if (order.status == OrderStatus.pending ||
          order.status == OrderStatus.confirmed ||
          order.status == OrderStatus.preparing ||
          order.status == OrderStatus.outForDelivery) {
        activeCount++;
      }

      if (order.status == OrderStatus.delivered) {
        if (isToday) {
          completedCount++;
        }
      }
    }

    final sortedOrders = List<Order>.from(allOrders)
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    final recentOrders = sortedOrders.take(5).toList();

    final Map<String, int> itemSales = {};
    for (var item in allItems) {
      itemSales[item.id] = 0;
    }

    for (var order in allOrders) {
      if (order.status != OrderStatus.cancelled) {
        for (var orderItem in order.items) {
          if (itemSales.containsKey(orderItem.menuItemId)) {
            itemSales[orderItem.menuItemId] =
                itemSales[orderItem.menuItemId]! + orderItem.quantity;
          }
        }
      }
    }

    final soldItems = <MenuItemStats>[];
    final notYetOrdered = <MenuItem>[];

    for (var item in allItems) {
      final qty = itemSales[item.id] ?? 0;
      if (qty > 0) {
        soldItems.add(MenuItemStats(item, qty));
      } else {
        notYetOrdered.add(item);
      }
    }

    soldItems.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    final bestSelling = soldItems.take(5).toList();
    final lowPerforming = soldItems.reversed.take(5).toList();

    return DashboardStats(
      todaysOrders: todaysOrders,
      todaysRevenue: todaysRevenue,
      pendingOrders: pendingCount,
      activeOrders: activeCount,
      completedOrders: completedCount,
      recentOrders: recentOrders,
      bestSellingItems: bestSelling,
      lowPerformingItems: lowPerforming,
      notYetOrderedItems: notYetOrdered,
    );
  }
}

final adminAnalyticsRepositoryProvider = Provider<AdminAnalyticsRepository>((
  ref,
) {
  return AdminAnalyticsRepository(ref);
});
