import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/data/fake_favorites_repository.dart';

void main() {
  group('Favorites Repository Tests', () {
    test('FakeFavoritesRepository performs list, add, remove operations', () async {
      final repo = FakeFavoritesRepository();

      final listResult = await repo.getFavorites();
      expect(listResult.isSuccess, isTrue);
      expect(listResult.value.isEmpty, isTrue);

      final addResult = await repo.addFavorite('item-1');
      expect(addResult.isSuccess, isTrue);

      final removeResult = await repo.removeFavorite('item-1');
      expect(removeResult.isSuccess, isTrue);
    });
  });
}
