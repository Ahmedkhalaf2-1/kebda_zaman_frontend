import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/item_details_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/menu_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/item_details_screen.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/menu_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';
import 'package:kebda_zaman/generated/locale_keys.g.dart';

/// Focused tests for locale-aware product content: the [MenuItemLocalization]
/// extension's fallback logic in isolation, plus integration passes through
/// the real [MenuScreen] and [ItemDetailsScreen] to prove the active
/// customer surfaces actually switch between nameAr/nameEn and
/// descriptionAr/descriptionEn with the app locale, rather than always
/// showing English.
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
  String? nameAr,
  String? nameEn,
  String? descriptionAr,
  String? descriptionEn,
  double basePrice = 20,
  List<MenuItem> oftenOrderedWith = const [],
}) => MenuItem(
  id: id,
  categoryId: 'c1',
  name: nameEn ?? 'Fallback name $id',
  description: descriptionEn ?? 'Fallback description $id',
  imageUrl: '',
  basePrice: basePrice,
  nameAr: nameAr,
  nameEn: nameEn,
  descriptionAr: descriptionAr,
  descriptionEn: descriptionEn,
  oftenOrderedWith: oftenOrderedWith,
);

/// The `MenuScreen` search bar has a pre-existing overflow at narrow widths
/// unrelated to product-content localization (see
/// `menu_item_card_metadata_test.dart`) — swallowed here so it doesn't mask
/// genuine regressions from this phase.
bool _isKnownPreExistingSearchBarOverflow(FlutterErrorDetails details) =>
    details.exceptionAsString().contains('overflowed') &&
    details.toString().contains('menu_screen.dart:249');

