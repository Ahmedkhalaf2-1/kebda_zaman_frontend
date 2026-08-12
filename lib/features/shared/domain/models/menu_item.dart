import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item.freezed.dart';
part 'menu_item.g.dart';

/// Promotional badge shown on a menu item, per the VO3 catalog contract.
/// Backend sends the raw string ('BESTSELLER' / 'TOP_RATED' / null); unknown
/// values must parse to null rather than throw (see [menuItemBadgeFromApi]).
enum MenuItemBadge { bestseller, topRated }

/// Parses the backend's `badge` string into [MenuItemBadge]. Unknown or
/// missing values return null rather than throwing, since badge is
/// decorative and must never break menu parsing.
MenuItemBadge? menuItemBadgeFromApi(String? value) {
  switch (value) {
    case 'BESTSELLER':
      return MenuItemBadge.bestseller;
    case 'TOP_RATED':
      return MenuItemBadge.topRated;
    default:
      return null;
  }
}

/// Serializes [MenuItemBadge] back into the backend's raw string for admin
/// create/update requests. Inverse of [menuItemBadgeFromApi].
String? menuItemBadgeToApi(MenuItemBadge? badge) {
  switch (badge) {
    case MenuItemBadge.bestseller:
      return 'BESTSELLER';
    case MenuItemBadge.topRated:
      return 'TOP_RATED';
    case null:
      return null;
  }
}

/// Parses the backend's `calories` field, which may be an int, a
/// whole-number double, a numeric string, or null. Fractional and negative
/// values are rejected (return null) rather than silently truncated.
int? menuItemCaloriesFromApi(dynamic value) {
  if (value is int) {
    return value >= 0 ? value : null;
  }
  if (value is double) {
    return (value >= 0 && value == value.roundToDouble())
        ? value.toInt()
        : null;
  }
  if (value is String) {
    final asInt = int.tryParse(value);
    if (asInt != null) return asInt >= 0 ? asInt : null;
    final asDouble = double.tryParse(value);
    if (asDouble != null &&
        asDouble >= 0 &&
        asDouble == asDouble.roundToDouble()) {
      return asDouble.toInt();
    }
    return null;
  }
  return null;
}

/// Parses the backend's `compareAtPrice` field, which may be an int, a
/// double, a numeric string, or null. Negative and invalid values return
/// null rather than being coerced.
double? menuItemCompareAtPriceFromApi(dynamic value) {
  if (value is num) {
    return value >= 0 ? value.toDouble() : null;
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0) return parsed;
    return null;
  }
  return null;
}

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    required String categoryId,
    required String name,
    required String description,
    required String imageUrl,
    required double basePrice,
    /// The discounted price the customer actually pays, or null when the
    /// item has no active discount (always strictly less than [basePrice]
    /// when set — enforced server-side). Maps to the backend's `salePrice`
    /// JSON field (see `ApiMenuRepository._mapMenuItem`/
    /// `_buildMenuItemPayload`) — kept as `discountPrice` here since this
    /// field already existed under that name before the backend added
    /// `salePrice`; do not confuse with [compareAtPrice], a separate,
    /// purely cosmetic "was" price with opposite semantics.
    double? discountPrice,
    @Default(true) bool isAvailable,
    @Default(false) bool isFeatured,
    @Default(false) bool isBestSeller,
    @Default(15) int prepTimeMinutes,
    @Default([]) List<ModifierGroup> modifierGroups,
    @Default(0) int sortOrder,
    int? calories,
    double? compareAtPrice,
    MenuItemBadge? badge,
    @Default([]) List<MenuItem> oftenOrderedWith,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}

/// Locale-aware accessors for [MenuItem] product content. Falls back to the
/// other language when the preferred one is null, empty, or whitespace-only,
/// so the UI never shows a blank product name/description. Computed at
/// read-time (not cached) so switching locale rebuilds with the right text.
extension MenuItemLocalization on MenuItem {
  static String _pick(String? preferred, String? other, String fallback) {
    if (preferred != null && preferred.trim().isNotEmpty) return preferred;
    if (other != null && other.trim().isNotEmpty) return other;
    return fallback;
  }

  String localizedName(String languageCode) => languageCode == 'ar'
      ? _pick(nameAr, nameEn, name)
      : _pick(nameEn, nameAr, name);

  String localizedDescription(String languageCode) => languageCode == 'ar'
      ? _pick(descriptionAr, descriptionEn, description)
      : _pick(descriptionEn, descriptionAr, description);
}

@freezed
class ModifierGroup with _$ModifierGroup {
  const factory ModifierGroup({
    required String id,
    required String name,
    String? description,
    @Default(false) bool isRequired,
    @Default('SINGLE') String selectionType, // SINGLE, MULTIPLE, QUANTITY
    @Default(0) int minSelections,
    @Default(1) int maxSelections,
    @Default([]) List<ModifierOption> options,
    @Default(0) int sortOrder,
  }) = _ModifierGroup;

  factory ModifierGroup.fromJson(Map<String, dynamic> json) =>
      _$ModifierGroupFromJson(json);
}

@freezed
class ModifierOption with _$ModifierOption {
  const factory ModifierOption({
    required String id,
    required String name,
    String? description,
    String? image,
    @Default(0.0) double priceModifier,
    @Default(false) bool isDefault,
    @Default(true) bool isAvailable,
    @Default([]) List<ModifierGroup> nestedModifierGroups,
  }) = _ModifierOption;

  factory ModifierOption.fromJson(Map<String, dynamic> json) =>
      _$ModifierOptionFromJson(json);
}
