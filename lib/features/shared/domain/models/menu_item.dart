import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item.freezed.dart';
part 'menu_item.g.dart';

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    required String categoryId,
    required String name,
    required String description,
    required String imageUrl,
    required double basePrice,
    double? discountPrice,
    @Default(true) bool isAvailable,
    @Default(false) bool isFeatured,
    @Default(false) bool isBestSeller,
    @Default(15) int prepTimeMinutes,
    @Default([]) List<ModifierGroup> modifierGroups,
    @Default(0) int sortOrder,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
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
