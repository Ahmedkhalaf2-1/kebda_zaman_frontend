import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/favorites_repository.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  final List<MenuItem> _favorites = [];

  @override
  Future<Result<List<MenuItem>>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(List.unmodifiable(_favorites));
  }

  @override
  Future<Result<List<MenuItem>>> addFavorite(String menuItemId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(List.unmodifiable(_favorites));
  }

  @override
  Future<Result<void>> removeFavorite(String menuItemId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favorites.removeWhere((item) => item.id == menuItemId);
    return const Success(null);
  }
}
