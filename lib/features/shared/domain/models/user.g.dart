// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  phone: json['phone'] as String?,
  name: json['name'] as String,
  email: json['email'] as String?,
  addressIds:
      (json['addressIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  favoriteItemIds:
      (json['favoriteItemIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  loyaltyAccountId: json['loyaltyAccountId'] as String?,
  role: json['role'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'email': instance.email,
      'addressIds': instance.addressIds,
      'favoriteItemIds': instance.favoriteItemIds,
      'loyaltyAccountId': instance.loyaltyAccountId,
      'role': instance.role,
      'createdAt': instance.createdAt.toIso8601String(),
    };
