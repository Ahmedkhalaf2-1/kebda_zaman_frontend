import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';

/// Cart repository interface per md1 §18.
abstract class CartRepository {
  Future<Result<Cart>> getCart();
  Future<Result<Cart>> addItem(CartItem item);
  Future<Result<Cart>> updateItemQuantity(String itemId, int quantity);
  Future<Result<Cart>> removeItem(String itemId);
  Future<Result<Cart>> applyPromoCode(String code);
  Future<Result<Cart>> clearCart();
  Future<Result<Cart>> removePromoCode();
}