Future<void> _pumpAndSettleSwallowingKnownOverflow(
  WidgetTester tester,
  Widget widget,
) async {
  final origOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) {
      if (!_isKnownPreExistingSearchBarOverflow(details)) {
        FlutterError.presentError(details);
      }
    } else {
      FlutterError.presentError(details);
    }
  };
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
  FlutterError.onError = origOnError;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('MenuItemLocalization.localizedName', () {
    test('Arabic locale prefers nameAr', () {
      final item = _item('m1', nameAr: 'خبز', nameEn: 'Bread');
      expect(item.localizedName('ar'), 'خبز');
    });

    test('non-Arabic locale prefers nameEn', () {
      final item = _item('m1', nameAr: 'خبز', nameEn: 'Bread');
      expect(item.localizedName('en'), 'Bread');
    });

    test('empty nameAr falls back to nameEn under Arabic locale', () {
      final item = _item('m1', nameAr: '', nameEn: 'Bread');
      expect(item.localizedName('ar'), 'Bread');
    });

    test('whitespace-only nameAr falls back to nameEn under Arabic locale', () {
      final item = _item('m1', nameAr: '   ', nameEn: 'Bread');
      expect(item.localizedName('ar'), 'Bread');
    });

    test('null nameEn falls back to nameAr under English locale', () {
      final item = _item('m1', nameAr: 'خبز', nameEn: null);
      expect(item.localizedName('en'), 'خبز');
    });

    test('empty nameEn falls back to nameAr under English locale', () {
      final item = _item('m1', nameAr: 'خبز', nameEn: '');
      expect(item.localizedName('en'), 'خبز');
    });

    test(
      'whitespace-only nameEn falls back to nameAr under English locale',
      () {
        final item = _item('m1', nameAr: 'خبز', nameEn: '  ');
        expect(item.localizedName('en'), 'خبز');
      },
    );

    test('both bilingual fields empty falls back to the base name safely', () {
      const item = MenuItem(
        id: 'm1',
        categoryId: 'c1',
        name: 'Base name',
        description: 'Base description',
        imageUrl: '',
        basePrice: 20,
        nameAr: '',
        nameEn: '',
      );
      expect(item.localizedName('ar'), 'Base name');
      expect(item.localizedName('en'), 'Base name');
    });
  });

  group('MenuItemLocalization.localizedDescription', () {
    test('Arabic locale prefers descriptionAr', () {
      final item = _item(
        'm1',
        descriptionAr: 'خبز طازج',
        descriptionEn: 'Fresh bread',
      );
      expect(item.localizedDescription('ar'), 'خبز طازج');
    });

    test('non-Arabic locale prefers descriptionEn', () {
      final item = _item(
        'm1',
        descriptionAr: 'خبز طازج',
        descriptionEn: 'Fresh bread',
      );
      expect(item.localizedDescription('en'), 'Fresh bread');
    });

    test('empty descriptionAr falls back to descriptionEn', () {
      final item = _item('m1', descriptionAr: '', descriptionEn: 'Fresh bread');
      expect(item.localizedDescription('ar'), 'Fresh bread');
    });

    test('whitespace-only descriptionEn falls back to descriptionAr', () {
      final item = _item('m1', descriptionAr: 'خبز طازج', descriptionEn: '  ');
      expect(item.localizedDescription('en'), 'خبز طازج');
    });
  });

  Widget wrapMenu({
    required List<MenuItem> items,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
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
    );
  }

  group('MenuScreen — locale-aware product content', () {
    testWidgets('renders nameEn/descriptionEn under English locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await _pumpAndSettleSwallowingKnownOverflow(
        tester,
        wrapMenu(
          items: [
            _item(
              'm1',
              nameAr: 'خبز',
              nameEn: 'Bread',
              descriptionAr: 'خبز طازج',
              descriptionEn: 'Fresh bread',
            ),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('Fresh bread'), findsOneWidget);
      expect(find.text('خبز'), findsNothing);
    });

    testWidgets('renders nameAr/descriptionAr under Arabic locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await _pumpAndSettleSwallowingKnownOverflow(
        tester,
        wrapMenu(
          items: [
            _item(
              'm1',
              nameAr: 'خبز',
              nameEn: 'Bread',
              descriptionAr: 'خبز طازج',
              descriptionEn: 'Fresh bread',
            ),
          ],
          locale: const Locale('ar'),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('خبز'), findsOneWidget);
      expect(find.text('خبز طازج'), findsOneWidget);
      expect(find.text('Bread'), findsNothing);
    });

    testWidgets(
      'switching locale at runtime updates already-rendered product content',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final origOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exceptionAsString().contains('overflowed')) {
            if (!_isKnownPreExistingSearchBarOverflow(details)) {
              FlutterError.presentError(details);
            }
          } else {
            FlutterError.presentError(details);
          }
        };

        await tester.pumpWidget(
          wrapMenu(
            items: [
              _item(
                'm1',
                nameAr: 'خبز',
                nameEn: 'Bread',
                descriptionAr: 'خبز طازج',
                descriptionEn: 'Fresh bread',
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Bread'), findsOneWidget);

        final context = tester.element(find.byType(MenuScreen));
        await context.setLocale(const Locale('ar'));
        await tester.pumpAndSettle();

        FlutterError.onError = origOnError;

        expect(tester.takeException(), isNull);
        expect(find.text('خبز'), findsOneWidget);
        expect(find.text('Bread'), findsNothing);
      },
    );

    testWidgets('long Arabic name/description do not overflow at 360dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        wrapMenu(
          items: [
            _item(
              'm1',
              nameAr: 'ساندويتش ميكس كبدة بانيه وإسكندراني مع صلصة خاصة',
              nameEn: 'Mix sandwich',
              descriptionAr:
                  'وصف طويل جدًا لصنف يحتوي على مكونات متعددة ونكهات غنية تستحق التجربة',
              descriptionEn: 'A long description',
            ),
          ],
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  Future<void> pumpItemDetails(
    WidgetTester tester, {
    required Map<String, MenuItem> items,
    required String initialId,
    Locale locale = const Locale('en'),
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
  }

  group('ItemDetailsScreen — locale-aware product content', () {
    testWidgets('title and description render in English', (tester) async {
      final item = _item(
        'm1',
        nameAr: 'حواوشي لحم',
        nameEn: 'Meat Hawawshi',
        descriptionAr: 'وصف بالعربي',
        descriptionEn: 'English description',
      );
      await pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

      expect(tester.takeException(), isNull);
      expect(find.text('Meat Hawawshi'), findsWidgets);
      expect(find.text('English description'), findsOneWidget);
    });

    testWidgets('title and description render in Arabic', (tester) async {
      final item = _item(
        'm1',
        nameAr: 'حواوشي لحم',
        nameEn: 'Meat Hawawshi',
        descriptionAr: 'وصف بالعربي',
        descriptionEn: 'English description',
      );
      await pumpItemDetails(
        tester,
        items: {'m1': item},
        initialId: 'm1',
        locale: const Locale('ar'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('حواوشي لحم'), findsWidgets);
      expect(find.text('وصف بالعربي'), findsOneWidget);
    });

    testWidgets(
      'Often Ordered With recommendation renders localized name in Arabic',
      (tester) async {
        final rec = _item('rec1', nameAr: 'بطاطس', nameEn: 'Fries');
        final item = _item('m1', nameEn: 'Burger', oftenOrderedWith: [rec]);
        await pumpItemDetails(
          tester,
          items: {'m1': item},
          initialId: 'm1',
          locale: const Locale('ar'),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('بطاطس'), findsOneWidget);
        expect(find.text('Fries'), findsNothing);
      },
    );

    testWidgets(
      'Often Ordered With recommendation still renders localized name in '
      'English locale',
      (tester) async {
        final rec = _item('rec1', nameAr: 'بطاطس', nameEn: 'Fries');
        final item = _item('m1', nameEn: 'Burger', oftenOrderedWith: [rec]);
        await pumpItemDetails(tester, items: {'m1': item}, initialId: 'm1');

        expect(tester.takeException(), isNull);
        expect(find.text('Fries'), findsOneWidget);
      },
    );

    testWidgets('correct Arabic "Often Ordered With" section title renders', (
      tester,
    ) async {
      final rec = _item('rec1', nameAr: 'بطاطس', nameEn: 'Fries');
      final item = _item('m1', nameEn: 'Burger', oftenOrderedWith: [rec]);
      await pumpItemDetails(
        tester,
        items: {'m1': item},
        initialId: 'm1',
        locale: const Locale('ar'),
      );

      expect(tester.takeException(), isNull);
      expect(
        LocaleKeys.product_details_often_ordered_with.tr(),
        'غالبًا يُطلب مع',
      );
      expect(find.text('غالبًا يُطلب مع'), findsOneWidget);
      // The malformed/reversed form must never appear.
      expect(find.text('مع يُطلب غالبًا'), findsNothing);
    });
  });
}

class _FixedMenuNotifier extends MenuNotifier {
  final MenuData data;
  _FixedMenuNotifier(this.data);

  @override
  Future<MenuData> build() async => data;
}
