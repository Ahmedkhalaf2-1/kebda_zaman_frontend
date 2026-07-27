import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

abstract class FavoritesRepository {
  Future<Result<List<MenuItem>>> getFavorites();
  Future<Result<List<MenuItem>>> addFavorite(String menuItemId);
  Future<Result<void>> removeFavorite(String menuItemId);
}
