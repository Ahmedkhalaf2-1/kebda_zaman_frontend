import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
class Cart with _$Cart {
  const factory Cart({
    required String id,
    @Default([]) List<CartItem> items,
    String? promoCodeId,
    @Default(0) int loyaltyPointsApplied,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double subtotal,
    @Default(0.0) double discountTotal,
    @Default(0.0) double taxTotal,
    @Default(0.0) double grandTotal,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

@freezed
class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required String id,
    required String menuItemId,
    required String productName,
    required String productImage,
    required double basePrice,
    required int quantity,
    @Default({})
    Map<String, List<String>> selectedOptions, // groupId -> list of optionIds
    @Default({})
    Map<String, Map<String, List<String>>>
    nestedSelections, // optionId -> (groupId -> list of nestedOptionIds)
    @Default({}) Map<String, int> extraQuantities, // optionId -> quantity
    @Default([]) List<String> removedIngredients,
    @Default('') String specialInstructions,
    required double unitPrice,
    required double lineTotal,
    @Default(true) bool isAvailable,
    // Display-only snapshot of the linked menu item's original/discounted
    // unit price, from the cart response's nested `menuItem` object — never
    // used to compute anything. `unitPrice`/`lineTotal` above are already
    // the server-computed, authoritative charged amounts; these two fields
    // exist solely so a cart line can show a struck-through "was" price
    // when `menuItemDiscountPrice != null`.
    double? menuItemBasePrice,
    double? menuItemDiscountPrice,
  }) = _CartItem;

  String get configurationSignature {
    final opts =
        selectedOptions.entries
            .map((e) => '${e.key}:${e.value.join(",")}')
            .toList()
          ..sort();
    final nested =
        nestedSelections.entries
            .map(
              (e) =>
                  '${e.key}:${e.value.entries.map((n) => "${n.key}:${n.value.join(",")}").toList()..sort()}',
            )
            .toList()
          ..sort();
    final extra =
        extraQuantities.entries.map((e) => '${e.key}:${e.value}').toList()
          ..sort();
    final removed = List.from(removedIngredients)..sort();
    return '$menuItemId|${opts.join("|")}|${nested.join("|")}|${extra.join("|")}|${removed.join("|")}|$specialInstructions';
  }

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
