import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';
import 'api_interceptors.dart';
import 'safe_log_interceptor.dart';
import 'token_refresh_coordinator.dart';

class ApiClient {
  late final Dio dio;

  /// Owns the single, app-wide refresh coordination. Shared with the
  /// session-bootstrap flow (see providers.dart's tokenRefreshCoordinatorProvider)
  /// so a cold-start refresh and a reactive 401 refresh can never race each
  /// other — there must only ever be one Dio instance and one coordinator.
  late final TokenRefreshCoordinator tokenRefreshCoordinator;

  ApiClient({
    required FlutterSecureStorage secureStorage,
    required TokenStorage tokenStorage,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    tokenRefreshCoordinator = TokenRefreshCoordinator(
      dio: dio,
      secureStorage: secureStorage,
      tokenStorage: tokenStorage,
    );

    dio.interceptors.add(SafeLogInterceptor());
    dio.interceptors.add(
      AuthInterceptor(dio, coordinator: tokenRefreshCoordinator),
    );
    dio.interceptors.add(RetryInterceptor(dio));
  }
}
