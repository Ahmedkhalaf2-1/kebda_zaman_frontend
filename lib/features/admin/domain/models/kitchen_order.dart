import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

part 'kitchen_order.freezed.dart';
part 'kitchen_order.g.dart';

/// A single ticket in the kitchen queue/detail view — deliberately a much
/// smaller shape than [Order]: no customer name/phone, delivery address,
/// payment method/status, or totals/tax/delivery fee. The KITCHEN role's
/// two endpoints (`GET /kitchen/orders`, `GET /kitchen/orders/:id`) never
/// return any of that — kitchen staff only ever need to know what to cook.
/// Reuses [OrderStatus]/[FulfillmentType] from the customer/admin order
/// model rather than inventing parallel enums, since the wire values are
/// identical.
@freezed
class KitchenOrder with _$KitchenOrder {
  const factory KitchenOrder({
    required String id,
    required String orderNumber,
    required OrderStatus status,
    required FulfillmentType deliveryMethod,
    required DateTime createdAt,
    required List<KitchenOrderItem> items,
  }) = _KitchenOrder;

  factory KitchenOrder.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderFromJson(json);
}

@freezed
class KitchenOrderItem with _$KitchenOrderItem {
  const factory KitchenOrderItem({
    required String id,
    // Live MenuItem id — nullable the same way OrderItem.menuItemId is
    // (see order.dart's doc comment): null for a hard-deleted item. Not
    // used for anything on this screen today (no reorder/detail-link
    // action here), kept only in case that changes.
    String? menuItemId,
    required String nameAr,
    required String nameEn,
    String? imageUrl,
    KitchenCustomizationSnapshot? selectedVariant,
    @Default([]) List<KitchenCustomizationSnapshot> selectedAddons,
    required int quantity,
    String? specialInstructions,
    required double unitPrice,
    required double totalPrice,
  }) = _KitchenOrderItem;

  factory KitchenOrderItem.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderItemFromJson(json);
}

/// A variant/addon selection snapshot — `id` is the customization row's
/// own id (never a live catalog id), `refId` is the live
/// MenuItemVariant/MenuItemAddon id (nullable: null once discontinued).
/// Nothing here reorders or edits anything, so `refId` is carried only for
/// completeness — display uses `nameAr`/`nameEn`/`priceSnapshot`, which are
/// point-in-time and always correct regardless of `refId`.
@freezed
class KitchenCustomizationSnapshot with _$KitchenCustomizationSnapshot {
  const factory KitchenCustomizationSnapshot({
    required String id,
    String? refId,
    required String nameAr,
    required String nameEn,
    required double priceSnapshot,
  }) = _KitchenCustomizationSnapshot;

  factory KitchenCustomizationSnapshot.fromJson(Map<String, dynamic> json) =>
      _$KitchenCustomizationSnapshotFromJson(json);
}

extension KitchenOrderItemLocalization on KitchenOrderItem {
  String localizedName(String languageCode) {
    if (languageCode == 'ar' && nameAr.trim().isNotEmpty) return nameAr;
    if (nameEn.trim().isNotEmpty) return nameEn;
    return nameAr;
  }
}

extension KitchenCustomizationLocalization on KitchenCustomizationSnapshot {
  String localizedName(String languageCode) {
    if (languageCode == 'ar' && nameAr.trim().isNotEmpty) return nameAr;
    if (nameEn.trim().isNotEmpty) return nameEn;
    return nameAr;
  }
}
