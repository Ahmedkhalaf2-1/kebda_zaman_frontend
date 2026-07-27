import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
  // Not a real backend status — used when the backend sends a status string
  // that doesn't match any known value above (e.g. a new status added
  // server-side that this app doesn't know about yet), so it's never
  // silently misrepresented as "pending".
  unknown,
}

enum FulfillmentType { delivery, pickup }

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
    required OrderStatus status,
    required double subtotal,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double discountTotal,
    @Default(0) int loyaltyPointsUsed,
    @Default(0) int loyaltyPointsEarned,
    required double grandTotal,
    String? paymentId,
    String? paymentStatus,
    required DateTime placedAt,
    @Default([]) List<OrderStatusEntry> statusHistory,
    String? estimatedTime,
    // Additive field on the checkout response only (03_DTO_REFERENCE.md) — null
    // when no loyalty reward was redeemed for this order (the normal case).
    LoyaltyRedemptionInfo? loyaltyRedemption,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
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
