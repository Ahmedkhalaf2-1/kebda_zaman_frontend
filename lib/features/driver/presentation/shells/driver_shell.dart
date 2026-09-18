import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/driver/presentation/widgets/driver_tracking_status_banner.dart';

/// The DRIVER role's whole app shell: two working destinations (current
/// orders, delivery history) plus an account/logout tab. A slim status
/// banner above [child] reflects [driverTrackingStatusProvider] whenever an
/// eligible delivery needs the driver's attention (permission needed,
/// acquiring GPS, or upload trouble) — hidden entirely once uploads are
/// flowing normally or no delivery is currently eligible for tracking.
class DriverShell extends ConsumerWidget {
  final Widget child;

  const DriverShell({super.key, required this.child});

  static const _tabs = [
    (
      path: '/driver/orders',
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping,
      label: 'driver_app.tab_orders',
    ),
    (
      path: '/driver/history',
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: 'driver_app.tab_history',
    ),
    (
      path: '/driver/account',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'driver_app.tab_account',
    ),
  ];

  int _currentIndex(String location) {
    // Longest-matching-prefix first so `/driver/orders/:id` (a pushed detail
    // route, not one of the three tab roots) still highlights the Orders
    // tab it was opened from, rather than falling through to History/Account.
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _currentIndex(location);

    return Scaffold(
      body: Column(
        children: [
          const DriverTrackingStatusBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: KZ.surface,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon, color: KZ.primary),
              label: tab.label.tr(),
            ),
        ],
      ),
    );
  }
}
