/// One `workingHours` entry — `dayOfWeek` 0-6, 0 = Sunday (plain-integer
/// convention, no day-name enum), matching
/// PHASE_8_RESTAURANT_SETTINGS_API_CONTRACT.md §3. `openTime`/`closeTime`
/// are `"HH:MM"` 24-hour strings, `null` when `isOpen` is `false`. Overnight
/// ranges (e.g. `18:00` → `02:00`) are valid and un-normalized — the backend
/// never reorders them.
class DayWorkingHours {
  final int dayOfWeek;
  final bool isOpen;
  final String? openTime;
  final String? closeTime;

  const DayWorkingHours({
    required this.dayOfWeek,
    required this.isOpen,
    this.openTime,
    this.closeTime,
  });

  factory DayWorkingHours.fromJson(Map<String, dynamic> json) {
    return DayWorkingHours(
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
      isOpen: json['isOpen'] as bool? ?? false,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'isOpen': isOpen,
    'openTime': openTime,
    'closeTime': closeTime,
  };

  DayWorkingHours copyWith({
    bool? isOpen,
    String? openTime,
    String? closeTime,
  }) {
    return DayWorkingHours(
      dayOfWeek: dayOfWeek,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }
}

/// `RestaurantSettings` — restaurant profile, weekly hours, manual
/// order-acceptance gate (PHASE_8_RESTAURANT_SETTINGS_API_CONTRACT.md).
/// Same shape for `GET /settings` (public) and `GET/PUT /admin/settings`
/// (admin) — the admin repository call simply has access to every field.
class RestaurantSettings {
  final String restaurantNameAr;
  final String restaurantNameEn;
  final String? logoUrl;
  final String phone;
  final String addressAr;
  final String addressEn;
  final double taxRatePercent;
  final double deliveryFee;
  final double minOrderAmount;
  final String currency;
  final List<DayWorkingHours> workingHours;
  final String timezone;
  final bool isMaintenanceMode;
  final bool acceptingOrders;
  final String? closedMessageAr;
  final String? closedMessageEn;

  const RestaurantSettings({
    required this.restaurantNameAr,
    required this.restaurantNameEn,
    this.logoUrl,
    required this.phone,
    required this.addressAr,
    required this.addressEn,
    required this.taxRatePercent,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.currency,
    required this.workingHours,
    required this.timezone,
    required this.isMaintenanceMode,
    required this.acceptingOrders,
    this.closedMessageAr,
    this.closedMessageEn,
  });

  factory RestaurantSettings.fromJson(Map<String, dynamic> json) {
    final hoursJson = (json['workingHours'] as List?) ?? const [];
    return RestaurantSettings(
      restaurantNameAr: json['restaurantNameAr'] as String? ?? '',
      restaurantNameEn: json['restaurantNameEn'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      phone: json['phone'] as String? ?? '',
      addressAr: json['addressAr'] as String? ?? '',
      addressEn: json['addressEn'] as String? ?? '',
      taxRatePercent: (json['taxRatePercent'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      workingHours: hoursJson
          .map((e) => DayWorkingHours.fromJson(e as Map<String, dynamic>))
          .toList(),
      timezone: json['timezone'] as String? ?? 'Africa/Cairo',
      isMaintenanceMode: json['isMaintenanceMode'] as bool? ?? false,
      acceptingOrders: json['acceptingOrders'] as bool? ?? true,
      closedMessageAr: json['closedMessageAr'] as String?,
      closedMessageEn: json['closedMessageEn'] as String?,
    );
  }

  /// Full-replace payload for `PUT /admin/settings` — every field the
  /// contract lists, in the exact shape it expects.
  Map<String, dynamic> toJson() => {
    'restaurantNameAr': restaurantNameAr,
    'restaurantNameEn': restaurantNameEn,
    'logoUrl': logoUrl,
    'phone': phone,
    'addressAr': addressAr,
    'addressEn': addressEn,
    'taxRatePercent': taxRatePercent,
    'deliveryFee': deliveryFee,
    'minOrderAmount': minOrderAmount,
    'currency': currency,
    'workingHours': workingHours.map((h) => h.toJson()).toList(),
    'timezone': timezone,
    'isMaintenanceMode': isMaintenanceMode,
    'acceptingOrders': acceptingOrders,
    'closedMessageAr': closedMessageAr,
    'closedMessageEn': closedMessageEn,
  };

  RestaurantSettings copyWith({
    String? restaurantNameAr,
    String? restaurantNameEn,
    String? logoUrl,
    String? phone,
    String? addressAr,
    String? addressEn,
    double? taxRatePercent,
    double? deliveryFee,
    double? minOrderAmount,
    String? currency,
    List<DayWorkingHours>? workingHours,
    String? timezone,
    bool? isMaintenanceMode,
    bool? acceptingOrders,
    String? closedMessageAr,
    String? closedMessageEn,
  }) {
    return RestaurantSettings(
      restaurantNameAr: restaurantNameAr ?? this.restaurantNameAr,
      restaurantNameEn: restaurantNameEn ?? this.restaurantNameEn,
      logoUrl: logoUrl ?? this.logoUrl,
      phone: phone ?? this.phone,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      taxRatePercent: taxRatePercent ?? this.taxRatePercent,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      currency: currency ?? this.currency,
      workingHours: workingHours ?? this.workingHours,
      timezone: timezone ?? this.timezone,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      acceptingOrders: acceptingOrders ?? this.acceptingOrders,
      closedMessageAr: closedMessageAr ?? this.closedMessageAr,
      closedMessageEn: closedMessageEn ?? this.closedMessageEn,
    );
  }
}

/// Fixed client-side loyalty policy. The backend has no loyalty-policy
/// fields on `RestaurantSettings` (confirmed against
/// PHASE_8_RESTAURANT_SETTINGS_API_CONTRACT.md's full-replace payload and
/// the Prisma schema — loyalty lives entirely in `LoyaltyAccount`/
/// `LoyaltyTransaction`, with no configurable policy endpoint), so these
/// values are a versioned client constant rather than a value fabricated
/// from an API response that never returned them.
class LoyaltyPolicy {
  final double egpStep;
  final int pointsPerStep;
  final int minRedemptionPoints;
  final double maxDiscountFromPoints;

  const LoyaltyPolicy({
    required this.egpStep,
    required this.pointsPerStep,
    required this.minRedemptionPoints,
    required this.maxDiscountFromPoints,
  });

  static const standard = LoyaltyPolicy(
    egpStep: 10.0,
    pointsPerStep: 1,
    minRedemptionPoints: 100,
    maxDiscountFromPoints: 50.0,
  );
}
