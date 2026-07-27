// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderNotificationImpl _$$OrderNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$OrderNotificationImpl(
  id: json['id'] as String,
  type: json['type'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  orderId: json['orderId'] as String,
  customerId: json['customerId'] as String,
  customerName: json['customerName'] as String,
  orderNumber: json['orderNumber'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  isRead: json['isRead'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$OrderNotificationImplToJson(
  _$OrderNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'title': instance.title,
  'body': instance.body,
  'orderId': instance.orderId,
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'orderNumber': instance.orderNumber,
  'totalAmount': instance.totalAmount,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
