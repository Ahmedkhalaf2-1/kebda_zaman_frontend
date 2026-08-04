import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/menu_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/menu_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Focused tests for VO3 catalog metadata (badge, calories, compareAtPrice,
/// null-image fallback) on the customer-facing menu item cards. Covers the
/// shared [MenuItemBadgeChip]/[MenuItemComparePriceText]/[MenuItemCaloriesText]
/// widgets directly, plus an integration pass through the real [MenuScreen]
/// (the active surface these widgets are wired into) to prove the shared
/// card actually renders them.
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

MenuItem _item(
  String id, {
  String? name,
  String? description,
  String imageUrl = '',
  double basePrice = 55.5,
  double? compareAtPrice,
  int? calories,
  MenuItemBadge? badge,
  bool isFeatured = false,
  bool isBestSeller = false,
}) => MenuItem(
  id: id,
  categoryId: 'c1',
  name: name ?? 'Kebda Sandwich $id',
  description: description ?? 'Tender liver with herbs and peppers.',
  imageUrl: imageUrl,
  basePrice: basePrice,
  compareAtPrice: compareAtPrice,
  calories: calories,
  badge: badge,
  isFeatured: isFeatured,
  isBestSeller: isBestSeller,
);

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return ProviderScope(
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
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(body: child),
          );
        },
      ),
    ),
  );
}

/// The `MenuScreen` search bar (a plain `Row` in `_StickyMenuHeaderDelegate`,
/// at `menu_screen.dart:416`) has a pre-existing overflow at narrow widths
/// once `home.search_hint` is fully resolved — unrelated to the item-card
/// metadata this phase adds, and out of scope to fix here (see project VO3
/// UI rules: touch only the active menu-card surfaces). We isolate it so
/// card-specific overflow regressions aren't masked by it. (Line number has
/// shifted twice — 249 originally, then 412, now 416 — as the screen was
/// refactored/reformatted; same underlying pre-existing bug, unmoved.)
bool _isKnownPreExistingSearchBarOverflow(FlutterErrorDetails details) =>
    details.exceptionAsString().contains('overflowed') &&
    details.toString().contains('menu_screen.dart:416');

