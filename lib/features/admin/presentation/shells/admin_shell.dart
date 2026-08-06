import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
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

/// A labeled group of nav entries in the desktop sidebar / mobile drawer. A
/// `null` [header] renders the entries at the top level with no group label
/// (Dashboard, Orders, Customers, Settings — each a standalone destination
/// per the Phase 8 information architecture).
class _AdminNavGroup {
  final String? header;
  final List<_AdminNavEntry> entries;

  const _AdminNavGroup({this.header, required this.entries});
}

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  static const _cashierEntry = _AdminNavEntry(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long,
    label: 'nav.orders',
    path: '/admin/orders',
  );

  List<_AdminNavGroup> _adminGroups() => [
    _AdminNavGroup(
      entries: [
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
      ],
    ),
    _AdminNavGroup(
      header: 'nav_group.catalog'.tr(),
      entries: [
        _AdminNavEntry(
          icon: Icons.restaurant_menu_outlined,
          activeIcon: Icons.restaurant_menu,
          label: 'nav.menu'.tr(),
          path: '/admin/menu',
        ),
        _AdminNavEntry(
          icon: Icons.local_offer_outlined,
          activeIcon: Icons.local_offer,
          label: 'nav.promo_codes'.tr(),
          path: '/admin/offers',
        ),
      ],
    ),
    _AdminNavGroup(
      entries: [
        _AdminNavEntry(
          icon: Icons.campaign_outlined,
          activeIcon: Icons.campaign_rounded,
          label: 'nav_group.marketing'.tr(),
          path: '/admin/notifications',
        ),
      ],
    ),
    _AdminNavGroup(
      header: 'nav_group.operations'.tr(),
      entries: [
        _AdminNavEntry(
          icon: Icons.people_alt_outlined,
          activeIcon: Icons.people_alt,
          label: 'staff.title'.tr(),
          path: '/admin/staff',
        ),
      ],
    ),
    _AdminNavGroup(
      entries: [
        _AdminNavEntry(
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups,
          label: 'customers.title'.tr(),
          path: '/admin/customers',
        ),
        _AdminNavEntry(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'admin_settings.center_title'.tr(),
          path: '/admin/settings',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final role = ref.watch(authNotifierProvider).user?.role;
    final isCashier = role == 'CASHIER';

    Future<void> onLogout() async {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }

    // CASHIER only ever reaches Orders Management inside /admin — every
    // owner-only section is hidden from the nav entirely, on top of the
    // router-level redirect guard that blocks a manual navigation to them.
    if (isCashier) {
      return _CashierShell(onLogout: onLogout, child: child);
    }

    final groups = _adminGroups();
    final flatEntries = groups.expand((g) => g.entries).toList();
    int selectedIndex = flatEntries.indexWhere(
      (e) => location.startsWith(e.path),
    );
    if (selectedIndex < 0) selectedIndex = 0;

    void navigateTo(String path) => context.go(path);

    if (isMobile) {
      return _AdminMobileShell(
        groups: groups,
        currentPath: location,
        onNavigate: navigateTo,
        onLogout: onLogout,
        child: child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _AdminSidebar(
            groups: groups,
            currentPath: location,
            onNavigate: navigateTo,
            onLogout: onLogout,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Desktop/tablet: a fixed grouped sidebar with section labels — replaces
/// the flat `NavigationRail` now that there are too many destinations for
/// an unlabeled rail to stay scannable.
class _AdminSidebar extends StatelessWidget {
  final List<_AdminNavGroup> groups;
  final String currentPath;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const _AdminSidebar({
    required this.groups,
    required this.currentPath,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: KZ.surface,
      child: Column(
        children: [
          const SizedBox(height: KZ.sp20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: KZ.primary,
                size: 28,
              ),
              const SizedBox(width: KZ.sp8),
              Text('admin.title'.tr(), style: KZ.sectionTitle),
            ],
          ),
          const SizedBox(height: KZ.sp16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: KZ.sp8),
              children: [
                for (final group in groups) ...[
                  if (group.header != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KZ.sp12,
                        KZ.sp16,
                        KZ.sp12,
                        KZ.sp6,
                      ),
                      child: Text(
                        group.header!,
                        style: KZ.label.copyWith(letterSpacing: 0.6),
                      ),
                    ),
                  ],
                  for (final entry in group.entries)
                    _SidebarTile(
                      entry: entry,
                      selected: currentPath.startsWith(entry.path),
                      onTap: () => onNavigate(entry.path),
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(KZ.sp12),
            child: TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, color: KZ.secondary),
              label: Text(
                'profile.logout'.tr(),
                style: const TextStyle(color: KZ.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final _AdminNavEntry entry;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: KZPressableScale(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(KZ.radiusMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            onTap: onTap,
            child: AnimatedContainer(
              duration: KZMotion.durationFor(context, KZMotion.fast),
              curve: KZMotion.stateChange,
              decoration: BoxDecoration(
                color: selected
                    ? KZ.primaryFixed.withValues(alpha: 0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(KZ.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.sp12,
                vertical: KZ.sp10,
              ),
              child: Row(
                children: [
                  Icon(
                    selected ? entry.activeIcon : entry.icon,
                    size: KZ.iconControl,
                    color: selected ? KZ.primary : KZ.secondary,
                  ),
                  const SizedBox(width: KZ.sp12),
                  Expanded(
                    child: Text(
                      entry.label,
                      style: KZ.body.copyWith(
                        color: selected ? KZ.primary : KZ.onSurface,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile: a compact drawer reachable via a slim top bar — replaces the
/// old flat bottom-navigation bar, which had room for a handful of icons but
/// not the grouped Catalog/Marketing/Operations destinations Phase 8 adds.
class _AdminMobileShell extends StatelessWidget {
  final Widget child;
  final List<_AdminNavGroup> groups;
  final String currentPath;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const _AdminMobileShell({
    required this.child,
    required this.groups,
    required this.currentPath,
    required this.onNavigate,
    required this.onLogout,
  });

  String _currentLabel() {
    for (final group in groups) {
      for (final entry in group.entries) {
        if (currentPath.startsWith(entry.path)) return entry.label;
      }
    }
    return 'admin.title'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _currentLabel(),
          style: KZ.pageTitle.copyWith(fontSize: 18),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: KZ.sp12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color: KZ.primary,
                    size: 28,
                  ),
                  const SizedBox(width: KZ.sp8),
                  Text('admin.title'.tr(), style: KZ.sectionTitle),
                ],
              ),
              const SizedBox(height: KZ.sp12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: KZ.sp8),
                  children: [
                    for (final group in groups) ...[
                      if (group.header != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            KZ.sp12,
                            KZ.sp16,
                            KZ.sp12,
                            KZ.sp6,
                          ),
                          child: Text(
                            group.header!,
                            style: KZ.label.copyWith(letterSpacing: 0.6),
                          ),
                        ),
                      for (final entry in group.entries)
                        _SidebarTile(
                          entry: entry,
                          selected: currentPath.startsWith(entry.path),
                          onTap: () {
                            Navigator.of(context).pop();
                            onNavigate(entry.path);
                          },
                        ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(KZ.sp12),
                child: TextButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded, color: KZ.secondary),
                  label: Text(
                    'profile.logout'.tr(),
                    style: const TextStyle(color: KZ.secondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}

/// CASHIER's admin experience stays exactly the pre-Phase-8 single-destination
/// layout — Orders Management plus logout, nothing else — since CASHIER never
/// gains any of the new sections and a full sidebar/drawer would be pure
/// clutter for one destination.
class _CashierShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onLogout;

  const _CashierShell({required this.child, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    const entry = AdminShell._cashierEntry;

    if (isMobile) {
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
              top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long, color: KZ.primary, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      entry.label.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: KZ.primary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: onLogout,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Icon(
                      Icons.logout_rounded,
                      color: KZ.secondary,
                      size: 22,
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
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: Text(entry.label.tr()),
              ),
            ],
            leading: Column(
              children: [
                const SizedBox(height: 16),
                const Icon(
                  Icons.admin_panel_settings,
                  color: KZ.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text('Admin', style: Theme.of(context).textTheme.labelMedium),
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
