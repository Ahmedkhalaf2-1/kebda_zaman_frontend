import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  // Pickup-only lifecycle statuses (backend commit 51393d0). Never valid
  // alongside FulfillmentType.delivery in a well-formed order.
  readyForPickup,
  pickedUp,
  cancelled,
  // Not a real backend status — used when the backend sends a status string
  // that doesn't match any known value above (e.g. a new status added
  // server-side that this app doesn't know about yet), so it's never
  // silently misrepresented as "pending".
  unknown,
}

/// Whether this status represents a finished order (success or otherwise).
/// [OrderStatus.readyForPickup] is deliberately NOT terminal — it's still an
/// active, in-progress state (the customer hasn't collected the order yet).
extension OrderStatusX on OrderStatus {
  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.pickedUp ||
      this == OrderStatus.cancelled;
}

enum FulfillmentType { delivery, pickup }

/// Single source of truth for the fulfillment-aware customer/admin status
/// sequence — Delivery and Pickup orders never share the same in-progress
/// steps beyond `preparing`. Cancellation is not part of either normal
/// sequence; it's handled as a separate terminal state everywhere this is
/// consumed.
extension FulfillmentTypeStatusX on FulfillmentType {
  List<OrderStatus> get statusSequence => switch (this) {
    FulfillmentType.delivery => const [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ],
    FulfillmentType.pickup => const [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.readyForPickup,
      OrderStatus.pickedUp,
    ],
  };
}

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String orderNumber,
    required String userId,
    String? customerName,
    required List<OrderItem> items,
    required FulfillmentType fulfillmentType,
    String? addressId,
    String? pickupLocation,
    // Immutable delivery-address snapshot taken at order placement time
    // (backend VO2.3) — null for pickup orders and for older orders placed
    // before the backend started returning this snapshot.
    OrderDeliveryAddress? deliveryAddress,
    required OrderStatus status,
    required double subtotal,
    @Default(0.0) double deliveryFee,
    // Distance-based delivery pricing snapshot (backend distance-pricing
    // migration) — `null` for PICKUP orders and for any order placed before
    // the migration. Never required together; each is independently
    // nullable and never crashes when absent.
    int? deliveryDistanceMeters,
    double? deliveryDistanceKm,
    int? deliveryDurationSeconds,
    OrderDeliveryTier? deliveryTier,
    // DEPRECATED zone-based pricing snapshot — historical orders only.
    // Always `null` for orders placed after the distance-pricing migration;
    // kept purely for display on older orders that still carry it.
    OrderDeliveryZoneSnapshot? deliveryZone,
    @Default(0.0) double discountTotal,
    @Default(0) int loyaltyPointsUsed,
    @Default(0) int loyaltyPointsEarned,
    required double grandTotal,
    String? paymentId,
    String? paymentStatus,
    String? paymentMethod,
    required DateTime placedAt,
    @Default([]) List<OrderStatusEntry> statusHistory,
    String? estimatedTime,
    // Additive field on the checkout response only (03_DTO_REFERENCE.md) — null
    // when no loyalty reward was redeemed for this order (the normal case).
    LoyaltyRedemptionInfo? loyaltyRedemption,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

/// Fulfillment-aware next-status transitions, mirroring the backend's
/// `ALLOWED_TRANSITIONS` table (05_ORDER_LIFECYCLE.md) so the admin/cashier
/// UI never offers an illegal or cross-method transition (e.g. Pickup
/// `preparing` -> `outForDelivery`, or Delivery `outForDelivery` ->
/// `pickedUp`) instead of round-tripping a 422.
extension OrderStatusTransitionX on OrderStatus {
  Set<OrderStatus> allowedNextStatuses(FulfillmentType fulfillmentType) {
    if (isTerminal) return const {};
    final sequence = fulfillmentType.statusSequence;
    final idx = sequence.indexOf(this);
    if (idx == -1 || idx == sequence.length - 1) return const {};
    return {sequence[idx + 1], OrderStatus.cancelled};
  }
}

extension OrderCrossMethodX on Order {
  /// True when [status] doesn't belong to this order's own fulfillment
  /// type's normal sequence (`cancelled`/`unknown` are valid for either
  /// type, so they're never a mismatch). The backend guarantees this never
  /// happens for well-formed data — e.g. a Pickup order should never carry
  /// `outForDelivery`/`delivered` — but UI consumers must not silently
  /// render a normal timeline for that specific mismatched case if it ever
  /// occurs; they should fall back to a safe generic presentation instead.
  bool get hasCrossMethodStatusMismatch {
    if (status == OrderStatus.cancelled || status == OrderStatus.unknown) {
      return false;
    }
    return !fulfillmentType.statusSequence.contains(status);
  }
}

@freezed
class OrderDeliveryAddress with _$OrderDeliveryAddress {
  const factory OrderDeliveryAddress({
    String? label,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? city,
    String? area,
    String? notes,
    double? lat,
    double? lng,
  }) = _OrderDeliveryAddress;

