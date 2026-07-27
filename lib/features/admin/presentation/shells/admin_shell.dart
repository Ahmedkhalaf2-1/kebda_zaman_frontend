import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.path;
    final isMobile = MediaQuery.of(context).size.width < 600;

    int calculateSelectedIndex(String location) {
      if (location.startsWith('/admin/dashboard')) return 0;
      if (location.startsWith('/admin/orders')) return 1;
      if (location.startsWith('/admin/menu')) return 2;
      if (location.startsWith('/admin/offers')) return 3;
      if (location.startsWith('/admin/notifications')) return 4;
      if (location.startsWith('/admin/settings')) return 5;
      return 0;
    }

    void onDestinationSelected(int index) {
      switch (index) {
        case 0:
          context.go('/admin/dashboard');
          break;
        case 1:
          context.go('/admin/orders');
          break;
        case 2:
          context.go('/admin/menu');
          break;
        case 3:
          context.go('/admin/offers');
          break;
        case 4:
          context.go('/admin/notifications');
          break;
        case 5:
          context.go('/admin/settings');
          break;
      }
    }

    final selectedIndex = calculateSelectedIndex(location);

    if (isMobile) {
      const activeColor = KZ.primary;
      const inactiveColor = KZ.secondary;

      final navItems = [
        (
          icon: Icons.grid_view_rounded,
          activeIcon: Icons.grid_view_rounded,
          label: 'nav.dashboard'.tr(),
        ),
        (
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'nav.orders'.tr(),
        ),
        (
          icon: Icons.restaurant_menu_outlined,
          activeIcon: Icons.restaurant_menu,
          label: 'nav.menu'.tr(),
        ),
        (
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications_rounded,
          label: 'Notifications',
        ),
        (
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'nav.settings'.tr(),
        ),
      ];

      return Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: KZ.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = selectedIndex == index;

                return InkWell(
                  onTap: () => onDestinationSelected(index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFEBE3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? activeColor : inactiveColor,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: Text('nav.dashboard'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: Text('nav.orders'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.restaurant_menu_outlined),
                selectedIcon: const Icon(Icons.restaurant_menu),
                label: Text('nav.menu'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.local_offer_outlined),
                selectedIcon: const Icon(Icons.local_offer),
                label: Text('nav.offers'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.notifications_outlined),
                selectedIcon: const Icon(Icons.notifications_rounded),
                label: const Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text('nav.settings'.tr()),
              ),
            ],
            leading: Column(
              children: [
                const SizedBox(height: 16),
                Icon(
                  Icons.admin_panel_settings,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text('Admin', style: theme.textTheme.labelMedium),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
