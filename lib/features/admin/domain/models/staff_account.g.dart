// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StaffAccountImpl _$$StaffAccountImplFromJson(Map<String, dynamic> json) =>
    _$StaffAccountImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StaffAccountImplToJson(_$StaffAccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
