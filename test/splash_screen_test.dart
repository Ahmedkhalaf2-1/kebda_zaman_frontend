import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/api/token_refresh_coordinator.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/splash_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';

User _testUser() =>
    User(id: 'u1', name: 'Ahmed', createdAt: DateTime(2026, 1, 1));

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<User?>> getCurrentUser() async => Success(_testUser());
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<User>> login(String email, String password) async =>
      Success(_testUser());
  @override
  Future<Result<User>> adminLogin(String email, String password) async =>
      Success(_testUser());
  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async => Success(_testUser());
  @override
  Future<Result<User>> guestLogin() async => Success(_testUser());
  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async => Success(_testUser());
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);
  final List<Future<ResponseBody> Function(RequestOptions)> script;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (script.isEmpty) {
      throw StateError('No more scripted responses for ${options.path}');
    }
    return script.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

Future<ResponseBody> Function(RequestOptions) _jsonSuccess(
  Map<String, dynamic> data,
) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// Builds a minimal router (not the app's full router.dart) with just the
/// destinations SplashScreen can navigate to, each rendering an
/// identifiable placeholder — keeps this test focused on splash gating
/// without pulling in every real screen/provider.
GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language-select',
        builder: (context, state) =>
            const Scaffold(body: Text('language-select-placeholder')),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            const Scaffold(body: Text('onboarding-placeholder')),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const Scaffold(body: Text('home-placeholder')),
      ),
    ],
  );
}

Future<void> _pumpApp(
  WidgetTester tester,
  GoRouter router,
  List<Override> overrides,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
}

Future<List<Override>> _buildOverrides({String? storedRefreshToken}) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  final adapter = _ScriptedAdapter([
    if (storedRefreshToken != null)
      _jsonSuccess({
        'accessToken': 'new-access-token',
        'refreshToken': 'rotated-refresh-token',
      }),
  ]);
  dio.httpClientAdapter = adapter;

  const secureStorage = FlutterSecureStorage();
  if (storedRefreshToken != null) {
    await secureStorage.write(
      key: TokenRefreshCoordinator.refreshTokenKey,
      value: storedRefreshToken,
    );
  }
  final tokenStorage = TokenStorage();
  final coordinator = TokenRefreshCoordinator(
    dio: dio,
    secureStorage: secureStorage,
    tokenStorage: tokenStorage,
  );

  return [
    secureStorageProvider.overrideWithValue(secureStorage),
    tokenRefreshCoordinatorProvider.overrideWithValue(coordinator),
    authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
    // SplashScreen calls 'home.tagline'.tr(), which needs EasyLocalization's
    // controller initialized (normally done once in main.dart).
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'does not leave splash while bootstrap is still loading, even past the min duration',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'kz_lang_selected': true,
        'kz_onboarding_completed': true,
        AuthNotifier.isLoggedInKey: true,
      });

      // A refresh call that never resolves — bootstrap stays in AsyncLoading
      // indefinitely, simulating a slow/hanging network right at cold start.
      final hangingDio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      hangingDio.httpClientAdapter = _ScriptedAdapter([
        (options) => Completer<ResponseBody>().future,
      ]);
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(
        key: TokenRefreshCoordinator.refreshTokenKey,
        value: 'stored-refresh-token',
      );
      final coordinator = TokenRefreshCoordinator(
        dio: hangingDio,
        secureStorage: secureStorage,
        tokenStorage: TokenStorage(),
      );

      final router = _buildTestRouter();
      await _pumpApp(tester, router, [
        secureStorageProvider.overrideWithValue(secureStorage),
        tokenRefreshCoordinatorProvider.overrideWithValue(coordinator),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ]);

      // Advance well past the 2400ms minimum visual duration.
      await tester.pump(const Duration(milliseconds: 3000));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('home-placeholder'), findsNothing);
    },
  );

  testWidgets(
    'language not selected yet: navigates to language-select once ready',
    (tester) async {
      SharedPreferences.setMockInitialValues({'kz_lang_selected': false});

      final router = _buildTestRouter();
      await _pumpApp(tester, router, await _buildOverrides());

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(find.text('language-select-placeholder'), findsOneWidget);
    },
  );

  testWidgets(
    'language selected but onboarding not completed: navigates to onboarding once ready',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'kz_lang_selected': true,
        'kz_onboarding_completed': false,
      });

      final router = _buildTestRouter();
      await _pumpApp(tester, router, await _buildOverrides());

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(find.text('onboarding-placeholder'), findsOneWidget);
    },
  );

  testWidgets(
    'fully onboarded, no saved session: navigates to home once bootstrap resolves unauthenticated',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'kz_lang_selected': true,
        'kz_onboarding_completed': true,
      });

      final router = _buildTestRouter();
      await _pumpApp(
        tester,
        router,
        await _buildOverrides(),
      ); // no saved session -> no refresh call needed

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(find.text('home-placeholder'), findsOneWidget);
    },
  );

  testWidgets(
    'fully onboarded, valid saved session: navigates to home once bootstrap resolves authenticated',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'kz_lang_selected': true,
        'kz_onboarding_completed': true,
        AuthNotifier.isLoggedInKey: true,
      });

      final router = _buildTestRouter();
      await _pumpApp(
        tester,
        router,
        await _buildOverrides(storedRefreshToken: 'stored-refresh-token'),
      );

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(find.text('home-placeholder'), findsOneWidget);
    },
  );
}
