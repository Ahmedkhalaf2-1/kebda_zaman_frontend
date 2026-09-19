// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
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
  deliveryAddress: json['deliveryAddress'] == null
      ? null
      : OrderDeliveryAddress.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>,
        ),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
  deliveryDistanceMeters: (json['deliveryDistanceMeters'] as num?)?.toInt(),
  deliveryDistanceKm: (json['deliveryDistanceKm'] as num?)?.toDouble(),
  deliveryDurationSeconds: (json['deliveryDurationSeconds'] as num?)?.toInt(),
  deliveryTier: json['deliveryTier'] == null
      ? null
      : OrderDeliveryTier.fromJson(
          json['deliveryTier'] as Map<String, dynamic>,
        ),
  deliveryZone: json['deliveryZone'] == null
      ? null
      : OrderDeliveryZoneSnapshot.fromJson(
          json['deliveryZone'] as Map<String, dynamic>,
        ),
  discountTotal: (json['discountTotal'] as num?)?.toDouble() ?? 0.0,
  loyaltyPointsUsed: (json['loyaltyPointsUsed'] as num?)?.toInt() ?? 0,
  loyaltyPointsEarned: (json['loyaltyPointsEarned'] as num?)?.toInt() ?? 0,
  grandTotal: (json['grandTotal'] as num).toDouble(),
  paymentId: json['paymentId'] as String?,
  paymentStatus: json['paymentStatus'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  paymentAuthorizedAt: json['paymentAuthorizedAt'] == null
      ? null
      : DateTime.parse(json['paymentAuthorizedAt'] as String),
  placedAt: DateTime.parse(json['placedAt'] as String),
  statusHistory:
      (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => OrderStatusEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  estimatedTime: json['estimatedTime'] as String?,
  preparationTimeMinutes: (json['preparationTimeMinutes'] as num?)?.toInt(),
  loyaltyRedemption: json['loyaltyRedemption'] == null
      ? null
      : LoyaltyRedemptionInfo.fromJson(
          json['loyaltyRedemption'] as Map<String, dynamic>,
        ),
  driverId: json['driverId'] as String?,
  customerPhone: json['customerPhone'] as String?,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'orderNumber': instance.orderNumber,
  'userId': instance.userId,
  'customerName': instance.customerName,
  'items': instance.items,
  'fulfillmentType': _$FulfillmentTypeEnumMap[instance.fulfillmentType]!,
  'addressId': instance.addressId,
  'pickupLocation': instance.pickupLocation,
  'deliveryAddress': instance.deliveryAddress,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'subtotal': instance.subtotal,
  'deliveryFee': instance.deliveryFee,
  'deliveryDistanceMeters': instance.deliveryDistanceMeters,
  'deliveryDistanceKm': instance.deliveryDistanceKm,
  'deliveryDurationSeconds': instance.deliveryDurationSeconds,
  'deliveryTier': instance.deliveryTier,
  'deliveryZone': instance.deliveryZone,
  'discountTotal': instance.discountTotal,
  'loyaltyPointsUsed': instance.loyaltyPointsUsed,
  'loyaltyPointsEarned': instance.loyaltyPointsEarned,
  'grandTotal': instance.grandTotal,
  'paymentId': instance.paymentId,
  'paymentStatus': instance.paymentStatus,
  'paymentMethod': instance.paymentMethod,
  'paymentAuthorizedAt': instance.paymentAuthorizedAt?.toIso8601String(),
  'placedAt': instance.placedAt.toIso8601String(),
  'statusHistory': instance.statusHistory,
  'estimatedTime': instance.estimatedTime,
  'preparationTimeMinutes': instance.preparationTimeMinutes,
  'loyaltyRedemption': instance.loyaltyRedemption,
  'driverId': instance.driverId,
  'customerPhone': instance.customerPhone,
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
  OrderStatus.readyForPickup: 'readyForPickup',
  OrderStatus.pickedUp: 'pickedUp',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.unknown: 'unknown',
};

_OrderDeliveryAddress _$OrderDeliveryAddressFromJson(
  Map<String, dynamic> json,
) => _OrderDeliveryAddress(
  label: json['label'] as String?,
  street: json['street'] as String?,
  building: json['building'] as String?,
  floor: json['floor'] as String?,
  apartment: json['apartment'] as String?,
  city: json['city'] as String?,
  area: json['area'] as String?,
  notes: json['notes'] as String?,
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OrderDeliveryAddressToJson(
  _OrderDeliveryAddress instance,
) => <String, dynamic>{
  'label': instance.label,
  'street': instance.street,
  'building': instance.building,
  'floor': instance.floor,
  'apartment': instance.apartment,
  'city': instance.city,
  'area': instance.area,
  'notes': instance.notes,
  'lat': instance.lat,
  'lng': instance.lng,
};

_OrderDeliveryTier _$OrderDeliveryTierFromJson(Map<String, dynamic> json) =>
    _OrderDeliveryTier(
      id: json['id'] as String,
      minDistanceKm: (json['minDistanceKm'] as num).toDouble(),
      maxDistanceKm: (json['maxDistanceKm'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderDeliveryTierToJson(_OrderDeliveryTier instance) =>
    <String, dynamic>{
      'id': instance.id,
      'minDistanceKm': instance.minDistanceKm,
      'maxDistanceKm': instance.maxDistanceKm,
    };

_OrderDeliveryZoneSnapshot _$OrderDeliveryZoneSnapshotFromJson(
  Map<String, dynamic> json,
) => _OrderDeliveryZoneSnapshot(
  id: json['id'] as String,
  nameAr: json['nameAr'] as String,
  nameEn: json['nameEn'] as String,
);

Map<String, dynamic> _$OrderDeliveryZoneSnapshotToJson(
  _OrderDeliveryZoneSnapshot instance,
) => <String, dynamic>{
  'id': instance.id,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
};

_LoyaltyRedemptionInfo _$LoyaltyRedemptionInfoFromJson(
  Map<String, dynamic> json,
) => _LoyaltyRedemptionInfo(
  rewardId: json['rewardId'] as String,
  rewardName: json['rewardName'] as String,
  pointsRedeemed: (json['pointsRedeemed'] as num).toInt(),
);

Map<String, dynamic> _$LoyaltyRedemptionInfoToJson(
  _LoyaltyRedemptionInfo instance,
) => <String, dynamic>{
  'rewardId': instance.rewardId,
  'rewardName': instance.rewardName,
  'pointsRedeemed': instance.pointsRedeemed,
};

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  menuItemId: json['menuItemId'] as String?,
  variantRefId: json['variantRefId'] as String?,
  addonRefIds:
      (json['addonRefIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String,
  basePrice: (json['basePrice'] as num).toDouble(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  selectedOptions:
      (json['selectedOptions'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
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

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
      'variantRefId': instance.variantRefId,
      'addonRefIds': instance.addonRefIds,
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

_OrderStatusEntry _$OrderStatusEntryFromJson(Map<String, dynamic> json) =>
    _OrderStatusEntry(
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$OrderStatusEntryToJson(_OrderStatusEntry instance) =>
    <String, dynamic>{
      'status': _$OrderStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
    };
