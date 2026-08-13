import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// Localized label for a manually-assigned [MenuItemBadge]. Independent of
/// `isFeatured`/`isBestSeller` — callers must guard with
/// `if (item.badge != null)` before using this.
String menuItemBadgeLabel(MenuItemBadge badge) {
  switch (badge) {
    case MenuItemBadge.bestseller:
      return 'menu.badge_bestseller'.tr();
    case MenuItemBadge.topRated:
      return 'menu.badge_top_rated'.tr();
  }
}

/// Compact badge chip for a manually-assigned [MenuItemBadge]. Shared across
/// every customer-facing menu-item card so the badge presentation never
/// drifts between Menu, Home, and Search.
class MenuItemBadgeChip extends StatelessWidget {
  final MenuItemBadge badge;

  const MenuItemBadgeChip({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: KZ.primary,
        borderRadius: BorderRadius.circular(KZ.radiusSm),
      ),
      child: Text(
        menuItemBadgeLabel(badge),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Crossed-out original price. Callers are responsible for only rendering
/// this when `compareAtPrice != null && compareAtPrice > basePrice` — this
/// widget just formats and strikes through whatever price it's given.
class MenuItemComparePriceText extends StatelessWidget {
  final double compareAtPrice;
  final TextStyle? style;

  const MenuItemComparePriceText({
    super.key,
    required this.compareAtPrice,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatCurrency(compareAtPrice, locale: context.locale),
      style: (style ?? KZ.bodySmall).copyWith(
        decoration: TextDecoration.lineThrough,
        fontSize: 11,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Quiet secondary calorie readout — callers only render this when
/// `calories != null`.
class MenuItemCaloriesText extends StatelessWidget {
  final int calories;
  final TextStyle? style;

  const MenuItemCaloriesText({super.key, required this.calories, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      'menu.calories'.tr(namedArgs: {'count': '$calories'}),
      style: (style ?? KZ.bodySmall).copyWith(color: KZ.outline, fontSize: 11),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
