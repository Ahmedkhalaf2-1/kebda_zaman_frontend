import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/api/token_refresh_coordinator.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/session_bootstrap_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';

User _testUser() =>
    User(id: 'u1', name: 'Ahmed', createdAt: DateTime(2026, 1, 1));

class _FakeAuthRepository implements AuthRepository {
  int getCurrentUserCallCount = 0;
  Result<User?> Function()? getCurrentUserOverride;

  @override
  Future<Result<User?>> getCurrentUser() async {
    getCurrentUserCallCount++;
    return getCurrentUserOverride?.call() ?? Success(_testUser());
  }

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();

  @override
  Future<Result<User>> login(String email, String password) async =>
      Success(_testUser());

  @override
  Future<Result<User>> adminLogin(String email, String password) async =>
      Success(_testUser());

  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async =>
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
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    callCount++;
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

Future<ResponseBody> Function(RequestOptions) _statusError(int statusCode) {
  return (options) async => ResponseBody.fromString(jsonEncode({}), statusCode);
}

Future<ResponseBody> Function(RequestOptions) _transportError(
  DioExceptionType type,
) {
  return (options) async =>
      throw DioException(requestOptions: options, type: type);
}

({
  ProviderContainer container,
  _ScriptedAdapter adapter,
  _FakeAuthRepository authRepo,
})
_buildContainer({
  bool hasSavedSession = true,
  List<Future<ResponseBody> Function(RequestOptions)> refreshScript = const [],
}) {
  SharedPreferences.setMockInitialValues({
    if (hasSavedSession) AuthNotifier.isLoggedInKey: true,
  });

  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  final adapter = _ScriptedAdapter(List.of(refreshScript));
  dio.httpClientAdapter = adapter;

  const secureStorage = FlutterSecureStorage();
  final tokenStorage = TokenStorage();
  final coordinator = TokenRefreshCoordinator(
    dio: dio,
    secureStorage: secureStorage,
    tokenStorage: tokenStorage,
  );

  final authRepo = _FakeAuthRepository();

  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(secureStorage),
      tokenRefreshCoordinatorProvider.overrideWithValue(coordinator),
      authRepositoryProvider.overrideWithValue(authRepo),
    ],
  );

  return (container: container, adapter: adapter, authRepo: authRepo);
}

Future<void> _seedRefreshToken(String? value) async {
  const secureStorage = FlutterSecureStorage();
  if (value != null) {
    await secureStorage.write(
      key: TokenRefreshCoordinator.refreshTokenKey,
      value: value,
    );
  }
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  group('SessionBootstrapNotifier', () {
    test(
      'cold start with valid refresh token: exactly one refresh call, resolves authenticated',
      () async {
        await _seedRefreshToken('stored-refresh-token');
        final built = _buildContainer(
          refreshScript: [
            _jsonSuccess({
              'accessToken': 'new-access-token',
              'refreshToken': 'rotated-refresh-token',
            }),
          ],
        );
        addTearDown(built.container.dispose);

        final status = await built.container.read(
          sessionBootstrapProvider.future,
        );

        expect(status, SessionBootstrapStatus.authenticated);
        expect(built.adapter.callCount, 1);
        expect(built.authRepo.getCurrentUserCallCount, 1);
      },
    );

    test(
      'cold start with no saved session: no refresh request, resolves unauthenticated',
      () async {
        final built = _buildContainer(
          hasSavedSession: false,
          refreshScript: [],
        );
        addTearDown(built.container.dispose);

        final status = await built.container.read(
          sessionBootstrapProvider.future,
        );

        expect(status, SessionBootstrapStatus.unauthenticated);
        expect(built.adapter.callCount, 0);
      },
    );

    test(
      'cold start with saved session but no refresh token: no refresh request, unauthenticated',
      () async {
        // hasSavedSession true, but never seed a refresh token in secure storage.
        final built = _buildContainer(refreshScript: []);
        addTearDown(built.container.dispose);

        final status = await built.container.read(
          sessionBootstrapProvider.future,
        );

        expect(status, SessionBootstrapStatus.unauthenticated);
        expect(built.adapter.callCount, 0);
      },
    );

    test(
      'refresh endpoint returns 401: resolves unauthenticated and clears local session',
      () async {
        await _seedRefreshToken('reused-refresh-token');
        final built = _buildContainer(refreshScript: [_statusError(401)]);
        addTearDown(built.container.dispose);

        final status = await built.container.read(
          sessionBootstrapProvider.future,
        );

        expect(status, SessionBootstrapStatus.unauthenticated);
        final authState = built.container.read(authNotifierProvider);
        expect(authState.isLoggedIn, isFalse);
      },
    );

    test(
      'refresh times out: resolves recoverableError, session is not destroyed',
      () async {
        await _seedRefreshToken('still-valid-refresh-token');
        final built = _buildContainer(
          refreshScript: [_transportError(DioExceptionType.connectionTimeout)],
        );
        addTearDown(built.container.dispose);

        final status = await built.container.read(
          sessionBootstrapProvider.future,
        );

        expect(status, SessionBootstrapStatus.recoverableError);
        const secureStorage = FlutterSecureStorage();
        expect(
          await secureStorage.read(
            key: TokenRefreshCoordinator.refreshTokenKey,
          ),
          'still-valid-refresh-token',
        );
      },
    );

    test(
      'retry() re-runs the bootstrap and can succeed after a prior recoverableError',
      () async {
        await _seedRefreshToken('still-valid-refresh-token');
        final built = _buildContainer(
          refreshScript: [
            _transportError(DioExceptionType.connectionTimeout),
            _jsonSuccess({
              'accessToken': 'new-access-token',
              'refreshToken': 'rotated-refresh-token',
            }),
          ],
        );
        addTearDown(built.container.dispose);

        final first = await built.container.read(
          sessionBootstrapProvider.future,
        );
        expect(first, SessionBootstrapStatus.recoverableError);

        await built.container.read(sessionBootstrapProvider.notifier).retry();
        final second = built.container.read(sessionBootstrapProvider).value;

        expect(second, SessionBootstrapStatus.authenticated);
        expect(built.adapter.callCount, 2);
      },
    );
  });
}
