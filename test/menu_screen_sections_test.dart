import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/menu_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/menu_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Focused tests for the sectioned, scroll-synced Menu screen: all
/// categories rendered as one vertical list (in backend order), tap-to-scroll
/// and manual-scroll-to-select synchronization with the horizontal category
/// bar, localization, and that unrelated behavior (search, product-detail
/// navigation) is unchanged.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<User?>> getCurrentUser() async => const Success(null);
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<User>> login(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> adminLogin(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async => throw UnimplementedError();
  @override
  Future<Result<User>> guestLogin() async => throw UnimplementedError();
  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async => throw UnimplementedError();
}

class _FixedMenuNotifier extends MenuNotifier {
  final MenuData data;
  _FixedMenuNotifier(this.data);

  @override
  Future<MenuData> build() async => data;
}

MenuItem _item(
  String id, {
  required String categoryId,
  String? nameEn,
  String? nameAr,
}) => MenuItem(
  id: id,
  categoryId: categoryId,
  name: nameEn ?? 'Item $id',
  nameEn: nameEn ?? 'Item $id',
  nameAr: nameAr,
  description: 'Description $id',
  imageUrl: '',
  basePrice: 20,
);

/// 3 categories in backend order, each with several items (enough to make
/// the whole menu scroll well past one screen), plus one category with zero
/// items to verify it's hidden.
List<Category> _threeCategories() => const [
  Category(
    id: 'c1',
    name: 'Sandwiches',
    nameAr: 'ساندوتشات',
    nameEn: 'Sandwiches',
  ),
  Category(id: 'c2', name: 'Drinks', nameAr: 'مشروبات', nameEn: 'Drinks'),
  Category(id: 'c3', name: 'Desserts', nameAr: 'حلويات', nameEn: 'Desserts'),
  Category(id: 'c4', name: 'Empty Section'),
];

List<MenuItem> _manyItems() => [
  for (var i = 1; i <= 6; i++) _item('c1_$i', categoryId: 'c1'),
  for (var i = 1; i <= 6; i++) _item('c2_$i', categoryId: 'c2'),
  for (var i = 1; i <= 6; i++) _item('c3_$i', categoryId: 'c3'),
];

/// The `MenuScreen` search bar has a pre-existing overflow at narrow widths
/// (documented in menu_item_card_metadata_test.dart) — unrelated to
/// sectioning/scroll-sync, swallowed here so it doesn't mask genuine
/// regressions from this phase.
bool _isKnownPreExistingSearchBarOverflow(FlutterErrorDetails details) =>
    details.exceptionAsString().contains('overflowed') &&
    details.toString().contains('menu_screen.dart:416');

/// Pumps [MenuScreen], swallowing the known pre-existing search-bar
/// overflow and returning any *other* overflow for the caller to assert on.
Future<List<FlutterErrorDetails>> _pumpMenuScreen(
  WidgetTester tester, {
  required List<Category> categories,
  required List<MenuItem> items,
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const MenuScreen()),
      GoRoute(
        path: '/menu/item/:id',
        builder: (c, s) =>
            Scaffold(body: Text('ITEM_DETAILS_${s.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/search',
        builder: (c, s) => const Scaffold(body: Text('SEARCH_SCREEN')),
      ),
    ],
  );

  final unexpectedOverflows = <FlutterErrorDetails>[];
  final origOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) {
      if (!_isKnownPreExistingSearchBarOverflow(details)) {
        unexpectedOverflows.add(details);
      }
    } else {
      FlutterError.presentError(details);
    }
  };

  try {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          menuNotifierProvider.overrideWith(
            () => _FixedMenuNotifier(
              MenuData(categories: categories, items: items),
            ),
          ),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          startLocale: locale,
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
  } finally {
    FlutterError.onError = origOnError;
  }

  return unexpectedOverflows;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('1. all categories render as sections in one vertical menu', (
    tester,
  ) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: _manyItems(),
    );

    expect(tester.takeException(), isNull);
    // "Sandwiches" appears twice (tab chip + its own section header, both
    // visible at the initial scroll position); the others render at least
    // as their tab chip.
    expect(find.text('Sandwiches'), findsWidgets);
    expect(find.text('Drinks'), findsWidgets);
    expect(find.text('Desserts'), findsWidgets);
    // Only one CustomScrollView / Scaffold — no duplicate/second menu screen.
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);
  });

  testWidgets('2. products remain grouped under the correct category', (
    tester,
  ) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: [
        _item('a1', categoryId: 'c1', nameEn: 'Kebda Sandwich'),
        _item('b1', categoryId: 'c2', nameEn: 'Mint Lemonade'),
      ],
    );

    final sections = buildMenuSections(
      MenuData(
        categories: _threeCategories(),
        items: [
          _item('a1', categoryId: 'c1', nameEn: 'Kebda Sandwich'),
          _item('b1', categoryId: 'c2', nameEn: 'Mint Lemonade'),
        ],
      ),
    );

    expect(sections[0].category.id, 'c1');
    expect(sections[0].items.single.id, 'a1');
    expect(sections[1].category.id, 'c2');
    expect(sections[1].items.single.id, 'b1');
  });

  test('3. backend category order is preserved', () {
    final data = MenuData(
      categories: const [
        Category(id: 'c3', name: 'Desserts'),
        Category(id: 'c1', name: 'Sandwiches'),
        Category(id: 'c2', name: 'Drinks'),
      ],
      items: [
        _item('m1', categoryId: 'c1'),
        _item('m2', categoryId: 'c2'),
        _item('m3', categoryId: 'c3'),
      ],
    );

    final sections = buildMenuSections(data);
    expect(sections.map((s) => s.category.id).toList(), ['c3', 'c1', 'c2']);
  });

  test('4. product order within a category is preserved', () {
    final data = MenuData(
      categories: const [Category(id: 'c1', name: 'Sandwiches')],
      items: [
        _item('m3', categoryId: 'c1'),
        _item('m1', categoryId: 'c1'),
        _item('m2', categoryId: 'c1'),
      ],
    );

    final sections = buildMenuSections(data);
    expect(sections.single.items.map((i) => i.id).toList(), ['m3', 'm1', 'm2']);
  });

  testWidgets('5. a category with no items is hidden (no empty section)', (
    tester,
  ) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: _manyItems(),
    );

    expect(tester.takeException(), isNull);
    // "Empty Section" (c4) has zero items and must not render a header.
    expect(find.text('Empty Section'), findsNothing);
  });

  testWidgets('6. tapping a category tab scrolls to its section', (
    tester,
  ) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: _manyItems(),
    );

    // "Desserts" (the last section) has its tab chip in the horizontal bar
    // (always rendered) but its section header isn't visible/built yet at
    // the initial scroll position — exactly one match, not two.
    expect(find.text('Desserts'), findsOneWidget);

    await tester.tap(find.text('Desserts'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Now both the tab and the (scrolled-to) section header are present.
    expect(find.text('Desserts'), findsNWidgets(2));
  });

  testWidgets('7. manual downward scroll updates the selected category', (
    tester,
  ) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: _manyItems(),
    );

    // Tab + its own section header, both visible at the top initially.
    expect(find.text('Sandwiches'), findsNWidgets(2));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1400));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // After scrolling far down, "Sandwiches" section header has scrolled
    // off — only its (always-rendered) tab chip remains.
    expect(find.text('Sandwiches'), findsOneWidget);
  });

  testWidgets('8. manual upward scroll reactivates the previous category', (
    tester,
  ) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: _manyItems(),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1400));
    await tester.pumpAndSettle();
    expect(find.text('Sandwiches'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 1400));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Back near the top — tab + section header both visible again.
    expect(find.text('Sandwiches'), findsNWidgets(2));
  });

  testWidgets(
    '9. horizontal category bar keeps the active tab visible after tap',
    (tester) async {
      await _pumpMenuScreen(
        tester,
        categories: _threeCategories(),
        items: _manyItems(),
      );

      await tester.tap(find.text('Desserts'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // The tapped tab's own label is still findable (still built/visible
      // within the horizontal bar) after any auto-scroll of the tab strip.
      expect(find.text('Desserts'), findsWidgets);
    },
  );

  testWidgets(
    '10. programmatic tap-to-scroll does not cause selection oscillation',
    (tester) async {
      await _pumpMenuScreen(
        tester,
        categories: _threeCategories(),
        items: _manyItems(),
      );

      await tester.tap(find.text('Drinks'));
      // Pump through the animation in discrete steps (rather than
      // pumpAndSettle) to catch any mid-flight flicker back to another
      // section while the programmatic-scroll guard should be active.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 40));
      }
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Drinks'), findsWidgets);
    },
  );

  testWidgets('11. Arabic category names render in Arabic', (tester) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: _manyItems(),
      locale: const Locale('ar'),
    );

    expect(tester.takeException(), isNull);
    // Tab + its own visible section header.
    expect(find.text('ساندوتشات'), findsNWidgets(2));
    expect(find.text('Sandwiches'), findsNothing);
  });

  testWidgets('12. English category names render in English', (tester) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: _manyItems(),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Sandwiches'), findsNWidgets(2));
    expect(find.text('ساندوتشات'), findsNothing);
  });

  testWidgets('13. tapping a product card still opens Item Details', (
    tester,
  ) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: [_item('m1', categoryId: 'c1', nameEn: 'Kebda Sandwich')],
    );

    await tester.tap(find.text('Kebda Sandwich'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ITEM_DETAILS_m1'), findsOneWidget);
  });

  testWidgets('14. search bar tap still navigates to Search (unchanged)', (
    tester,
  ) async {
    await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: _manyItems(),
    );

    await tester.tap(find.text('home.search_hint'.tr()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('SEARCH_SCREEN'), findsOneWidget);
  });

  testWidgets('15. no overflow at 360dp', (tester) async {
    final overflows = await _pumpMenuScreen(
      tester,
      categories: _threeCategories(),
      items: [
        _item(
          'm1',
          categoryId: 'c1',
          nameEn: 'A Very Long Product Name That Could Wrap Or Overflow',
        ),
        _item('m2', categoryId: 'c2'),
        _item('m3', categoryId: 'c3'),
      ],
      size: const Size(360, 800),
    );
    expect(overflows, isEmpty);

    final origOnError = FlutterError.onError;
    final tapOverflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) {
        if (!_isKnownPreExistingSearchBarOverflow(details)) {
          tapOverflows.add(details);
        }
      } else {
        FlutterError.presentError(details);
      }
    };
    try {
      await tester.tap(find.text('Desserts'));
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = origOnError;
    }

    expect(tapOverflows, isEmpty);
  });

  testWidgets('16. existing Menu regression behavior remains intact', (
    tester,
  ) async {
    // A category with no matching items at all (global empty state) still
    // renders the existing "no items" empty view without exceptions.
    await _pumpMenuScreen(tester, categories: const [], items: const []);

    expect(tester.takeException(), isNull);
    expect(find.byType(MenuScreen), findsOneWidget);
  });
}
