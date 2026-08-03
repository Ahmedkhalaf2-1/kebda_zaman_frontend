import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_food_form_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/menu_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Focused tests for Admin Catalog VO3 metadata management: calories,
/// compare-at price, badge, and Often Ordered With recommendations on the
/// shared create/edit form (`AdminFoodFormScreen`). Uses a deterministic
/// in-memory [MenuRepository] spy (not [FakeMenuRepository], which has
/// randomized delay/failure and asset/SharedPreferences dependencies
/// unnecessary here) to capture exactly what create/update submit.
class _SpyMenuRepository implements MenuRepository {
  final List<Category> categories;
  final List<MenuItem> catalogItems;
  MenuItem? lastSaved;
  int createCalls = 0;
  int updateCalls = 0;

  _SpyMenuRepository({required this.categories, this.catalogItems = const []});

  @override
  Future<Result<List<Category>>> getAdminCategories() async =>
      Success(categories);

  @override
  Future<Result<List<MenuItem>>> getAdminMenuItems({
    String? categoryId,
    String? query,
  }) async => Success(catalogItems);

  @override
  Future<Result<void>> createMenuItem(MenuItem item) async {
    createCalls++;
    lastSaved = item;
    return const Success(null);
  }

  @override
  Future<Result<void>> updateMenuItem(MenuItem item) async {
    updateCalls++;
    lastSaved = item;
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteMenuItem(String id) async =>
      throw UnimplementedError();
  @override
  Future<Result<void>> createCategory(Category category) async =>
      throw UnimplementedError();
  @override
  Future<Result<void>> updateCategory(Category category) async =>
      throw UnimplementedError();
  @override
  Future<Result<void>> deleteCategory(String id) async =>
      throw UnimplementedError();
  @override
  Future<Result<String>> uploadImage(List<int> bytes, String filename) async =>
      throw UnimplementedError();
  @override
  Future<Result<List<Category>>> getCategories() async =>
      throw UnimplementedError();
  @override
  Future<Result<Category>> getCategoryById(String id) async =>
      throw UnimplementedError();
  @override
  Future<Result<List<MenuItem>>> getMenuItems({String? categoryId}) async =>
      throw UnimplementedError();
  @override
  Future<Result<MenuItem>> getMenuItemById(String id) async =>
      throw UnimplementedError();
  @override
  Future<Result<List<MenuItem>>> getFeaturedItems() async =>
      throw UnimplementedError();
  @override
  Future<Result<List<MenuItem>>> getBestSellers() async =>
      throw UnimplementedError();
  @override
  Future<Result<List<MenuItem>>> searchItems(String query) async =>
      throw UnimplementedError();
}

MenuItem _item(
  String id, {
  String? name,
  double basePrice = 20,
  int? calories,
  double? compareAtPrice,
  MenuItemBadge? badge,
  List<MenuItem> oftenOrderedWith = const [],
}) => MenuItem(
  id: id,
  categoryId: 'c1',
  name: name ?? 'Item $id',
  description: 'Description',
  imageUrl: '',
  basePrice: basePrice,
  calories: calories,
  compareAtPrice: compareAtPrice,
  badge: badge,
  oftenOrderedWith: oftenOrderedWith,
);

Future<_SpyMenuRepository> _pumpForm(
  WidgetTester tester, {
  MenuItem? existingItem,
  List<MenuItem> catalogItems = const [],
}) async {
  final repo = _SpyMenuRepository(
    categories: const [Category(id: 'c1', name: 'Sandwiches')],
    catalogItems: catalogItems,
  );

  // The form's ListView is a sliver-backed lazy list: fields far down the
  // page (calories, compare-at price, badge, recommendations) are never
  // built unless they're within (or near) the viewport. A tall viewport
  // avoids needing scrollUntilVisible for every field under test.
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (c, s) => const Scaffold(body: SizedBox()),
      ),
      GoRoute(
        path: '/form',
        builder: (c, s) => AdminFoodFormScreen(existingItem: existingItem),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [menuRepositoryProvider.overrideWithValue(repo)],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        saveLocale: false,
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            );
          },
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();

  router.push('/form');
  await tester.pumpAndSettle();

  if (existingItem == null) {
    // Required fields not under test here — fill them so validate() isn't
    // blocked by unrelated basic-info requirements.
    await tester.enterText(
      find.byKey(const Key('product_name_field')),
      'Test Product',
    );
    await tester.enterText(
      find.byKey(const Key('product_description_field')),
      'Test description',
    );
  }

  return repo;
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('form.save_product'.tr()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('form.save_product'.tr()));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('calories', () {
    testWidgets('empty calories is allowed and saves as null', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.createCalls, 1);
      expect(repo.lastSaved?.calories, isNull);
    });

    testWidgets('integer calories is accepted', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await tester.enterText(find.byKey(const Key('calories_field')), '450');
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.calories, 450);
    });

    testWidgets('zero calories is accepted', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await tester.enterText(find.byKey(const Key('calories_field')), '0');
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.calories, 0);
    });

    testWidgets('negative calories is rejected and blocks submission', (
      tester,
    ) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await tester.enterText(find.byKey(const Key('calories_field')), '-5');
      await _save(tester);

      expect(repo.createCalls, 0);
      expect(find.text('admin_catalog.calories_invalid'.tr()), findsOneWidget);
    });

    testWidgets('decimal calories is rejected and blocks submission', (
      tester,
    ) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await tester.enterText(find.byKey(const Key('calories_field')), '12.5');
      await _save(tester);

      expect(repo.createCalls, 0);
      expect(find.text('admin_catalog.calories_invalid'.tr()), findsOneWidget);
    });

    testWidgets('existing calories value prepopulates on edit', (tester) async {
      await _pumpForm(tester, existingItem: _item('m1', calories: 300));

      final field = tester.widget<TextFormField>(
        find.byKey(const Key('calories_field')),
      );
      expect(field.controller?.text, '300');
    });

    testWidgets('clearing calories on edit sends null on update', (
      tester,
    ) async {
      final repo = await _pumpForm(
        tester,
        existingItem: _item('m1', calories: 300),
      );
      await tester.enterText(find.byKey(const Key('calories_field')), '');
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.updateCalls, 1);
      expect(repo.lastSaved?.calories, isNull);
    });
  });

  group('compare-at price', () {
    testWidgets('empty compare-at price is allowed', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.compareAtPrice, isNull);
    });

    testWidgets('greater than basePrice is accepted', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await tester.enterText(
        find.byKey(const Key('compare_at_price_field')),
        '30',
      );
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.compareAtPrice, 30);
    });

    testWidgets('equal to basePrice is rejected', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await tester.enterText(
        find.byKey(const Key('compare_at_price_field')),
        '20',
      );
      await _save(tester);

      expect(repo.createCalls, 0);
      expect(
        find.text('admin_catalog.compare_at_price_invalid'.tr()),
        findsOneWidget,
      );
    });

    testWidgets('less than basePrice is rejected', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await tester.enterText(
        find.byKey(const Key('compare_at_price_field')),
        '15',
      );
      await _save(tester);

      expect(repo.createCalls, 0);
      expect(
        find.text('admin_catalog.compare_at_price_invalid'.tr()),
        findsOneWidget,
      );
    });

    testWidgets('existing compare-at price prepopulates on edit', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        existingItem: _item('m1', basePrice: 20, compareAtPrice: 30),
      );

      final field = tester.widget<TextFormField>(
        find.byKey(const Key('compare_at_price_field')),
      );
      expect(field.controller?.text, '30.0');
    });

    testWidgets('clearing compare-at price on edit sends null', (tester) async {
      final repo = await _pumpForm(
        tester,
        existingItem: _item('m1', basePrice: 20, compareAtPrice: 30),
      );
      await tester.enterText(
        find.byKey(const Key('compare_at_price_field')),
        '',
      );
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.compareAtPrice, isNull);
    });

    testWidgets(
      'raising basePrice above an already-entered compare-at price shows '
      'the error live',
      (tester) async {
        await _pumpForm(tester);
        await tester.enterText(find.byKey(const Key('base_price_field')), '20');
        await tester.enterText(
          find.byKey(const Key('compare_at_price_field')),
          '25',
        );
        await tester.pumpAndSettle();
        expect(
          find.text('admin_catalog.compare_at_price_invalid'.tr()),
          findsNothing,
        );

        await tester.enterText(find.byKey(const Key('base_price_field')), '30');
        await tester.pumpAndSettle();

        expect(
          find.text('admin_catalog.compare_at_price_invalid'.tr()),
          findsOneWidget,
        );
      },
    );
  });

  group('badge', () {
    testWidgets('No Badge sends null', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.badge, isNull);
    });

    testWidgets('Bestseller badge selection saves as bestseller', (
      tester,
    ) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');

      await tester.ensureVisible(find.byKey(const Key('badge_dropdown')));
      await tester.tap(find.byKey(const Key('badge_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('admin_catalog.badge_bestseller'.tr()).last);
      await tester.pumpAndSettle();

      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.badge, MenuItemBadge.bestseller);
    });

    testWidgets('Top Rated badge selection saves as topRated', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');

      await tester.ensureVisible(find.byKey(const Key('badge_dropdown')));
      await tester.tap(find.byKey(const Key('badge_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('admin_catalog.badge_top_rated'.tr()).last);
      await tester.pumpAndSettle();

      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.badge, MenuItemBadge.topRated);
    });

    testWidgets('selecting a badge does not toggle isPopular/best-seller', (
      tester,
    ) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');

      await tester.ensureVisible(find.byKey(const Key('badge_dropdown')));
      await tester.tap(find.byKey(const Key('badge_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('admin_catalog.badge_bestseller'.tr()).last);
      await tester.pumpAndSettle();

      await _save(tester);

      expect(repo.lastSaved?.isBestSeller, false);
      expect(repo.lastSaved?.isFeatured, false);
    });

    testWidgets('existing badge prepopulates on edit', (tester) async {
      await _pumpForm(
        tester,
        existingItem: _item('m1', badge: MenuItemBadge.topRated),
      );
      await tester.pumpAndSettle();

      expect(find.text('admin_catalog.badge_top_rated'.tr()), findsOneWidget);
    });
  });

  group('recommendations', () {
    testWidgets('empty recommendations is allowed', (tester) async {
      final repo = await _pumpForm(tester);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await _save(tester);

      expect(tester.takeException(), isNull);
      expect(repo.lastSaved?.oftenOrderedWith, isEmpty);
    });

    testWidgets('selecting one item adds it to the recommendation list', (
      tester,
    ) async {
      final fries = _item('rec1', name: 'Fries', basePrice: 12);
      final repo = await _pumpForm(tester, catalogItems: [fries]);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');

      await tester.ensureVisible(
        find.text('admin_catalog.search_recommendations'.tr()),
      );
      await tester.tap(find.text('admin_catalog.search_recommendations'.tr()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fries'));
      await tester.pumpAndSettle();

      expect(find.text('Fries'), findsOneWidget);

      await _save(tester);
      expect(repo.lastSaved?.oftenOrderedWith.map((r) => r.id), ['rec1']);
    });

    testWidgets('a fourth selection is blocked once 3 are selected', (
      tester,
    ) async {
      final catalog = [
        _item('rec1', name: 'Fries'),
        _item('rec2', name: 'Drink'),
        _item('rec3', name: 'Salad'),
        _item('rec4', name: 'Cake'),
      ];
      await _pumpForm(
        tester,
        existingItem: _item(
          'm1',
          oftenOrderedWith: [catalog[0], catalog[1], catalog[2]],
        ),
        catalogItems: catalog,
      );

      // The "Add" button is disabled once 3 recommendations are selected —
      // tapping it must not open the picker or add a 4th recommendation.
      expect(
        find.text('admin_catalog.max_recommendations'.tr()),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.text('admin_catalog.search_recommendations'.tr()),
      );
      await tester.tap(find.text('admin_catalog.search_recommendations'.tr()));
      await tester.pumpAndSettle();

      expect(
        find.text('admin_catalog.search_recommendations'.tr()),
        findsOneWidget,
      );
      expect(find.text('Cake'), findsNothing);
    });

    testWidgets('picker excludes already-selected items (no duplicates)', (
      tester,
    ) async {
      final fries = _item('rec1', name: 'Fries');
      final drink = _item('rec2', name: 'Drink');
      await _pumpForm(
        tester,
        existingItem: _item('m1', oftenOrderedWith: [fries]),
        catalogItems: [fries, drink],
      );

      await tester.ensureVisible(
        find.text('admin_catalog.search_recommendations'.tr()),
      );
      await tester.tap(find.text('admin_catalog.search_recommendations'.tr()));
      await tester.pumpAndSettle();

      // Fries is already selected — it must not appear again in the picker
      // (scoped to the picker's own ListTile rows, since "Fries" also
      // legitimately renders in the already-selected recommendations list
      // on the form underneath the dialog).
      expect(find.widgetWithText(ListTile, 'Drink'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Fries'), findsNothing);
    });

    testWidgets('picker excludes the current product itself in Edit mode', (
      tester,
    ) async {
      final self = _item('m1', name: 'Burger');
      final other = _item('rec1', name: 'Fries');
      await _pumpForm(tester, existingItem: self, catalogItems: [self, other]);

      await tester.ensureVisible(
        find.text('admin_catalog.search_recommendations'.tr()),
      );
      await tester.tap(find.text('admin_catalog.search_recommendations'.tr()));
      await tester.pumpAndSettle();

      // "Burger" (the current product's own name) must never appear as a
      // selectable row in the picker — scoped to the picker's ListTile rows
      // since the product name field itself also legitimately renders
      // "Burger" text underneath the dialog.
      expect(find.widgetWithText(ListTile, 'Fries'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Burger'), findsNothing);
    });

    testWidgets('removing a selected recommendation works', (tester) async {
      final fries = _item('rec1', name: 'Fries');
      final repo = await _pumpForm(
        tester,
        existingItem: _item('m1', oftenOrderedWith: [fries]),
        catalogItems: [fries],
      );

      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.close_rounded).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Fries'), findsNothing);
      await _save(tester);
      expect(repo.lastSaved?.oftenOrderedWith, isEmpty);
    });

    testWidgets('clearing all recommendations sends an empty list', (
      tester,
    ) async {
      final fries = _item('rec1', name: 'Fries');
      final drink = _item('rec2', name: 'Drink');
      final repo = await _pumpForm(
        tester,
        existingItem: _item('m1', oftenOrderedWith: [fries, drink]),
        catalogItems: [fries, drink],
      );

      for (var i = 0; i < 2; i++) {
        await tester.tap(
          find.widgetWithIcon(IconButton, Icons.close_rounded).first,
        );
        await tester.pumpAndSettle();
      }

      await _save(tester);
      expect(repo.lastSaved?.oftenOrderedWith, isEmpty);
    });

    testWidgets('reordering moves an item and updates outgoing id order', (
      tester,
    ) async {
      final fries = _item('rec1', name: 'Fries');
      final drink = _item('rec2', name: 'Drink');
      final repo = await _pumpForm(
        tester,
        existingItem: _item('m1', oftenOrderedWith: [fries, drink]),
        catalogItems: [fries, drink],
      );

      // Move the second item ("Drink") up, ahead of "Fries".
      await tester.tap(
        find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded).last,
      );
      await tester.pumpAndSettle();

      await _save(tester);
      expect(repo.lastSaved?.oftenOrderedWith.map((r) => r.id), [
        'rec2',
        'rec1',
      ]);
    });

    testWidgets('existing recommendation order prepopulates from the item', (
      tester,
    ) async {
      final fries = _item('rec1', name: 'Fries');
      final drink = _item('rec2', name: 'Drink');
      await _pumpForm(
        tester,
        existingItem: _item('m1', oftenOrderedWith: [drink, fries]),
        catalogItems: [fries, drink],
      );

      final tiles = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      expect(tiles.indexOf('Drink'), lessThan(tiles.indexOf('Fries')));
    });

    testWidgets('search uses the real catalog (from menuAdminProvider), '
        'not fake/static data', (tester) async {
      final realItem = _item('rec1', name: 'Real Catalog Item');
      await _pumpForm(tester, catalogItems: [realItem]);

      await tester.ensureVisible(
        find.text('admin_catalog.search_recommendations'.tr()),
      );
      await tester.tap(find.text('admin_catalog.search_recommendations'.tr()));
      await tester.pumpAndSettle();

      expect(find.text('Real Catalog Item'), findsOneWidget);
    });
  });

  group('submission', () {
    testWidgets('create request includes all VO3 fields', (tester) async {
      final rec = _item('rec1', name: 'Fries');
      final repo = await _pumpForm(tester, catalogItems: [rec]);
      await tester.enterText(find.byKey(const Key('base_price_field')), '20');
      await tester.enterText(find.byKey(const Key('calories_field')), '400');
      await tester.enterText(
        find.byKey(const Key('compare_at_price_field')),
        '30',
      );

      await tester.ensureVisible(find.byKey(const Key('badge_dropdown')));
      await tester.tap(find.byKey(const Key('badge_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('admin_catalog.badge_bestseller'.tr()).last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.text('admin_catalog.search_recommendations'.tr()),
      );
      await tester.tap(find.text('admin_catalog.search_recommendations'.tr()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fries'));
      await tester.pumpAndSettle();

      await _save(tester);

      expect(repo.createCalls, 1);
      expect(repo.lastSaved?.calories, 400);
      expect(repo.lastSaved?.compareAtPrice, 30);
      expect(repo.lastSaved?.badge, MenuItemBadge.bestseller);
      expect(repo.lastSaved?.oftenOrderedWith.map((r) => r.id), ['rec1']);
    });

    testWidgets('update preserves untouched VO3 fields', (tester) async {
      final rec = _item('rec1', name: 'Fries');
      final existing = _item(
        'm1',
        basePrice: 20,
        calories: 500,
        compareAtPrice: 35,
        badge: MenuItemBadge.topRated,
        oftenOrderedWith: [rec],
      );
      final repo = await _pumpForm(
        tester,
        existingItem: existing,
        catalogItems: [rec],
      );

      // Touch nothing VO3-related — just save.
      await _save(tester);

      expect(repo.updateCalls, 1);
      expect(repo.lastSaved?.calories, 500);
      expect(repo.lastSaved?.compareAtPrice, 35);
      expect(repo.lastSaved?.badge, MenuItemBadge.topRated);
      expect(repo.lastSaved?.oftenOrderedWith.map((r) => r.id), ['rec1']);
    });

    testWidgets('existing variants/modifier groups remain unchanged on save', (
      tester,
    ) async {
      const existing = MenuItem(
        id: 'm1',
        categoryId: 'c1',
        name: 'Burger',
        description: 'd',
        imageUrl: '',
        basePrice: 20,
        modifierGroups: [
          ModifierGroup(
            id: 'g1',
            name: 'Size',
            options: [ModifierOption(id: 'o1', name: 'Small')],
          ),
        ],
      );
      final repo = await _pumpForm(tester, existingItem: existing);

      await _save(tester);

      expect(repo.lastSaved?.modifierGroups.length, 1);
      expect(repo.lastSaved?.modifierGroups.first.id, 'g1');
    });
  });
}
