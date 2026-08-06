/// Advisory pre-checkout delivery pricing estimate returned by
/// `POST /delivery/quote` (distance-based delivery pricing migration).
/// Checkout always recalculates authoritatively — this is UI-only and must
/// never be submitted back to the server or trusted as the final fee.
library;

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// Snapshot of the distance tier the quote matched — `null` whenever
/// [DeliveryQuote.deliverable] is `false`.
class DeliveryQuoteTier {
  final String id;
  final double minDistanceKm;
  final double maxDistanceKm;

  const DeliveryQuoteTier({
    required this.id,
    required this.minDistanceKm,
    required this.maxDistanceKm,
  });

  factory DeliveryQuoteTier.fromJson(Map<String, dynamic> json) {
    return DeliveryQuoteTier(
      id: (json['id'] ?? '').toString(),
      minDistanceKm: _toDouble(json['minDistanceKm']) ?? 0.0,
      maxDistanceKm: _toDouble(json['maxDistanceKm']) ?? 0.0,
    );
  }
}

class DeliveryQuote {
  final bool deliverable;
  final int? distanceMeters;
  final double? distanceKm;
  final int? durationSeconds;
  final int? durationMinutes;
  final double? deliveryFee;
  final double? minimumOrder;
  final String? currency;
  final DeliveryQuoteTier? tier;
  // Present only when `deliverable == false`, e.g. 'OUTSIDE_DELIVERY_RANGE'.
  final String? reason;

  const DeliveryQuote({
    required this.deliverable,
    this.distanceMeters,
    this.distanceKm,
    this.durationSeconds,
    this.durationMinutes,
    this.deliveryFee,
    this.minimumOrder,
    this.currency,
    this.tier,
    this.reason,
  });

  /// Every field but [deliverable] is optional/nullable and tolerant of
  /// numeric-string wire values (e.g. `"13.42"`) — a missing or malformed
  /// optional field is parsed as `null` rather than throwing.
  factory DeliveryQuote.fromJson(Map<String, dynamic> json) {
    final tierJson = json['tier'] as Map<String, dynamic>?;
    return DeliveryQuote(
      deliverable: json['deliverable'] == true,
      distanceMeters: _toInt(json['distanceMeters']),
      distanceKm: _toDouble(json['distanceKm']),
      durationSeconds: _toInt(json['durationSeconds']),
      durationMinutes: _toInt(json['durationMinutes']),
      deliveryFee: _toDouble(json['deliveryFee']),
      minimumOrder: _toDouble(json['minimumOrder']),
      currency: json['currency'] as String?,
      tier: tierJson != null ? DeliveryQuoteTier.fromJson(tierJson) : null,
      reason: json['reason'] as String?,
    );
  }
}
