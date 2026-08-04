/// Parsed response from POST /locations/reverse-geocode.
class ReverseGeocodeResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String street;
  final String area;
  final String city;
  final String governorate;
  final String country;
  final String? postalCode;
  final String? placeId;
  final String? source;

  const ReverseGeocodeResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.street,
    required this.area,
    required this.city,
    required this.governorate,
    required this.country,
    this.postalCode,
    this.placeId,
    this.source,
  });

  factory ReverseGeocodeResult.fromJson(Map<String, dynamic> json) {
    return ReverseGeocodeResult(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      formattedAddress: json['formattedAddress'] as String? ?? '',
      street: json['street'] as String? ?? '',
      area: json['area'] as String? ?? '',
      city: json['city'] as String? ?? '',
      governorate: json['governorate'] as String? ?? '',
      country: json['country'] as String? ?? '',
      postalCode: json['postalCode'] as String?,
      placeId: json['placeId'] as String?,
      source: json['source'] as String?,
    );
  }
}
