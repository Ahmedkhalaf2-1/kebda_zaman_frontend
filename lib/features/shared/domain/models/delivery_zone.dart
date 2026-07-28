/// `DeliveryZone` — a named delivery area with a flat fee and minimum order,
/// nothing more (no polygons/coordinates/radius/geofencing — see
/// PHASE_8_RESTAURANT_SETTINGS_API_CONTRACT.md §5). The public endpoint
/// (`GET /delivery-zones`) omits `isActive`/timestamps; the admin endpoint
/// (`GET /admin/delivery-zones`) includes them. [isActive] defaults to
/// `true` when absent (i.e. every zone from the public endpoint is active
/// by construction — it only ever returns active zones).
class DeliveryZone {
  final String id;
  final String nameAr;
  final String nameEn;
  final double deliveryFee;
  final double minimumOrder;
  final bool isActive;
  final int sortOrder;

  const DeliveryZone({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.deliveryFee,
    required this.minimumOrder,
    required this.isActive,
    required this.sortOrder,
  });

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    return DeliveryZone(
      id: json['id'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      minimumOrder: (json['minimumOrder'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
}
