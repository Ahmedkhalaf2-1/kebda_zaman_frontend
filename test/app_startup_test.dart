import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/app.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/api/token_refresh_coordinator.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/failures.dart';
import 'package:kebda_zaman/core/errors/result.dart';
import 'package:kebda_zaman/core/session/session_coordinator.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';

User _testUser() => User(id: 'u1', name: 'Ahmed', createdAt: DateTime(2026, 1, 1));

class _FakeAuthRepository implements AuthRepository {
  int getCurrentUserCallCount = 0;
  
  @override
  Future<Result<User?>> getCurrentUser() async {
    getCurrentUserCallCount++;
    return Success(_testUser());
  }
  
  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<User>> login(String email, String password) async => Success(_testUser());

  @override
  Future<Result<User>> adminLogin(String email, String password) async => Success(_testUser());

  @override
  Future<Result<User>> register({required String name, required String email, required String phone, required String password}) async => Success(_testUser());

  @override
  Future<Result<User>> guestLogin() async => Success(_testUser());

  @override
  Future<Result<User>> updateProfile({String? name, String? phone, String? avatarUrl, String? locale, bool? pushEnabled}) async => Success(_testUser());

  @override
  Future<Result<void>> updatePassword(String oldPassword, String newPassword) async => const Success(null);

  @override
  Future<Result<void>> confirmRestoredSession() async => const Success(null);
}

class _FakeTokenRefreshCoordinator implements TokenRefreshCoordinator {
  int refreshCallCount = 0;
  RefreshOutcome refreshResult = const RefreshSuccess('new_token');
  
  @override
  Future<RefreshOutcome> refresh() async {
    refreshCallCount++;
    return refreshResult;
  }

  @override
  Dio get dio => throw UnimplementedError();

  @override
  FlutterSecureStorage get secureStorage => throw UnimplementedError();

  @override
  TokenStorage get tokenStorage => throw UnimplementedError();
}

void main() {
  setUpAll(() async {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      <String, String>{},
    );
    SharedPreferences.setMockInitialValues({});
    EasyLocalization.logger.enableLevels = [];
    await EasyLocalization.ensureInitialized();
  });

  Future<void> _pumpApp(
    WidgetTester tester, 
    ProviderContainer container,
    String initialLocation, {
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('initial_location', initialLocation);
    
    const secureStorage = FlutterSecureStorage();
    await secureStorage.deleteAll();
    if (refreshToken != null) {
      await secureStorage.write(
        key: TokenRefreshCoordinator.refreshTokenKey, 
        value: refreshToken
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: EasyLocalization(
          supportedLocales: const [Locale('en')],
          path: 'assets/mock',
          fallbackLocale: const Locale('en'),
          useOnlyLangCode: true,
          child: const KebdaZamanApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('App Startup Integration', () {
    testWidgets('direct startup on /home with saved session triggers exactly one refresh and calls getCurrentUser', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AuthNotifier.isLoggedInKey, true);
      
      final authRepo = _FakeAuthRepository();
      final refreshCoordinator = _FakeTokenRefreshCoordinator();
      
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          tokenRefreshCoordinatorProvider.overrideWithValue(refreshCoordinator),
        ],
      );

      await _pumpApp(tester, container, '/home', refreshToken: 'refresh_123');

      expect(refreshCoordinator.refreshCallCount, 1);
      expect(authRepo.getCurrentUserCallCount, 1);
      
      final authState = container.read(authNotifierProvider);
      expect(authState.isLoggedIn, isTrue);
      expect(authState.user, isNotNull);
    });

    testWidgets('no saved session does not call refresh', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      final authRepo = _FakeAuthRepository();
      final refreshCoordinator = _FakeTokenRefreshCoordinator();
      
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          tokenRefreshCoordinatorProvider.overrideWithValue(refreshCoordinator),
        ],
      );

      await _pumpApp(tester, container, '/home');

      expect(refreshCoordinator.refreshCallCount, 0);
      
      final authState = container.read(authNotifierProvider);
      expect(authState.isLoggedIn, isFalse);
    });

    testWidgets('transient refresh failure preserves saved credentials', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AuthNotifier.isLoggedInKey, true);
      
      final authRepo = _FakeAuthRepository();
      final refreshCoordinator = _FakeTokenRefreshCoordinator();
      refreshCoordinator.refreshResult = const RefreshTransientFailure('Network Error');
      
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          tokenRefreshCoordinatorProvider.overrideWithValue(refreshCoordinator),
        ],
      );

      await _pumpApp(tester, container, '/home', refreshToken: 'refresh_123');

      expect(refreshCoordinator.refreshCallCount, 1);
      
      expect(prefs.getBool(AuthNotifier.isLoggedInKey), isTrue);
      // We don't really have has_saved_session anymore, we use AuthNotifier.isLoggedInKey
      // But the test is checking that the session was NOT cleared.
    });
  });
}
