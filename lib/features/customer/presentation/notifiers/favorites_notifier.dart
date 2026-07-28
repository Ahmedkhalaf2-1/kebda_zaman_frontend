import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

class FavoritesState {
  final List<MenuItem> favoriteItems;
  final Set<String> favoriteIds;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.favoriteItems = const [],
    this.favoriteIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    List<MenuItem>? favoriteItems,
    Set<String>? favoriteIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favoriteItems: favoriteItems ?? this.favoriteItems,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CustomerFavoritesNotifier extends StateNotifier<FavoritesState> {
  final Ref _ref;
  final Set<String> _mutatingIds = {};

  CustomerFavoritesNotifier(this._ref)
    : super(const FavoritesState(isLoading: true)) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final authState = _ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) {
      state = const FavoritesState(
        favoriteItems: [],
        favoriteIds: {},
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = _ref.read(favoritesRepositoryProvider);
    final result = await repo.getFavorites();

    result.fold(
      (failure) {
        if (!mounted) return;
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (items) {
        if (!mounted) return;
        state = FavoritesState(
          favoriteItems: items,
          favoriteIds: items.map((i) => i.id).toSet(),
          isLoading: false,
        );
      },
    );
  }

  Future<bool> toggleFavorite(String menuItemId) async {
    final authState = _ref.read(authNotifierProvider);
    if (!authState.isLoggedIn) return false;

    if (_mutatingIds.contains(menuItemId)) return false;
    _mutatingIds.add(menuItemId);

    try {
      final repo = _ref.read(favoritesRepositoryProvider);
      final isFav = state.favoriteIds.contains(menuItemId);
      final previousState = state;

      if (isFav) {
        final newIds = Set<String>.from(state.favoriteIds)..remove(menuItemId);
        final newItems = state.favoriteItems
            .where((i) => i.id != menuItemId)
            .toList();
        state = state.copyWith(
          favoriteIds: newIds,
          favoriteItems: newItems,
          errorMessage: null,
        );

        final result = await repo.removeFavorite(menuItemId);
        return result.fold(
          (failure) {
            if (!mounted) return false;
            state = previousState.copyWith(errorMessage: failure.message);
            return false;
          },
          (_) {
            return true;
          },
        );
      } else {
        final newIds = Set<String>.from(state.favoriteIds)..add(menuItemId);
        state = state.copyWith(favoriteIds: newIds, errorMessage: null);

        final result = await repo.addFavorite(menuItemId);
        return result.fold(
          (failure) {
            if (!mounted) return false;
            state = previousState.copyWith(errorMessage: failure.message);
            return false;
          },
          (updatedItems) {
            if (!mounted) return false;
            state = FavoritesState(
              favoriteItems: updatedItems,
              favoriteIds: updatedItems.map((i) => i.id).toSet(),
              isLoading: false,
            );
            return true;
          },
        );
      }
    } finally {
      _mutatingIds.remove(menuItemId);
    }
  }

  bool isFavorite(String menuItemId) => state.favoriteIds.contains(menuItemId);
}

final customerFavoritesProvider =
    StateNotifierProvider<CustomerFavoritesNotifier, FavoritesState>((ref) {
      return CustomerFavoritesNotifier(ref);
    });
