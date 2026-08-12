import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/cart_repository.dart';

class ApiCartRepository implements CartRepository {
  final ApiClient _apiClient;

  ApiCartRepository(this._apiClient);

  @override
  Future<Result<Cart>> getCart() async {
    try {
      final response = await _apiClient.dio.get('/cart');
      return Success(_mapCart(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load cart'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading cart'));
    }
  }

  @override
  Future<Result<Cart>> addItem(CartItem item) async {
    try {
      final payload = _buildCartItemPayload(item);
      final response = await _apiClient.dio.post('/cart/items', data: payload);
      return Success(_mapCart(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to add item to cart'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error adding item to cart'));
    }
  }

  @override
  Future<Result<Cart>> removeItem(String cartItemId) async {
    try {
      final response = await _apiClient.dio.delete('/cart/items/$cartItemId');
      return Success(_mapCart(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to remove item from cart'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error removing item from cart'));
    }
  }

  @override
  Future<Result<Cart>> updateItemQuantity(
    String cartItemId,
    int quantity,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/cart/items/$cartItemId',
        data: {'quantity': quantity},
      );
      return Success(_mapCart(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to update item quantity'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error updating item quantity'));
    }
  }

  @override
  Future<Result<Cart>> clearCart() async {
    try {
      final response = await _apiClient.dio.delete('/cart');
      return Success(_mapCart(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to clear cart'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error clearing cart'));
    }
  }

  @override
  Future<Result<Cart>> applyPromoCode(String promoCodeId) async {
    try {
      // Backend expects { code: string }
      final response = await _apiClient.dio.post(
        '/cart/apply-promo',
        data: {'code': promoCodeId},
      );
      return Success(_mapCart(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to apply promo code'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error applying promo code'));
    }
  }

  @override
  Future<Result<Cart>> removePromoCode() async {
    try {
      final response = await _apiClient.dio.delete('/cart/promo');
      return Success(_mapCart(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to remove promo code'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error removing promo code'));
    }
  }

  Map<String, dynamic> _buildCartItemPayload(CartItem item) {
    String? variantId;
    List<String> addonIds = [];

    // Extract variantId if present
    final variantGroupId = 'variants_group_${item.menuItemId}';
    if (item.selectedOptions.containsKey(variantGroupId)) {
      final variantSelections = item.selectedOptions[variantGroupId];
      if (variantSelections != null && variantSelections.isNotEmpty) {
        variantId = variantSelections.first;
      }
    }

    // Extract all other selected options as addonIds
    item.selectedOptions.forEach((groupId, options) {
      if (groupId != variantGroupId) {
        addonIds.addAll(options);
      }
    });

    // Add nested selections if any
    item.nestedSelections.forEach((optionId, nestedGroups) {
      nestedGroups.forEach((groupId, options) {
        addonIds.addAll(options);
      });
    });

    final payload = <String, dynamic>{
      'menuItemId': item.menuItemId,
      'quantity': item.quantity,
    };
    if (variantId != null) {
      payload['variantId'] = variantId;
    }
    if (addonIds.isNotEmpty) {
      payload['addonIds'] = addonIds.toSet().toList(); // unique
    }
    if (item.specialInstructions.trim().isNotEmpty) {
      payload['specialInstructions'] = item.specialInstructions.trim();
    }
    return payload;
  }

  Cart _mapCart(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?) ?? [];
    final parsedItems = itemsList.map((i) => _mapCartItem(i)).toList();

    // Calculate subtotal from items as requested
    final subtotal = parsedItems.fold<double>(
      0.0,
      (sum, item) => sum + item.lineTotal,
    );
    final deliveryFee = (json['deliveryFee'] as num?)?.toDouble() ?? 0.0;

    // Attempt approximate discount display if promo is applied
    double discountTotal = 0.0;
    String? promoCodeId;
    if (json['appliedPromo'] != null) {
      final promo = json['appliedPromo'];
      promoCodeId = promo['code'];
      // Just a visual approximation since backend doesn't return computed discount on the cart object
      if (promo['discountType'] == 'PERCENT') {
        final pct = (promo['value'] as num).toDouble();
        discountTotal = subtotal * (pct / 100);
        if (promo['maxDiscountAmount'] != null) {
          final maxD = (promo['maxDiscountAmount'] as num).toDouble();
          if (discountTotal > maxD && maxD > 0) discountTotal = maxD;
        }
      } else if (promo['discountType'] == 'FIXED') {
        discountTotal = (promo['value'] as num).toDouble();
      }
    }

    final taxRate = (json['taxRate'] as num?)?.toDouble() ?? 0.0;
    final taxableAmount = (subtotal - discountTotal) > 0
        ? (subtotal - discountTotal)
        : 0;
    final taxTotal = taxableAmount * (taxRate / 100);
    final grandTotal = subtotal - discountTotal + deliveryFee + taxTotal;

    return Cart(
      id: 'remote_cart',
      items: parsedItems,
      promoCodeId: promoCodeId,
      deliveryFee: deliveryFee,
      subtotal: subtotal,
      discountTotal: discountTotal,
      taxTotal: taxTotal,
      grandTotal: grandTotal,
    );
  }

  CartItem _mapCartItem(Map<String, dynamic> json) {
    final menuItem = json['menuItem'] ?? {};
    final selectedVariant = json['selectedVariant'];
    final selectedAddons = (json['selectedAddons'] as List?) ?? [];

    Map<String, List<String>> selectedOptions = {};

    // Map variant back into the options map
    if (selectedVariant != null) {
      selectedOptions['variants_group_${menuItem["id"]}'] = [
        selectedVariant['id'],
      ];
    }

    // Addons go into a generic addon group for the UI (if we had the exact group ID it would be better, but we don't have it in the cart response)
    // The UI mainly needs this for display or matching.
    if (selectedAddons.isNotEmpty) {
      selectedOptions['addons'] = selectedAddons
          .map((a) => a['id'].toString())
          .toList();
    }

    return CartItem(
      id: json['id'],
      menuItemId: menuItem['id'] ?? '',
      productName: menuItem['nameEn'] ?? menuItem['nameAr'] ?? 'Unknown',
      productImage: menuItem['imageUrl'] ?? '',
      basePrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      specialInstructions: json['specialInstructions'] ?? '',
      selectedOptions: selectedOptions,
      isAvailable: json['isAvailable'] ?? true,
      menuItemBasePrice: (menuItem['basePrice'] as num?)?.toDouble(),
      menuItemDiscountPrice: (menuItem['salePrice'] as num?)?.toDouble(),
    );
  }
}
