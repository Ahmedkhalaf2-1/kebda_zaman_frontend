// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartImpl _$$CartImplFromJson(Map<String, dynamic> json) => _$CartImpl(
  id: json['id'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  promoCodeId: json['promoCodeId'] as String?,
  loyaltyPointsApplied: (json['loyaltyPointsApplied'] as num?)?.toInt() ?? 0,
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
  discountTotal: (json['discountTotal'] as num?)?.toDouble() ?? 0.0,
  taxTotal: (json['taxTotal'] as num?)?.toDouble() ?? 0.0,
  grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$CartImplToJson(_$CartImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'items': instance.items,
      'promoCodeId': instance.promoCodeId,
      'loyaltyPointsApplied': instance.loyaltyPointsApplied,
      'deliveryFee': instance.deliveryFee,
      'subtotal': instance.subtotal,
      'discountTotal': instance.discountTotal,
      'taxTotal': instance.taxTotal,
      'grandTotal': instance.grandTotal,
    };

_$CartItemImpl _$$CartItemImplFromJson(Map<String, dynamic> json) =>
    _$CartItemImpl(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      selectedOptions:
          (json['selectedOptions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          const {},
      nestedSelections:
          (json['nestedSelections'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                  k,
                  (e as List<dynamic>).map((e) => e as String).toList(),
                ),
              ),
            ),
          ) ??
          const {},
      extraQuantities:
          (json['extraQuantities'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      removedIngredients:
          (json['removedIngredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      specialInstructions: json['specialInstructions'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$$CartItemImplToJson(_$CartItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menuItemId': instance.menuItemId,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'basePrice': instance.basePrice,
      'quantity': instance.quantity,
      'selectedOptions': instance.selectedOptions,
      'nestedSelections': instance.nestedSelections,
      'extraQuantities': instance.extraQuantities,
      'removedIngredients': instance.removedIngredients,
      'specialInstructions': instance.specialInstructions,
      'unitPrice': instance.unitPrice,
      'lineTotal': instance.lineTotal,
      'isAvailable': instance.isAvailable,
    };
