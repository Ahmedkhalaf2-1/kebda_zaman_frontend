import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kebda_zaman/core/responsive/responsive_breakpoints.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

class CustomerShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerShell({super.key, required this.navigationShell});

  static const Color primaryColor = KZ.primary;
  static const Color unselectedColor = Color(0xFF6E6E6E);
  static const Color backgroundColor = KZ.surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == currentIndex,
                );
              },
              backgroundColor: backgroundColor,
              indicatorColor: primaryColor.withValues(alpha: 0.15),
              selectedIconTheme: const IconThemeData(
                color: primaryColor,
                size: 26,
              ),
              unselectedIconTheme: const IconThemeData(
                color: unselectedColor,
                size: 24,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                fontSize: 13,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: unselectedColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                fontSize: 13,
              ),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kebda Zaman',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text('nav.home'.tr(context: context)),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.flatware_outlined),
                  selectedIcon: const Icon(Icons.flatware),
                  label: Text('nav.menu'.tr(context: context)),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  selectedIcon: const Icon(Icons.receipt_long),
                  label: Text('nav.orders'.tr(context: context)),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: Text('nav.profile'.tr(context: context)),
                ),
              ],
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: Color(0xFFECE7E1),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: backgroundColor,
          border: Border(top: BorderSide(color: Color(0xFFECE7E1), width: 1.0)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GNav(
              selectedIndex: currentIndex,
              onTabChange: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == currentIndex,
                );
              },
              gap: 8,
              color: unselectedColor,
              // Active tab reads as the same solid-primary/white treatment
              // as the floating add-to-cart button, not a light tint —
              // white icon+label on a solid primary pill.
              activeColor: Colors.white,
              iconSize: 24,
              tabBackgroundColor: primaryColor,
              tabBorderRadius: 100,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Colors.white,
              ),
              tabs: [
                GButton(
                  icon: Icons.home_outlined,
                  text: 'nav.home'.tr(context: context),
                ),
                GButton(
                  icon: Icons.flatware_outlined,
                  text: 'nav.menu'.tr(context: context),
                ),
                GButton(
                  icon: Icons.receipt_long_outlined,
                  text: 'nav.orders'.tr(context: context),
                ),
                GButton(
                  icon: Icons.person_outline,
                  text: 'nav.profile'.tr(context: context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
