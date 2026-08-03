import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/item_details_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/item_details_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Focused tests for the VO3 Product Details experience: top-section
/// metadata (badge/calories/compareAtPrice), the existing variant selector
/// still defaulting/pricing correctly, and the new "Often Ordered With"
/// recommendations section (visibility, tap-to-navigate, per-recommendation
/// metadata, and no runaway recursion).
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

ModifierGroup _variantGroup() => const ModifierGroup(
  id: 'g-size',
  name: 'Size',
  isRequired: true,
  selectionType: 'SINGLE',
  minSelections: 1,
  maxSelections: 1,
  options: [
    ModifierOption(
      id: 'small',
      name: 'Small',
      priceModifier: 0,
      isDefault: true,
    ),
    ModifierOption(
      id: 'large',
      name: 'Large',
      priceModifier: 7,
      isDefault: false,
    ),
  ],
);

MenuItem _item(
  String id, {
  String? name,
  double basePrice = 20,
  double? compareAtPrice,
  int? calories,
  MenuItemBadge? badge,
  String imageUrl = '',
  List<ModifierGroup> modifierGroups = const [],
  List<MenuItem> oftenOrderedWith = const [],
}) => MenuItem(
  id: id,
  categoryId: 'c1',
  name: name ?? 'Item $id',
  description: 'Description for $id',
  imageUrl: imageUrl,
  basePrice: basePrice,
  compareAtPrice: compareAtPrice,
  calories: calories,
  badge: badge,
  modifierGroups: modifierGroups,
  oftenOrderedWith: oftenOrderedWith,
);

