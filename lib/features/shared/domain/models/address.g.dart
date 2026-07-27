// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      building: json['building'] as String,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      city: json['city'] as String,
      area: json['area'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'label': instance.label,
      'street': instance.street,
      'building': instance.building,
      'floor': instance.floor,
      'apartment': instance.apartment,
      'city': instance.city,
      'area': instance.area,
      'lat': instance.lat,
      'lng': instance.lng,
      'notes': instance.notes,
      'isDefault': instance.isDefault,
    };
