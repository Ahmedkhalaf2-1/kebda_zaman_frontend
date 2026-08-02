import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/data/api_menu_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// Focused mapping tests for [ApiMenuRepository]'s private `_mapMenuItem`,
/// exercised via the `@visibleForTesting` seam `mapMenuItemForTesting`. This
/// is the single mapper used by every menu endpoint (list, search, featured,
/// item details, admin list), so these cases cover all of them without
/// hitting a live backend.
void main() {
  Map<String, dynamic> baseItemJson({
    Object? compareAtPrice,
    Object? calories,
    Object? badge,
    Object? oftenOrderedWith,
  }) {
    return {
      'id': 'item-1',
      'categoryId': 'cat-1',
      'nameAr': 'اسم',
      'nameEn': 'Name',
      'descriptionAr': 'وصف',
      'descriptionEn': 'Description',
      'basePrice': 20,
      'compareAtPrice': compareAtPrice,
      'calories': calories,
      'badge': badge,
      'imageUrl': null,
      'isAvailable': true,
      'isPopular': false,
      'variants': [],
      'addonGroups': [],
      if (oftenOrderedWith != null) 'oftenOrderedWith': oftenOrderedWith,
    };
  }

  Map<String, dynamic> recommendationJson({
    String id = 'rec-1',
    Object? compareAtPrice,
    Object? calories,
    Object? badge,
    Object? oftenOrderedWith,
  }) {
    return {
      'id': id,
      'categoryId': 'cat-1',
      'nameAr': 'اسم',
      'nameEn': 'Rec',
      'descriptionAr': 'وصف',
      'descriptionEn': 'Rec description',
      'basePrice': 4,
      'compareAtPrice': compareAtPrice,
      'calories': calories,
      'badge': badge,
      'imageUrl': null,
      'isAvailable': true,
      'isPopular': false,
      if (oftenOrderedWith != null) 'oftenOrderedWith': oftenOrderedWith,
    };
  }

  group('badge parsing', () {
    test('BESTSELLER parses to bestseller', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(badge: 'BESTSELLER'),
      );
      expect(item.badge, MenuItemBadge.bestseller);
    });

    test('TOP_RATED parses to topRated', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(badge: 'TOP_RATED'),
      );
      expect(item.badge, MenuItemBadge.topRated);
    });

    test('null parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(badge: null),
      );
      expect(item.badge, isNull);
    });

    test('unknown badge parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(badge: 'MYSTERY'),
      );
      expect(item.badge, isNull);
    });
  });

  group('calories parsing', () {
    test('integer parses', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(calories: 500),
      );
      expect(item.calories, 500);
    });

    test('whole double parses', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(calories: 500.0),
      );
      expect(item.calories, 500);
    });

    test('numeric integer string parses', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(calories: '500'),
      );
      expect(item.calories, 500);
    });

    test('null parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(calories: null),
      );
      expect(item.calories, isNull);
    });

    test('fractional number parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(calories: 500.5),
      );
      expect(item.calories, isNull);
    });

    test('fractional string parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(calories: '500.5'),
      );
      expect(item.calories, isNull);
    });

    test('negative value parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(calories: -10),
      );
      expect(item.calories, isNull);
    });

    test('invalid string parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(calories: 'abc'),
      );
      expect(item.calories, isNull);
    });
  });

  group('compareAtPrice parsing', () {
    test('integer parses to double', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(compareAtPrice: 25),
      );
      expect(item.compareAtPrice, 25.0);
    });

    test('double parses', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(compareAtPrice: 25.5),
      );
      expect(item.compareAtPrice, 25.5);
    });

    test('numeric string parses', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(compareAtPrice: '25.00'),
      );
      expect(item.compareAtPrice, 25.0);
    });

    test('null parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(compareAtPrice: null),
      );
      expect(item.compareAtPrice, isNull);
    });

    test('negative value parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(compareAtPrice: -5),
      );
      expect(item.compareAtPrice, isNull);
    });

    test('invalid string parses to null', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(compareAtPrice: 'abc'),
      );
      expect(item.compareAtPrice, isNull);
    });
  });

  group('list/search/featured item parsing (no oftenOrderedWith)', () {
    test('item parses successfully when oftenOrderedWith is absent', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(baseItemJson());
      expect(item.id, 'item-1');
      expect(item.oftenOrderedWith, isEmpty);
    });

    test('existing variants and addonGroups still parse unchanged', () {
      final json = baseItemJson();
      json['variants'] = [
        {'id': 'v1', 'nameEn': 'Large', 'priceDelta': 5, 'isDefault': true},
      ];
      json['addonGroups'] = [
        {
          'id': 'g1',
          'titleEn': 'Extras',
          'isRequired': false,
          'minSelect': 0,
          'maxSelect': 2,
          'addons': [
            {'id': 'a1', 'nameEn': 'Cheese', 'price': 3},
          ],
        },
      ];
      final item = ApiMenuRepository.mapMenuItemForTesting(json);
      expect(item.modifierGroups.length, 2);
      expect(item.modifierGroups[0].options.single.name, 'Large');
      expect(item.modifierGroups[1].options.single.name, 'Cheese');
    });

    test('metadata fields parse correctly in list response', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(compareAtPrice: 25, calories: 500, badge: 'BESTSELLER'),
      );
      expect(item.compareAtPrice, 25.0);
      expect(item.calories, 500);
      expect(item.badge, MenuItemBadge.bestseller);
    });
  });

  group('details parsing (oftenOrderedWith)', () {
    test('oftenOrderedWith preserves backend order', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(
          oftenOrderedWith: [
            recommendationJson(id: 'rec-a'),
            recommendationJson(id: 'rec-b'),
            recommendationJson(id: 'rec-c'),
          ],
        ),
      );
      expect(item.oftenOrderedWith.map((e) => e.id).toList(), [
        'rec-a',
        'rec-b',
        'rec-c',
      ]);
    });

    test('omitted oftenOrderedWith becomes empty', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(baseItemJson());
      expect(item.oftenOrderedWith, isEmpty);
    });

    test('null oftenOrderedWith becomes empty', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(oftenOrderedWith: null),
      );
      expect(item.oftenOrderedWith, isEmpty);
    });

    test('recommendation summary parses without variants', () {
      final json = recommendationJson();
      expect(json.containsKey('variants'), isFalse);
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(oftenOrderedWith: [json]),
      );
      expect(item.oftenOrderedWith.single.modifierGroups, isEmpty);
    });

    test('recommendation summary parses without addonGroups', () {
      final json = recommendationJson();
      expect(json.containsKey('addonGroups'), isFalse);
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(oftenOrderedWith: [json]),
      );
      expect(item.oftenOrderedWith.single.modifierGroups, isEmpty);
    });

    test('nested oftenOrderedWith inside a recommendation is ignored', () {
      final nested = recommendationJson(id: 'rec-nested');
      final rec = recommendationJson(id: 'rec-1', oftenOrderedWith: [nested]);
      final item = ApiMenuRepository.mapMenuItemForTesting(
        baseItemJson(oftenOrderedWith: [rec]),
      );
      expect(item.oftenOrderedWith.single.oftenOrderedWith, isEmpty);
    });

    test(
      'compareAtPrice/calories/badge parse inside recommendation summary',
      () {
        final rec = recommendationJson(
          compareAtPrice: null,
          calories: 172,
          badge: null,
        );
        final item = ApiMenuRepository.mapMenuItemForTesting(
          baseItemJson(oftenOrderedWith: [rec]),
        );
        final parsed = item.oftenOrderedWith.single;
        expect(parsed.compareAtPrice, isNull);
        expect(parsed.calories, 172);
        expect(parsed.badge, isNull);
      },
    );
  });

  group('compatibility', () {
    test('old-format backend payload without new fields still parses', () {
      final oldFormatJson = {
        'id': 'item-old',
        'categoryId': 'cat-1',
        'nameAr': 'اسم',
        'nameEn': 'Old Item',
        'descriptionAr': 'وصف',
        'descriptionEn': 'Old description',
        'basePrice': 15,
        'imageUrl': null,
        'isAvailable': true,
        'isPopular': false,
        'variants': [],
        'addonGroups': [],
      };
      final item = ApiMenuRepository.mapMenuItemForTesting(oldFormatJson);
      expect(item.id, 'item-old');
      expect(item.compareAtPrice, isNull);
      expect(item.calories, isNull);
      expect(item.badge, isNull);
      expect(item.oftenOrderedWith, isEmpty);
    });

    test('copyWith and equality include new fields', () {
      final item = ApiMenuRepository.mapMenuItemForTesting(baseItemJson());
      final withBadge = item.copyWith(
        badge: MenuItemBadge.topRated,
        calories: 300,
        compareAtPrice: 10.0,
      );
      expect(withBadge, isNot(equals(item)));
      expect(withBadge.badge, MenuItemBadge.topRated);
      expect(withBadge.calories, 300);
      expect(withBadge.compareAtPrice, 10.0);

      final same = item.copyWith();
      expect(same, equals(item));
    });
  });
}
