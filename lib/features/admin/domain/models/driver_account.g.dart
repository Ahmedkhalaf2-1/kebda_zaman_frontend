// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverAccount _$DriverAccountFromJson(Map<String, dynamic> json) =>
    _DriverAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DriverAccountToJson(_DriverAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
