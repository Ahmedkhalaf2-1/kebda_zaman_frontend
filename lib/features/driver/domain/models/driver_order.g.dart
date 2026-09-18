// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverOrder _$DriverOrderFromJson(Map<String, dynamic> json) => _DriverOrder(
  id: json['id'] as String,
  orderNumber: json['orderNumber'] as String,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryAddress: json['deliveryAddress'] == null
      ? null
      : OrderDeliveryAddress.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>,
        ),
  deliveryMethod: $enumDecode(_$FulfillmentTypeEnumMap, json['deliveryMethod']),
  customerName: json['customerName'] as String,
  customerPhone: json['customerPhone'] as String?,
  paymentMethod: json['paymentMethod'] as String,
  paymentStatus: json['paymentStatus'] as String,
  amountToCollect: (json['amountToCollect'] as num).toDouble(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  assignmentVersion: (json['assignmentVersion'] as num).toInt(),
);

Map<String, dynamic> _$DriverOrderToJson(_DriverOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'items': instance.items,
      'deliveryAddress': instance.deliveryAddress,
      'deliveryMethod': _$FulfillmentTypeEnumMap[instance.deliveryMethod]!,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'paymentMethod': instance.paymentMethod,
      'paymentStatus': instance.paymentStatus,
      'amountToCollect': instance.amountToCollect,
      'totalAmount': instance.totalAmount,
      'createdAt': instance.createdAt.toIso8601String(),
      'assignmentVersion': instance.assignmentVersion,
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
