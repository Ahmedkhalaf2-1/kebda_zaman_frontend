import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
class Address with _$Address {
  const factory Address({
    required String id,
    required String userId,
    required String label, // Home / Work / Other
    required String street,
    required String building,
    String? floor,
    String? apartment,
    required String city,
    required String area,
    double? lat,
    double? lng,
    String? notes,
    @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  factory Address.fromBackendJson(Map<String, dynamic> json) {
    return Address(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      label: (json['title'] ?? json['label'] ?? 'Home').toString(),
      street: (json['street'] ?? '').toString(),
      building: (json['building'] ?? '').toString(),
      floor: json['floor']?.toString(),
      apartment: json['apartment']?.toString(),
      city: (json['city'] ?? '').toString(),
      area: (json['area'] ?? '').toString(),
      lat: (json['latitude'] ?? json['lat']) != null
          ? double.tryParse((json['latitude'] ?? json['lat']).toString())
          : null,
      lng: (json['longitude'] ?? json['lng']) != null
          ? double.tryParse((json['longitude'] ?? json['lng']).toString())
          : null,
      notes: json['notes']?.toString() ?? json['landmark']?.toString(),
      isDefault: json['isDefault'] == true,
    );
  }
}

extension AddressFieldsExtension on Address {
  String? get landmark => notes;
  String? get recipientName => null;
  String? get phone => null;

  /// True only when both coordinates are present and non-zero — mirrors
  /// [OrderDeliveryAddressCoordsX.hasValidCoordinates]. The backend never
  /// legitimately places an address at the (0, 0) "null island" sentinel, so
  /// that combination is treated as missing/invalid, never as a real pin.
  bool get hasValidCoordinates {
    final latitude = lat;
    final longitude = lng;
    if (latitude == null || longitude == null) return false;
    if (!latitude.isFinite || !longitude.isFinite) return false;
    if (latitude < -90 || latitude > 90) return false;
    if (longitude < -180 || longitude > 180) return false;
    if (latitude == 0.0 && longitude == 0.0) return false;
    return true;
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'title': label.isNotEmpty ? label : 'Home',
      'street': street,
      'building': building,
      if (floor != null && floor!.isNotEmpty) 'floor': floor,
      if (apartment != null && apartment!.isNotEmpty) 'apartment': apartment,
      'city': city.isNotEmpty ? city : 'Cairo',
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (lat != null) 'latitude': lat,
      if (lng != null) 'longitude': lng,
      'isDefault': isDefault,
    };
  }
}
