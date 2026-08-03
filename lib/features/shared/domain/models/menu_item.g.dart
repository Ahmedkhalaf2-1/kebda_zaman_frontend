// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuItemImpl _$$MenuItemImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemImpl(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 15,
      modifierGroups:
          (json['modifierGroups'] as List<dynamic>?)
              ?.map((e) => ModifierGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toInt(),
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      badge: $enumDecodeNullable(_$MenuItemBadgeEnumMap, json['badge']),
      oftenOrderedWith:
          (json['oftenOrderedWith'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nameAr: json['nameAr'] as String?,
      nameEn: json['nameEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
    );

Map<String, dynamic> _$$MenuItemImplToJson(_$MenuItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'basePrice': instance.basePrice,
      'discountPrice': instance.discountPrice,
      'isAvailable': instance.isAvailable,
      'isFeatured': instance.isFeatured,
      'isBestSeller': instance.isBestSeller,
      'prepTimeMinutes': instance.prepTimeMinutes,
      'modifierGroups': instance.modifierGroups,
      'sortOrder': instance.sortOrder,
      'calories': instance.calories,
      'compareAtPrice': instance.compareAtPrice,
      'badge': _$MenuItemBadgeEnumMap[instance.badge],
      'oftenOrderedWith': instance.oftenOrderedWith,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'descriptionAr': instance.descriptionAr,
      'descriptionEn': instance.descriptionEn,
    };

const _$MenuItemBadgeEnumMap = {
  MenuItemBadge.bestseller: 'bestseller',
  MenuItemBadge.topRated: 'topRated',
};

_$ModifierGroupImpl _$$ModifierGroupImplFromJson(Map<String, dynamic> json) =>
    _$ModifierGroupImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
      selectionType: json['selectionType'] as String? ?? 'SINGLE',
      minSelections: (json['minSelections'] as num?)?.toInt() ?? 0,
      maxSelections: (json['maxSelections'] as num?)?.toInt() ?? 1,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => ModifierOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ModifierGroupImplToJson(_$ModifierGroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isRequired': instance.isRequired,
      'selectionType': instance.selectionType,
      'minSelections': instance.minSelections,
      'maxSelections': instance.maxSelections,
      'options': instance.options,
      'sortOrder': instance.sortOrder,
    };

_$ModifierOptionImpl _$$ModifierOptionImplFromJson(Map<String, dynamic> json) =>
    _$ModifierOptionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      nestedModifierGroups:
          (json['nestedModifierGroups'] as List<dynamic>?)
              ?.map((e) => ModifierGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ModifierOptionImplToJson(
  _$ModifierOptionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'image': instance.image,
  'priceModifier': instance.priceModifier,
  'isDefault': instance.isDefault,
  'isAvailable': instance.isAvailable,
  'nestedModifierGroups': instance.nestedModifierGroups,
};
