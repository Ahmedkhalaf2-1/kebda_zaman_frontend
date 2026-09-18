// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
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
  isGuest: json['isGuest'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'name': instance.name,
  'email': instance.email,
  'addressIds': instance.addressIds,
  'favoriteItemIds': instance.favoriteItemIds,
  'loyaltyAccountId': instance.loyaltyAccountId,
  'role': instance.role,
  'isGuest': instance.isGuest,
  'createdAt': instance.createdAt.toIso8601String(),
};
