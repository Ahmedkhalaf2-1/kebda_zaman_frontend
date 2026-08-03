import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/data/api_menu_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// Focused tests for the admin create/update wire payload built by
/// [ApiMenuRepository], exercised via the `@visibleForTesting` seam
/// `buildMenuItemPayloadForTesting` (shared by both createMenuItem and
/// updateMenuItem). Covers the VO3 metadata fields added in Phase 4:
/// calories, compareAtPrice, badge (enum -> wire string), and
/// recommendationItemIds (derived from oftenOrderedWith's parent MenuItem
/// ids only — never variant ids, never nested).
void main() {
  MenuItem baseItem({
    int? calories,
    double? compareAtPrice,
    MenuItemBadge? badge,
    List<MenuItem> oftenOrderedWith = const [],
  }) => MenuItem(
    id: 'm1',
    categoryId: 'c1',
    name: 'Item',
    description: 'Description',
    imageUrl: '',
    basePrice: 20,
    calories: calories,
    compareAtPrice: compareAtPrice,
    badge: badge,
    oftenOrderedWith: oftenOrderedWith,
  );

  group('calories', () {
    test('null calories serializes to null', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(),
      );
      expect(payload['calories'], isNull);
    });

    test('integer calories passes through unchanged', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(calories: 450),
      );
      expect(payload['calories'], 450);
    });
  });

  group('compareAtPrice', () {
    test('null compareAtPrice serializes to null', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(),
      );
      expect(payload['compareAtPrice'], isNull);
    });

    test('compareAtPrice passes through unchanged', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(compareAtPrice: 60),
      );
      expect(payload['compareAtPrice'], 60);
    });
  });

  group('badge', () {
    test('null badge serializes to null', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(),
      );
      expect(payload['badge'], isNull);
    });

    test('bestseller badge serializes to BESTSELLER', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(badge: MenuItemBadge.bestseller),
      );
      expect(payload['badge'], 'BESTSELLER');
    });

    test('top rated badge serializes to TOP_RATED', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(badge: MenuItemBadge.topRated),
      );
      expect(payload['badge'], 'TOP_RATED');
    });

    test('badge is independent of isPopular in the payload', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        const MenuItem(
          id: 'm1',
          categoryId: 'c1',
          name: 'Item',
          description: 'Description',
          imageUrl: '',
          basePrice: 20,
          badge: MenuItemBadge.bestseller,
          isFeatured: false,
        ),
      );
      expect(payload['badge'], 'BESTSELLER');
      expect(payload['isPopular'], false);
    });
  });

  group('recommendationItemIds', () {
    test('empty oftenOrderedWith serializes to an empty list', () {
      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(),
      );
      expect(payload['recommendationItemIds'], <String>[]);
    });

    test('sends parent MenuItem ids in order, never variant ids', () {
      const rec1 = MenuItem(
        id: 'rec-1',
        categoryId: 'c1',
        name: 'Fries',
        description: 'd',
        imageUrl: '',
        basePrice: 12,
        modifierGroups: [
          ModifierGroup(
            id: 'variant-group',
            name: 'Size',
            options: [
              ModifierOption(id: 'variant-small', name: 'Small'),
              ModifierOption(id: 'variant-large', name: 'Large'),
            ],
          ),
        ],
      );
      const rec2 = MenuItem(
        id: 'rec-2',
        categoryId: 'c1',
        name: 'Drink',
        description: 'd',
        imageUrl: '',
        basePrice: 8,
      );

      final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(
        baseItem(oftenOrderedWith: [rec1, rec2]),
      );

      expect(payload['recommendationItemIds'], ['rec-1', 'rec-2']);
    });
  });

  test('create and update use the identical payload shape', () {
    final item = baseItem(
      calories: 300,
      compareAtPrice: 50,
      badge: MenuItemBadge.topRated,
      oftenOrderedWith: const [
        MenuItem(
          id: 'rec-1',
          categoryId: 'c1',
          name: 'Fries',
          description: 'd',
          imageUrl: '',
          basePrice: 12,
        ),
      ],
    );
    final payload = ApiMenuRepository.buildMenuItemPayloadForTesting(item);

    expect(payload['calories'], 300);
    expect(payload['compareAtPrice'], 50);
    expect(payload['badge'], 'TOP_RATED');
    expect(payload['recommendationItemIds'], ['rec-1']);
    // Existing fields remain present alongside the new ones.
    expect(payload['categoryId'], 'c1');
    expect(payload['basePrice'], 20);
    expect(payload['isAvailable'], true);
  });
}
