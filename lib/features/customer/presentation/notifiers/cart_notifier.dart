import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/result.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';

class CartNotifier extends AutoDisposeAsyncNotifier<Cart?> {
  @override
  Future<Cart?> build() async {
    return _fetchCart();
  }

  Future<Cart?> _fetchCart() async {
    // Do not issue GET /cart while unauthenticated — the route is protected
    // and issuing it after logout (while the UI still holds the provider)
    // would produce a 401 and unnecessary noise.
    final authState = ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) return null;

    final repo = ref.read(cartRepositoryProvider);
    final result = await repo.getCart();
    return result.fold((f) => throw f, (data) => data);
  }

  Future<void> addItem(CartItem item) async {
    state = const AsyncLoading<Cart?>().copyWithPrevious(state);
    final repo = ref.read(cartRepositoryProvider);
    final result = await repo.addItem(item);

    return result.fold(
      (failure) {
        // Reset state by refetching, then throw to let UI handle the error
        AsyncValue.guard(_fetchCart).then((s) => state = s);
        throw Exception(failure.message);
      },
      (data) async {
        state = await AsyncValue.guard(_fetchCart);
      },
    );
  }

  Future<void> updateItem(String itemId, int quantity) async {
    state = const AsyncLoading<Cart?>().copyWithPrevious(state);
    final repo = ref.read(cartRepositoryProvider);
    final result = await repo.updateItemQuantity(itemId, quantity);
    return result.fold((failure) {
      AsyncValue.guard(_fetchCart).then((s) => state = s);
      throw Exception(failure.message);
    }, (data) async => state = await AsyncValue.guard(_fetchCart));
  }

  Future<void> removeItem(String itemId) async {
    state = const AsyncLoading<Cart?>().copyWithPrevious(state);
    final repo = ref.read(cartRepositoryProvider);
    final result = await repo.removeItem(itemId);
    return result.fold((failure) {
      AsyncValue.guard(_fetchCart).then((s) => state = s);
      throw Exception(failure.message);
    }, (data) async => state = await AsyncValue.guard(_fetchCart));
  }

  Future<void> replaceItem(String oldItemId, CartItem newItem) async {
    state = const AsyncLoading<Cart?>().copyWithPrevious(state);
    final repo = ref.read(cartRepositoryProvider);
    // Replace by removing old and adding new
    final removeResult = await repo.removeItem(oldItemId);
    if (removeResult is Err) {
      AsyncValue.guard(_fetchCart).then((s) => state = s);
      throw Exception(removeResult.failure.message);
    }
    final addResult = await repo.addItem(newItem);
    if (addResult is Err) {
      AsyncValue.guard(_fetchCart).then((s) => state = s);
      throw Exception(addResult.failure.message);
    }
    state = await AsyncValue.guard(_fetchCart);
  }

  Future<void> applyPromoCode(String code) async {
    state = const AsyncLoading<Cart?>().copyWithPrevious(state);
    final repo = ref.read(cartRepositoryProvider);
    final result = await repo.applyPromoCode(code);
    return result.fold((failure) {
      // Refetch the real server cart so a rejected promo never leaves the
      // UI showing a discount that was never actually applied.
      AsyncValue.guard(_fetchCart).then((s) => state = s);
      // Thrown as the Failure itself (not a generic Exception) so the UI can
      // inspect failure.cause for the backend's error code — e.g.
      // PROMO_ALREADY_USED — and pick a specific localized message.
      throw failure;
    }, (data) async => state = await AsyncValue.guard(_fetchCart));
  }

  Future<void> removePromoCode() async {
    state = const AsyncLoading<Cart?>().copyWithPrevious(state);
    final repo = ref.read(cartRepositoryProvider);
    final result = await repo.removePromoCode();
    return result.fold((failure) {
      AsyncValue.guard(_fetchCart).then((s) => state = s);
      throw Exception(failure.message);
    }, (data) async => state = await AsyncValue.guard(_fetchCart));
  }

  Future<void> clearCart() async {
    state = const AsyncLoading<Cart?>().copyWithPrevious(state);
    final repo = ref.read(cartRepositoryProvider);
    final result = await repo.clearCart();
    return result.fold((failure) {
      AsyncValue.guard(_fetchCart).then((s) => state = s);
      throw Exception(failure.message);
    }, (data) async => state = await AsyncValue.guard(_fetchCart));
  }
}

final cartProvider = AutoDisposeAsyncNotifierProvider<CartNotifier, Cart?>(
  () => CartNotifier(),
);