  factory OrderDeliveryAddress.fromJson(Map<String, dynamic> json) =>
      _$OrderDeliveryAddressFromJson(json);

  /// Tolerant of the backend's mixed key naming (`latitude`/`lat`,
  /// `longitude`/`lng`, `title`/`label`) and of any field being absent —
  /// every field here is optional so older order snapshots (taken before a
  /// field existed) still parse cleanly instead of throwing.
  factory OrderDeliveryAddress.fromBackendJson(Map<String, dynamic> json) {
    return OrderDeliveryAddress(
      label: (json['title'] ?? json['label'])?.toString(),
      street: json['street']?.toString(),
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      apartment: json['apartment']?.toString(),
      city: json['city']?.toString(),
      area: json['area']?.toString(),
      notes: (json['notes'] ?? json['landmark'])?.toString(),
      lat: (json['latitude'] ?? json['lat']) != null
          ? double.tryParse((json['latitude'] ?? json['lat']).toString())
          : null,
      lng: (json['longitude'] ?? json['lng']) != null
          ? double.tryParse((json['longitude'] ?? json['lng']).toString())
          : null,
    );
  }
}

/// True only when both coordinates are present and non-zero — the backend
/// never legitimately places an order at the (0, 0) "null island" sentinel,
/// so that combination is treated as missing/invalid rather than launched.
extension OrderDeliveryAddressCoordsX on OrderDeliveryAddress {
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
}

/// Distance tier snapshot captured at checkout time for a DELIVERY order
/// (distance-pricing migration) — built from the order's own snapshot
/// columns server-side, never a live tier join, so it never changes if the
/// tier is later edited/deactivated.
@freezed
class OrderDeliveryTier with _$OrderDeliveryTier {
  const factory OrderDeliveryTier({
    required String id,
    required double minDistanceKm,
    required double maxDistanceKm,
  }) = _OrderDeliveryTier;

  factory OrderDeliveryTier.fromJson(Map<String, dynamic> json) =>
      _$OrderDeliveryTierFromJson(json);

  /// Tolerant of numeric or numeric-string wire values (the backend formats
  /// these with `toFixed(2)`) — a missing/malformed value parses as `0.0`
  /// rather than throwing.
  factory OrderDeliveryTier.fromBackendJson(Map<String, dynamic> json) {
    return OrderDeliveryTier(
      id: (json['id'] ?? '').toString(),
      minDistanceKm: _toDouble(json['minDistanceKm']) ?? 0.0,
      maxDistanceKm: _toDouble(json['maxDistanceKm']) ?? 0.0,
    );
  }
}

/// DEPRECATED zone-based pricing snapshot — present only on orders placed
/// before the distance-pricing migration. `null` for every order placed
/// after it (and for PICKUP orders).
@freezed
class OrderDeliveryZoneSnapshot with _$OrderDeliveryZoneSnapshot {
  const factory OrderDeliveryZoneSnapshot({
    required String id,
    required String nameAr,
    required String nameEn,
  }) = _OrderDeliveryZoneSnapshot;

  factory OrderDeliveryZoneSnapshot.fromJson(Map<String, dynamic> json) =>
      _$OrderDeliveryZoneSnapshotFromJson(json);

  factory OrderDeliveryZoneSnapshot.fromBackendJson(Map<String, dynamic> json) {
    return OrderDeliveryZoneSnapshot(
      id: (json['id'] ?? '').toString(),
      nameAr: (json['nameAr'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? '').toString(),
    );
  }
}

extension OrderDeliveryZoneSnapshotX on OrderDeliveryZoneSnapshot {
  String localizedName(String languageCode) {
    if (languageCode == 'ar') {
      return nameAr.isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }
}

@freezed
class LoyaltyRedemptionInfo with _$LoyaltyRedemptionInfo {
  const factory LoyaltyRedemptionInfo({
    required String rewardId,
    required String rewardName,
    required int pointsRedeemed,
  }) = _LoyaltyRedemptionInfo;

  factory LoyaltyRedemptionInfo.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyRedemptionInfoFromJson(json);
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String menuItemId,
    required String name,
    required String imageUrl,
    required double basePrice,
    required double unitPrice,
    required int quantity,
    @Default({})
    Map<String, List<String>> selectedOptions, // groupId -> list of optionIds
    @Default({})
    Map<String, Map<String, List<String>>>
    nestedSelections, // optionId -> (groupId -> list of nestedOptionIds)
    @Default({}) Map<String, int> extraQuantities, // optionId -> quantity
    @Default([]) List<String> removedIngredients,
    @Default('') String specialInstructions,
    @Default('') String formattedConfiguration,
    required double lineTotal,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
class OrderStatusEntry with _$OrderStatusEntry {
  const factory OrderStatusEntry({
    required OrderStatus status,
    required DateTime timestamp,
  }) = _OrderStatusEntry;

  factory OrderStatusEntry.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusEntryFromJson(json);
}
