// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KitchenOrderImpl _$$KitchenOrderImplFromJson(Map<String, dynamic> json) =>
    _$KitchenOrderImpl(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      deliveryMethod: $enumDecode(
        _$FulfillmentTypeEnumMap,
        json['deliveryMethod'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => KitchenOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$KitchenOrderImplToJson(_$KitchenOrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'deliveryMethod': _$FulfillmentTypeEnumMap[instance.deliveryMethod]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'items': instance.items,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.outForDelivery: 'outForDelivery',
  OrderStatus.delivered: 'delivered',
  OrderStatus.readyForPickup: 'readyForPickup',
  OrderStatus.pickedUp: 'pickedUp',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.unknown: 'unknown',
};

const _$FulfillmentTypeEnumMap = {
  FulfillmentType.delivery: 'delivery',
  FulfillmentType.pickup: 'pickup',
};

_$KitchenOrderItemImpl _$$KitchenOrderItemImplFromJson(
  Map<String, dynamic> json,
) => _$KitchenOrderItemImpl(
  id: json['id'] as String,
  menuItemId: json['menuItemId'] as String?,
  nameAr: json['nameAr'] as String,
  nameEn: json['nameEn'] as String,
  imageUrl: json['imageUrl'] as String?,
  selectedVariant: json['selectedVariant'] == null
      ? null
      : KitchenCustomizationSnapshot.fromJson(
          json['selectedVariant'] as Map<String, dynamic>,
        ),
  selectedAddons:
      (json['selectedAddons'] as List<dynamic>?)
          ?.map(
            (e) => KitchenCustomizationSnapshot.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
  quantity: (json['quantity'] as num).toInt(),
  specialInstructions: json['specialInstructions'] as String?,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
);

Map<String, dynamic> _$$KitchenOrderItemImplToJson(
  _$KitchenOrderItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'menuItemId': instance.menuItemId,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'imageUrl': instance.imageUrl,
  'selectedVariant': instance.selectedVariant,
  'selectedAddons': instance.selectedAddons,
  'quantity': instance.quantity,
  'specialInstructions': instance.specialInstructions,
  'unitPrice': instance.unitPrice,
  'totalPrice': instance.totalPrice,
};

_$KitchenCustomizationSnapshotImpl _$$KitchenCustomizationSnapshotImplFromJson(
  Map<String, dynamic> json,
) => _$KitchenCustomizationSnapshotImpl(
  id: json['id'] as String,
  refId: json['refId'] as String?,
  nameAr: json['nameAr'] as String,
  nameEn: json['nameEn'] as String,
  priceSnapshot: (json['priceSnapshot'] as num).toDouble(),
);

Map<String, dynamic> _$$KitchenCustomizationSnapshotImplToJson(
  _$KitchenCustomizationSnapshotImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'refId': instance.refId,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'priceSnapshot': instance.priceSnapshot,
};
