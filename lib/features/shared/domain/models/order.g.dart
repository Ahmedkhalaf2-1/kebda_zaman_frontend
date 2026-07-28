// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  orderNumber: json['orderNumber'] as String,
  userId: json['userId'] as String,
  customerName: json['customerName'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  fulfillmentType: $enumDecode(
    _$FulfillmentTypeEnumMap,
    json['fulfillmentType'],
  ),
  addressId: json['addressId'] as String?,
  pickupLocation: json['pickupLocation'] as String?,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
  discountTotal: (json['discountTotal'] as num?)?.toDouble() ?? 0.0,
  loyaltyPointsUsed: (json['loyaltyPointsUsed'] as num?)?.toInt() ?? 0,
  loyaltyPointsEarned: (json['loyaltyPointsEarned'] as num?)?.toInt() ?? 0,
  grandTotal: (json['grandTotal'] as num).toDouble(),
  paymentId: json['paymentId'] as String?,
  paymentStatus: json['paymentStatus'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  placedAt: DateTime.parse(json['placedAt'] as String),
  statusHistory:
      (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => OrderStatusEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  estimatedTime: json['estimatedTime'] as String?,
  loyaltyRedemption: json['loyaltyRedemption'] == null
      ? null
      : LoyaltyRedemptionInfo.fromJson(
          json['loyaltyRedemption'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'userId': instance.userId,
      'customerName': instance.customerName,
      'items': instance.items,
      'fulfillmentType': _$FulfillmentTypeEnumMap[instance.fulfillmentType]!,
      'addressId': instance.addressId,
      'pickupLocation': instance.pickupLocation,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'discountTotal': instance.discountTotal,
      'loyaltyPointsUsed': instance.loyaltyPointsUsed,
      'loyaltyPointsEarned': instance.loyaltyPointsEarned,
      'grandTotal': instance.grandTotal,
      'paymentId': instance.paymentId,
      'paymentStatus': instance.paymentStatus,
      'paymentMethod': instance.paymentMethod,
      'placedAt': instance.placedAt.toIso8601String(),
      'statusHistory': instance.statusHistory,
      'estimatedTime': instance.estimatedTime,
      'loyaltyRedemption': instance.loyaltyRedemption,
    };

const _$FulfillmentTypeEnumMap = {
  FulfillmentType.delivery: 'delivery',
  FulfillmentType.pickup: 'pickup',
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.outForDelivery: 'outForDelivery',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.unknown: 'unknown',
};

_$LoyaltyRedemptionInfoImpl _$$LoyaltyRedemptionInfoImplFromJson(
  Map<String, dynamic> json,
) => _$LoyaltyRedemptionInfoImpl(
  rewardId: json['rewardId'] as String,
  rewardName: json['rewardName'] as String,
  pointsRedeemed: (json['pointsRedeemed'] as num).toInt(),
);

Map<String, dynamic> _$$LoyaltyRedemptionInfoImplToJson(
  _$LoyaltyRedemptionInfoImpl instance,
) => <String, dynamic>{
  'rewardId': instance.rewardId,
  'rewardName': instance.rewardName,
  'pointsRedeemed': instance.pointsRedeemed,
};

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
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
      formattedConfiguration: json['formattedConfiguration'] as String? ?? '',
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'basePrice': instance.basePrice,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'selectedOptions': instance.selectedOptions,
      'nestedSelections': instance.nestedSelections,
      'extraQuantities': instance.extraQuantities,
      'removedIngredients': instance.removedIngredients,
      'specialInstructions': instance.specialInstructions,
      'formattedConfiguration': instance.formattedConfiguration,
      'lineTotal': instance.lineTotal,
    };

_$OrderStatusEntryImpl _$$OrderStatusEntryImplFromJson(
  Map<String, dynamic> json,
) => _$OrderStatusEntryImpl(
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$OrderStatusEntryImplToJson(
  _$OrderStatusEntryImpl instance,
) => <String, dynamic>{
  'status': _$OrderStatusEnumMap[instance.status]!,
  'timestamp': instance.timestamp.toIso8601String(),
};
