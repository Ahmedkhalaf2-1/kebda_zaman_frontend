import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_offer.freezed.dart';

/// A lightweight snapshot of the linked [MenuItem] as embedded in the admin
/// Menu Offers response — not the full catalog model, and never fetched
/// independently. Every field except [id] is nullable: the exact shape of
/// the backend's nested summary isn't part of this task's contract, so the
/// repository mapper tolerates a narrower or differently-shaped object
/// rather than crashing on parse.
@freezed
class MenuOfferMenuItemSummary with _$MenuOfferMenuItemSummary {
  const factory MenuOfferMenuItemSummary({
    required String id,
    String? name,
    String? imageUrl,
    double? basePrice,
    bool? isAvailable,
    String? categoryId,
  }) = _MenuOfferMenuItemSummary;
}

/// A visual offer banner linked to an existing [MenuOfferMenuItemSummary] —
/// NOT a promo code, and it never carries pricing/discount data of its own.
/// Mirrors the backend `MenuOffer` fields exactly (see
/// `POST/PUT /api/v1/admin/menu-offers`); no local-only fields are added
/// here — transient UI state (upload progress, etc.) belongs in
/// presentation state, not this model.
@freezed
class MenuOffer with _$MenuOffer {
  const factory MenuOffer({
    required String id,
    required String menuItemId,
    required String imageUrl,
    String? title,
    String? description,
    @Default(true) bool isActive,
    DateTime? startAt,
    DateTime? endAt,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    MenuOfferMenuItemSummary? menuItem,
  }) = _MenuOffer;
}

/// Derived, presentation-only status — never a new persisted backend field.
/// Mirrors the exact priority order specified for this feature: an
/// admin-set Inactive flag always wins, then a future start date, then a
/// past end date, with Active as the fallback when none apply.
enum MenuOfferStatus { active, inactive, scheduled, expired }

MenuOfferStatus deriveMenuOfferStatus(MenuOffer offer) {
  if (!offer.isActive) return MenuOfferStatus.inactive;
  final now = DateTime.now();
  if (offer.startAt != null && offer.startAt!.isAfter(now)) {
    return MenuOfferStatus.scheduled;
  }
  if (offer.endAt != null && offer.endAt!.isBefore(now)) {
    return MenuOfferStatus.expired;
  }
  return MenuOfferStatus.active;
}
