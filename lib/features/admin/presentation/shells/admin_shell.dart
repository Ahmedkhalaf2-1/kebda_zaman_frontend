import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
import 'package:kebda_zaman/core/widgets/kz_brand_logo.dart';
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

  /// Information architecture: Overview / Orders & Operations / Catalog /
  /// Marketing / People / Restaurant — approved 2026 IA restructuring. Both
  /// the desktop sidebar and mobile drawer render from this single list, so
  /// they can never drift apart.
  List<_AdminNavGroup> _adminGroups() => [
    _AdminNavGroup(
      header: 'nav_group.overview'.tr(),
      entries: [
        _AdminNavEntry(
          icon: Icons.grid_view_rounded,
          activeIcon: Icons.grid_view_rounded,
          label: 'nav.dashboard'.tr(),
          path: '/admin/dashboard',
        ),
      ],
    ),
    _AdminNavGroup(
      header: 'nav_group.orders_operations'.tr(),
      entries: [
        _AdminNavEntry(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'nav.orders'.tr(),
          path: '/admin/orders',
        ),
        _AdminNavEntry(
          icon: Icons.tune_rounded,
          activeIcon: Icons.tune_rounded,
          label: 'nav.order_settings'.tr(),
          path: '/admin/order-settings',
        ),
        _AdminNavEntry(
          icon: Icons.schedule_outlined,
          activeIcon: Icons.schedule_rounded,
          label: 'nav.working_hours'.tr(),
          path: '/admin/working-hours',
        ),
      ],
    ),
    _AdminNavGroup(
      header: 'nav_group.catalog'.tr(),
      entries: [
        _AdminNavEntry(
          icon: Icons.restaurant_menu_outlined,
          activeIcon: Icons.restaurant_menu,
          label: 'nav.menu_items'.tr(),
          path: '/admin/menu',
        ),
      ],
    ),
    _AdminNavGroup(
      header: 'nav_group.marketing'.tr(),
      entries: [
        _AdminNavEntry(
          icon: Icons.local_offer_outlined,
          activeIcon: Icons.local_offer,
          label: 'nav.promo_codes'.tr(),
          path: '/admin/offers',
        ),
        _AdminNavEntry(
          icon: Icons.campaign_outlined,
          activeIcon: Icons.campaign_rounded,
          label: 'nav.notifications'.tr(),
          path: '/admin/notifications',
        ),
      ],
    ),
    _AdminNavGroup(
      header: 'nav_group.people'.tr(),
      entries: [
        _AdminNavEntry(
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups,
          label: 'customers.title'.tr(),
          path: '/admin/customers',
        ),
        _AdminNavEntry(
          icon: Icons.people_alt_outlined,
          activeIcon: Icons.people_alt,
          label: 'staff.title'.tr(),
          path: '/admin/staff',
        ),
      ],
    ),
    _AdminNavGroup(
      header: 'nav_group.restaurant'.tr(),
      entries: [
        _AdminNavEntry(
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront,
          label: 'nav.restaurant_profile'.tr(),
          path: '/admin/restaurant-profile',
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
      backgroundColor: KZ.surfaceContainerLow,
      body: Row(
        children: [
          _AdminSidebar(
            groups: groups,
            currentPath: location,
            onNavigate: navigateTo,
            onLogout: onLogout,
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: KZ.outlineVariant,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// The compact brand block shown at the top of both the desktop sidebar and
/// the mobile drawer — the shell's one source of Kebda Zaman branding, so
/// individual screens never need to repeat a logo/name block of their own.
class _ShellBrandHeader extends StatelessWidget {
  const _ShellBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KZ.sp16,
        KZ.sp20,
        KZ.sp16,
        KZ.sp16,
      ),
      child: Row(
        children: [
          const KZBrandLogo(width: 32, height: 32),
          const SizedBox(width: KZ.sp10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'app_name'.tr(),
                  style: KZ.itemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'admin.shell_badge'.tr(),
                  style: KZ.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders every group + destination from the shared nav model. Used
/// verbatim by both the desktop sidebar and the mobile drawer so the two
/// surfaces can never visually drift apart.
class _ShellNavList extends StatelessWidget {
  final List<_AdminNavGroup> groups;
  final String currentPath;
  final ValueChanged<String> onNavigate;

  const _ShellNavList({
    required this.groups,
    required this.currentPath,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: KZ.sp8),
      children: [
        for (int g = 0; g < groups.length; g++) ...[
          if (groups[g].header != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                KZ.sp12,
                g == 0 ? KZ.sp4 : KZ.sp24,
                KZ.sp12,
                KZ.sp8,
              ),
              child: Text(
                groups[g].header!.toUpperCase(),
                style: KZ.label.copyWith(
                  color: KZ.onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          for (final entry in groups[g].entries)
            _SidebarTile(
              entry: entry,
              selected: currentPath.startsWith(entry.path),
              onTap: () => onNavigate(entry.path),
            ),
        ],
        const SizedBox(height: KZ.sp8),
      ],
    );
  }
}

/// Bottom-of-shell logout action — visually separated from primary
/// navigation by a hairline divider and neutral (non-competing) styling, so
/// it stays easy to find without reading as another destination.
class _ShellLogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _ShellLogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, color: KZ.outlineVariant),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onLogout,
            hoverColor: KZ.error.withValues(alpha: 0.05),
            splashColor: KZ.error.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.sp16,
                vertical: KZ.sp14,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: KZ.secondary,
                    size: KZ.iconControl,
                  ),
                  const SizedBox(width: KZ.sp12),
                  Text(
                    'profile.logout'.tr(),
                    style: KZ.body.copyWith(color: KZ.secondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
      width: 248,
      color: KZ.surface,
      child: Column(
        children: [
          const _ShellBrandHeader(),
          Expanded(
            child: _ShellNavList(
              groups: groups,
              currentPath: currentPath,
              onNavigate: onNavigate,
            ),
          ),
          _ShellLogoutButton(onLogout: onLogout),
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
            hoverColor: KZ.surfaceContainerLow,
            splashColor: KZ.primary.withValues(alpha: 0.08),
            highlightColor: KZ.primary.withValues(alpha: 0.06),
            child: AnimatedContainer(
              duration: KZMotion.durationFor(context, KZMotion.fast),
              curve: KZMotion.stateChange,
              constraints: const BoxConstraints(
                minHeight: KZ.iconTapTargetMin,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? KZ.primary.withValues(alpha: 0.09)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(KZ.radiusMd),
                border: Border(
                  left: BorderSide(
                    color: selected ? KZ.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
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
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _currentLabel(),
          style: KZ.pageTitle.copyWith(fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      drawer: Drawer(
        backgroundColor: KZ.surface,
        child: SafeArea(
          child: Column(
            children: [
              const _ShellBrandHeader(),
              Expanded(
                child: _ShellNavList(
                  groups: groups,
                  currentPath: currentPath,
                  onNavigate: (path) {
                    Navigator.of(context).pop();
                    onNavigate(path);
                  },
                ),
              ),
              _ShellLogoutButton(onLogout: onLogout),
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
                color: KZ.onSurface.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            border: const Border(
              top: BorderSide(color: KZ.outlineVariant),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.sp12,
            vertical: KZ.sp8,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: KZ.primary,
                      size: KZ.iconAction,
                    ),
                    const SizedBox(height: KZ.sp4),
                    Text(
                      entry.label.tr(),
                      style: KZ.navigationLabel.copyWith(
                        color: KZ.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                InkWell(
                  onTap: onLogout,
                  borderRadius: BorderRadius.circular(KZ.radiusLg),
                  hoverColor: KZ.error.withValues(alpha: 0.05),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: KZ.sp16,
                      vertical: KZ.sp8,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: KZ.secondary,
                      size: KZ.iconAction,
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
      backgroundColor: KZ.surfaceContainerLow,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: KZ.surface,
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            labelType: NavigationRailLabelType.all,
            useIndicator: true,
            indicatorColor: KZ.primary.withValues(alpha: 0.09),
            selectedIconTheme: const IconThemeData(color: KZ.primary),
            unselectedIconTheme: const IconThemeData(color: KZ.secondary),
            selectedLabelTextStyle: KZ.navigationLabel.copyWith(
              color: KZ.primary,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelTextStyle: KZ.navigationLabel,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: Text(entry.label.tr()),
              ),
            ],
            leading: Column(
              children: [
                const SizedBox(height: KZ.sp16),
                const KZBrandLogo(width: 32, height: 32),
                const SizedBox(height: KZ.sp8),
                Text('admin.shell_badge'.tr(), style: KZ.caption),
                const SizedBox(height: KZ.sp16),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: KZ.sp16),
                  child: IconButton(
                    onPressed: onLogout,
                    tooltip: 'profile.logout'.tr(),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: KZ.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: KZ.outlineVariant,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
