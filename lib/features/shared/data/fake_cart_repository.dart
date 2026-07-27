import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/cart_repository.dart';

class FakeCartRepository implements CartRepository {
  Cart _cart = const Cart(id: 'cart_1', items: []);
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cart_state');
    if (data != null) {
      try {
        _cart = Cart.fromJson(json.decode(data));
      } catch (e) {
        _cart = const Cart(id: 'cart_1', items: []);
      }
    }
    _initialized = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart_state', json.encode(_cart.toJson()));
  }

  @override
  Future<Result<Cart>> getCart() async {
    await _init();
    return Success(_cart);
  }

  @override
  Future<Result<Cart>> addItem(CartItem item) async {
    await _init();
    final newItems = List<CartItem>.from(_cart.items)..add(item);
    _cart = _cart.copyWith(
      items: newItems,
      subtotal: _calculateSubtotal(newItems),
      grandTotal:
          _calculateSubtotal(newItems) +
          _cart.deliveryFee -
          _cart.discountTotal,
    );
    await _save();
    return Success(_cart);
  }

  @override
  Future<Result<Cart>> removeItem(String cartItemId) async {
    await _init();
    final newItems = List<CartItem>.from(_cart.items)
      ..removeWhere((i) => i.id == cartItemId);
    _cart = _cart.copyWith(
      items: newItems,
      subtotal: _calculateSubtotal(newItems),
      grandTotal:
          _calculateSubtotal(newItems) +
          _cart.deliveryFee -
          _cart.discountTotal,
    );
    await _save();
    return Success(_cart);
  }

  @override
  Future<Result<Cart>> updateItemQuantity(
    String cartItemId,
    int quantity,
  ) async {
    await _init();
    final newItems = _cart.items.map((i) {
      if (i.id == cartItemId) {
        return i.copyWith(
          quantity: quantity,
          lineTotal: i.unitPrice * quantity,
        );
      }
      return i;
    }).toList();
    _cart = _cart.copyWith(
      items: newItems,
      subtotal: _calculateSubtotal(newItems),
      grandTotal:
          _calculateSubtotal(newItems) +
          _cart.deliveryFee -
          _cart.discountTotal,
    );
    await _save();
    return Success(_cart);
  }

  @override
  Future<Result<Cart>> clearCart() async {
    await _init();
    _cart = const Cart(id: 'cart_1', items: []);
    await _save();
    return Success(_cart);
  }

  @override
  Future<Result<Cart>> applyPromoCode(String promoCodeId) async {
    await _init();
    _cart = _cart.copyWith(promoCodeId: promoCodeId, discountTotal: 50.0);
    _cart = _cart.copyWith(
      grandTotal: _cart.subtotal + _cart.deliveryFee - _cart.discountTotal,
    );
    await _save();
    return Success(_cart);
  }

  @override
  Future<Result<Cart>> removePromoCode() async {
    await _init();
    _cart = _cart.copyWith(promoCodeId: null, discountTotal: 0.0);
    _cart = _cart.copyWith(
      grandTotal: _cart.subtotal + _cart.deliveryFee - _cart.discountTotal,
    );
    await _save();
    return Success(_cart);
  }

  double _calculateSubtotal(List<CartItem> items) {
    return items.fold(0.0, (sum, i) => sum + i.lineTotal);
  }
}