Future<void> _pumpItemDetails(
  WidgetTester tester, {
  required Map<String, MenuItem> items,
  required String initialId,
}) async {
  final overrides = <Override>[
    authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
    for (final entry in items.entries)
      itemDetailsProvider(entry.key).overrideWith((ref) async => entry.value),
  ];

  final router = GoRouter(
    initialLocation: '/menu/item/$initialId',
    routes: [
      GoRoute(
        path: '/menu/item/:id',
        builder: (context, state) =>
            ItemDetailsScreen(itemId: state.pathParameters['id']!),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('top-section metadata', () {
    testWidgets('badge renders when present', (tester) async {
      final item = _item('m1', badge: MenuItemBadge.bestseller);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.byType(MenuItemBadgeChip), findsOneWidget);
      expect(find.text('Bestseller'), findsOneWidget);
    });

    testWidgets('badge absent when null', (tester) async {
      final item = _item('m1');
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.byType(MenuItemBadgeChip), findsNothing);
    });

    testWidgets('calories render when present', (tester) async {
      final item = _item('m1', calories: 500);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.text('500 kcal'), findsOneWidget);
    });

    testWidgets('calories absent when null', (tester) async {
      final item = _item('m1');
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.byType(MenuItemCaloriesText), findsNothing);
    });

    testWidgets('compareAtPrice renders crossed out when > basePrice', (
      tester,
    ) async {
      final item = _item('m1', basePrice: 20, compareAtPrice: 25);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.byType(MenuItemComparePriceText), findsOneWidget);
      expect(find.text('SAR 25'), findsOneWidget);
    });

    testWidgets('compareAtPrice absent when null', (tester) async {
      final item = _item('m1', basePrice: 20);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.byType(MenuItemComparePriceText), findsNothing);
    });

    testWidgets('compareAtPrice absent when <= basePrice', (tester) async {
      final item = _item('m1', basePrice: 20, compareAtPrice: 20);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.byType(MenuItemComparePriceText), findsNothing);
    });

    testWidgets('current price (basePrice) always renders', (tester) async {
      final item = _item('m1', basePrice: 20);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.text('SAR 20'), findsOneWidget);
    });
  });

  group('variant selector', () {
    testWidgets(
      'default variant selected on load and footer total reflects it',
      (tester) async {
        final item = _item(
          'm1',
          basePrice: 20,
          modifierGroups: [_variantGroup()],
        );
        await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

        expect(tester.takeException(), isNull);
        // Default option ("Small", priceModifier 0) selected -> footer total
        // is just basePrice, rendered as a bare "20" (no currency prefix).
        expect(find.text('20'), findsOneWidget);
      },
    );

    testWidgets('selecting a variant updates the footer total instantly', (
      tester,
    ) async {
      final item = _item(
        'm1',
        basePrice: 20,
        modifierGroups: [_variantGroup()],
      );
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      await tester.ensureVisible(find.text('Large'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('27'), findsOneWidget);
      expect(find.text('20'), findsNothing);
    });
  });

  group('Often Ordered With', () {
    testWidgets('section hidden when oftenOrderedWith is empty', (
      tester,
    ) async {
      final item = _item('m1');
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.text('OFTEN ORDERED WITH'), findsNothing);
    });

    testWidgets('section shown with recommendation cards when present', (
      tester,
    ) async {
      final rec = _item(
        'rec1',
        name: 'Fries',
        basePrice: 12,
        calories: 300,
        badge: MenuItemBadge.topRated,
      );
      final item = _item('m1', oftenOrderedWith: [rec]);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.text('OFTEN ORDERED WITH'), findsOneWidget);
      expect(find.text('Fries'), findsOneWidget);
      expect(find.text('SAR 12'), findsOneWidget);
      expect(find.text('300 kcal'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);
    });

    testWidgets('recommendation without an image uses the KZFoodImage '
        'placeholder without throwing', (tester) async {
      final rec = _item('rec1', name: 'Fries', imageUrl: '');
      final item = _item('m1', oftenOrderedWith: [rec]);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.text('Fries'), findsOneWidget);
    });

    testWidgets('recommendation without a badge renders no badge chip on '
        'its card', (tester) async {
      final rec = _item('rec1', name: 'Fries');
      final item = _item('m1', oftenOrderedWith: [rec]);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.byType(MenuItemBadgeChip), findsNothing);
    });

    testWidgets('recommendation without calories renders no calories text '
        'on its card', (tester) async {
      final rec = _item('rec1', name: 'Fries', calories: null);
      final item = _item('m1', oftenOrderedWith: [rec]);
      await _pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.byType(MenuItemCaloriesText), findsNothing);
    });

    testWidgets('tapping a recommendation opens Product Details for that '
        'item via the existing route (no duplicate screen)', (tester) async {
      final rec = _item('rec1', name: 'Fries', basePrice: 12);
      final item = _item('m1', name: 'Burger', oftenOrderedWith: [rec]);
      await _pumpItemDetails(
        tester,
        items: {'m1': item, 'rec1': rec},
        initialId: 'm1',
      );

      // "Burger" legitimately renders twice pre-navigation: the header
      // title and the empty-imageUrl hero fallback (both show item.name).
      expect(find.text('Burger'), findsWidgets);

      await tester.ensureVisible(find.text('Fries'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fries'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Navigated to a single ItemDetailsScreen instance now showing the
      // recommendation's own details — not a second/duplicate screen type.
      expect(find.byType(ItemDetailsScreen), findsOneWidget);
      expect(find.text('Burger'), findsNothing);
    });

    testWidgets('a circular oftenOrderedWith reference does not cause runaway '
        'recursion — only one level of recommendations ever renders', (
      tester,
    ) async {
      // A -> [B], B -> [A]: if the recommendation card ever tried to
      // render its own oftenOrderedWith, this would recurse forever.
      final itemA = _item(
        'a',
        name: 'Item A',
        oftenOrderedWith: [_item('b', name: 'Item B')],
      );
      final itemB = _item(
        'b',
        name: 'Item B',
        oftenOrderedWith: [_item('a', name: 'Item A')],
      );

      await _pumpItemDetails(
        tester,
        items: {'a': itemA, 'b': itemB},
        initialId: 'a',
      );

      expect(tester.takeException(), isNull);
      // Exactly one "Often Ordered With" section/list, one recommendation
      // card ("Item B") — no nested second list inside it.
      expect(find.text('OFTEN ORDERED WITH'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
    });
  });
}