/// Pumps [MenuScreen], capturing any overflow errors. Overflow errors from
/// the pre-existing, out-of-scope search-bar bug are swallowed; anything
/// else (including overflow from the item card) is returned for the caller
/// to assert on.
Future<List<FlutterErrorDetails>> _pumpMenuScreen(
  WidgetTester tester,
  List<MenuItem> items, {
  Locale locale = const Locale('en'),
}) async {
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

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        menuNotifierProvider.overrideWith(
          () => _FixedMenuNotifier(
            MenuData(
              categories: const [Category(id: 'c1', name: 'Sandwiches')],
              items: items,
            ),
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
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: const MenuScreen(),
            );
          },
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();

  FlutterError.onError = origOnError;
  return unexpectedOverflows;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> setViewport(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('MenuItemBadgeChip', () {
    testWidgets('renders localized Bestseller label', (tester) async {
      await tester.pumpWidget(
        _wrap(const MenuItemBadgeChip(badge: MenuItemBadge.bestseller)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bestseller'), findsOneWidget);
    });

    testWidgets('renders localized Top Rated label', (tester) async {
      await tester.pumpWidget(
        _wrap(const MenuItemBadgeChip(badge: MenuItemBadge.topRated)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Top Rated'), findsOneWidget);
    });

    testWidgets('renders Arabic bestseller label under Arabic locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const MenuItemBadgeChip(badge: MenuItemBadge.bestseller),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('الأكثر مبيعًا'), findsOneWidget);
    });
  });

  group('MenuItemComparePriceText', () {
    testWidgets('renders SAR-formatted, struck-through price', (tester) async {
      await tester.pumpWidget(
        _wrap(const MenuItemComparePriceText(compareAtPrice: 170)),
      );
      await tester.pumpAndSettle();
      final textWidget = tester.widget<Text>(find.text('SAR 170'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });
  });

  group('MenuItemCaloriesText', () {
    testWidgets('renders "{count} kcal" in English', (tester) async {
      await tester.pumpWidget(_wrap(const MenuItemCaloriesText(calories: 500)));
      await tester.pumpAndSettle();
      expect(find.text('500 kcal'), findsOneWidget);
    });

    testWidgets('renders Arabic calorie label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MenuItemCaloriesText(calories: 172),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('172'), findsOneWidget);
      expect(find.textContaining('سعرة حرارية'), findsOneWidget);
    });
  });

  group('MenuScreen — VO3 metadata integration', () {
    testWidgets('BESTSELLER item renders localized badge on the card', (
      tester,
    ) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', badge: MenuItemBadge.bestseller),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.text('Bestseller'), findsOneWidget);
    });

    testWidgets('TOP_RATED item renders localized badge on the card', (
      tester,
    ) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', badge: MenuItemBadge.topRated),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.text('Top Rated'), findsOneWidget);
    });

    testWidgets('null badge renders no VO3 badge chip', (tester) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [_item('m1')]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.byType(MenuItemBadgeChip), findsNothing);
    });

    testWidgets(
      'isFeatured/isBestSeller true with null badge does not render a VO3 badge',
      (tester) async {
        await setViewport(tester, const Size(390, 844));
        final overflows = await _pumpMenuScreen(tester, [
          _item('m1', isFeatured: true, isBestSeller: true),
        ]);
        expect(tester.takeException(), isNull);
        expect(overflows, isEmpty);
        expect(find.byType(MenuItemBadgeChip), findsNothing);
      },
    );

    testWidgets('basePrice always renders', (tester) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', basePrice: 136),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.text('SAR 136'), findsOneWidget);
    });

    testWidgets('valid compareAtPrice renders crossed out', (tester) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', basePrice: 136, compareAtPrice: 170),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.byType(MenuItemComparePriceText), findsOneWidget);
      expect(find.text('SAR 170'), findsOneWidget);
    });

    testWidgets('null compareAtPrice renders no compare price text', (
      tester,
    ) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', basePrice: 136),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.byType(MenuItemComparePriceText), findsNothing);
    });

    testWidgets('compareAtPrice <= basePrice is defensively absent', (
      tester,
    ) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', basePrice: 136, compareAtPrice: 136),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.byType(MenuItemComparePriceText), findsNothing);
    });

    testWidgets('calories render when present', (tester) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', calories: 500),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.text('500 kcal'), findsOneWidget);
    });

    testWidgets('calories are absent when null', (tester) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [_item('m1')]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.byType(MenuItemCaloriesText), findsNothing);
    });

    testWidgets('Arabic name renders under Arabic locale', (tester) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', name: 'ساندويتش كبدة'),
      ], locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.text('ساندويتش كبدة'), findsOneWidget);
    });

    testWidgets('English name renders under English locale', (tester) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [
        _item('m1', name: 'Liver Sandwich'),
      ], locale: const Locale('en'));
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      expect(find.text('Liver Sandwich'), findsOneWidget);
    });

    testWidgets('long Arabic name does not overflow at 360dp', (tester) async {
      await setViewport(tester, const Size(360, 800));
      final overflows = await _pumpMenuScreen(tester, [
        _item(
          'm1',
          name: 'ساندويتش ميكس كبدة بانيه وإسكندراني',
          calories: 640,
          badge: MenuItemBadge.bestseller,
          compareAtPrice: 60,
          basePrice: 45,
        ),
      ], locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
    });

    testWidgets('long English name does not overflow at 360dp', (tester) async {
      await setViewport(tester, const Size(360, 800));
      final overflows = await _pumpMenuScreen(tester, [
        _item(
          'm1',
          name: 'Mix Fishah With Tuhal And Askindirani Plate',
          calories: 640,
          badge: MenuItemBadge.topRated,
          compareAtPrice: 60,
          basePrice: 45,
        ),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
    });

    testWidgets('discounted high-price item does not overflow at 360dp', (
      tester,
    ) async {
      await setViewport(tester, const Size(360, 800));
      final overflows = await _pumpMenuScreen(tester, [
        _item(
          'm1',
          basePrice: 136,
          compareAtPrice: 170,
          calories: 900,
          badge: MenuItemBadge.bestseller,
        ),
      ]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
    });

    testWidgets('card remains tappable (shared KZCard present with onTap)', (
      tester,
    ) async {
      await setViewport(tester, const Size(390, 844));
      final overflows = await _pumpMenuScreen(tester, [_item('m1')]);
      expect(tester.takeException(), isNull);
      expect(overflows, isEmpty);
      final cardFinder = find.byType(KZCard);
      expect(cardFinder, findsWidgets);
      final card = tester.widget<KZCard>(cardFinder.first);
      expect(card.onTap, isNotNull);
    });

    testWidgets(
      'existing variant/modifier behavior is unchanged by new metadata',
      (tester) async {
        await setViewport(tester, const Size(390, 844));
        final overflows = await _pumpMenuScreen(tester, [
          _item(
            'm1',
            badge: MenuItemBadge.bestseller,
            calories: 500,
            compareAtPrice: 60,
            basePrice: 45,
          ),
        ]);
        expect(tester.takeException(), isNull);
        expect(overflows, isEmpty);
        // Modifier groups default to empty for these fixtures — the "Add"
        // button remains the direct add-to-cart affordance rather than
        // routing through item details, exactly as before VO3 metadata was
        // added.
        expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      },
    );
  });
}

class _FixedMenuNotifier extends MenuNotifier {
  final MenuData data;
  _FixedMenuNotifier(this.data);

  @override
  Future<MenuData> build() async => data;
}
