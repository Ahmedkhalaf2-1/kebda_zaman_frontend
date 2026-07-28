import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';

class _AdminNavEntry {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _AdminNavEntry({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.path;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final role = ref.watch(authNotifierProvider).user?.role;
    final isCashier = role == 'CASHIER';

    // A cashier only ever sees Orders Management — every owner-only section
    // (metrics dashboard, menu, offers, notifications, settings, staff) is
    // hidden from the nav entirely, on top of the router-level redirect
    // guard that blocks a manual navigation to those paths.
    final entries = <_AdminNavEntry>[
      if (!isCashier)
        _AdminNavEntry(
          icon: Icons.grid_view_rounded,
          activeIcon: Icons.grid_view_rounded,
          label: 'nav.dashboard'.tr(),
          path: '/admin/dashboard',
        ),
      _AdminNavEntry(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'nav.orders'.tr(),
        path: '/admin/orders',
      ),
      if (!isCashier) ...[
        _AdminNavEntry(
          icon: Icons.restaurant_menu_outlined,
          activeIcon: Icons.restaurant_menu,
          label: 'nav.menu'.tr(),
          path: '/admin/menu',
        ),
        _AdminNavEntry(
          icon: Icons.local_offer_outlined,
          activeIcon: Icons.local_offer,
          label: 'nav.offers'.tr(),
          path: '/admin/offers',
        ),
        _AdminNavEntry(
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications_rounded,
          label: 'nav.notifications'.tr(),
          path: '/admin/notifications',
        ),
        _AdminNavEntry(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'nav.settings'.tr(),
          path: '/admin/settings',
        ),
        _AdminNavEntry(
          icon: Icons.people_alt_outlined,
          activeIcon: Icons.people_alt,
          label: 'staff.title'.tr(),
          path: '/admin/staff',
        ),
        _AdminNavEntry(
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups,
          label: 'customers.title'.tr(),
          path: '/admin/customers',
        ),
      ],
    ];

    int selectedIndex = entries.indexWhere((e) => location.startsWith(e.path));
    if (selectedIndex < 0) selectedIndex = 0;

    void onDestinationSelected(int index) {
      context.go(entries[index].path);
    }

    Future<void> onLogout() async {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }

    if (isMobile) {
      const activeColor = KZ.primary;
      const inactiveColor = KZ.secondary;

      return Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: KZ.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...List.generate(entries.length, (index) {
                  final item = entries[index];
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
                InkWell(
                  onTap: onLogout,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: inactiveColor,
                          size: 22,
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ],
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
            destinations: entries
                .map(
                  (e) => NavigationRailDestination(
                    icon: Icon(e.icon),
                    selectedIcon: Icon(e.activeIcon),
                    label: Text(e.label),
                  ),
                )
                .toList(),
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
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    onPressed: onLogout,
                    tooltip: 'profile.logout'.tr(),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
