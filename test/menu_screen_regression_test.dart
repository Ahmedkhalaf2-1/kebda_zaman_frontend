import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
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

MenuItem _item(String id, {double? discountPrice, String? longDesc}) =>
    MenuItem(
      id: id,
      categoryId: 'c1',
      name: 'Kebda Sandwich $id — Extra Long Name To Test Wrapping',
      description:
          longDesc ??
          'Tender liver with herbs, peppers, garlic and our signature '
              'special seasoning blend, grilled fresh to order.',
      imageUrl: '',
      basePrice: 55.5,
      discountPrice: discountPrice,
    );

Future<void> _pump(WidgetTester tester, List<Override> overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        assetLoader: const CodegenLoader(),
        child: const MaterialApp(home: MenuScreen()),
      ),
    ),
  );
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

  final baseOverrides = [
    authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
  ];

  for (final entry in {
    'mobile (375x812)': const Size(375, 812),
    'tablet (800x1024)': const Size(800, 1024),
    'desktop (1440x900)': const Size(1440, 900),
  }.entries) {
    testWidgets(
      'renders without exceptions on ${entry.key} — populated menu, with '
      'discounts and long text',
      (tester) async {
        await setViewport(tester, entry.value);

        final overrides = [
          ...baseOverrides,
          menuNotifierProvider.overrideWith(
            () => _FixedMenuNotifier(
              MenuData(
                categories: const [
                  Category(id: 'c1', name: 'Sandwiches'),
                  Category(id: 'c2', name: 'Drinks'),
                  Category(id: 'c3', name: 'Extras'),
                ],
                items: [
                  _item('m1', discountPrice: 40),
                  _item('m2'),
                  _item('m3', longDesc: 'x'),
                  _item('m4', discountPrice: 12.5),
                  _item('m5'),
                ],
              ),
            ),
          ),
        ];

        await _pump(tester, overrides);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(MenuScreen), findsOneWidget);
      },
    );
  }

  testWidgets('renders without exceptions: empty menu (no items)', (
    tester,
  ) async {
    await setViewport(tester, const Size(375, 812));

    final overrides = [
      ...baseOverrides,
      menuNotifierProvider.overrideWith(
        () =>
            _FixedMenuNotifier(MenuData(categories: const [], items: const [])),
      ),
    ];

    await _pump(tester, overrides);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without exceptions: menuNotifierProvider errors', (
    tester,
  ) async {
    await setViewport(tester, const Size(375, 812));

    final overrides = [
      ...baseOverrides,
      menuNotifierProvider.overrideWith(() => _FailingMenuNotifier()),
    ];

    await _pump(tester, overrides);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dismissing the weekly-special strip removes it without exceptions',
    (tester) async {
      await setViewport(tester, const Size(375, 812));

      final overrides = [
        ...baseOverrides,
        menuNotifierProvider.overrideWith(
          () => _FixedMenuNotifier(
            MenuData(
              categories: const [Category(id: 'c1', name: 'Sandwiches')],
              items: [_item('m1')],
            ),
          ),
        ),
      ];

      await _pump(tester, overrides);
      await tester.pumpAndSettle();

      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    },
  );
}

class _FixedMenuNotifier extends MenuNotifier {
  final MenuData data;
  _FixedMenuNotifier(this.data);

  @override
  Future<MenuData> build() async => data;
}

class _FailingMenuNotifier extends MenuNotifier {
  @override
  Future<MenuData> build() async => throw Exception('simulated API failure');
}
