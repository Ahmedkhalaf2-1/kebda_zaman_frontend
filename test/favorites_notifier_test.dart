import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/shared/data/api_favorites_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/favorites_repository.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);

  final List<Future<ResponseBody> Function(RequestOptions)> script;
  final List<RequestOptions> recordedRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    recordedRequests.add(options);
    if (script.isEmpty) {
      throw StateError('No more scripted responses for ${options.path}');
    }
    return script.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

Future<ResponseBody> Function(RequestOptions) _jsonSuccess(dynamic data) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _MockFavoritesRepository implements FavoritesRepository {
  List<MenuItem> items;
  bool failAdd;
  bool failRemove;
  int addCallCount = 0;
  int removeCallCount = 0;
  Completer<Result<List<MenuItem>>>? addCompleter;

  _MockFavoritesRepository({
    this.items = const [],
    this.failAdd = false,
    this.failRemove = false,
  });

  @override
  Future<Result<List<MenuItem>>> getFavorites() async => Success(items);

  @override
  Future<Result<List<MenuItem>>> addFavorite(String menuItemId) async {
    addCallCount++;
    if (addCompleter != null) {
      return addCompleter!.future;
    }
    if (failAdd) {
      return const Err(NetworkFailure('Simulated add error'));
    }
    final newItem = MenuItem(
      id: menuItemId,
      categoryId: 'cat-1',
      name: 'Item $menuItemId',
      description: 'Desc',
      imageUrl: '',
      basePrice: 50,
    );
    items = [...items, newItem];
    return Success(items);
  }

  @override
  Future<Result<void>> removeFavorite(String menuItemId) async {
    removeCallCount++;
    if (failRemove) {
      return const Err(NetworkFailure('Simulated remove error'));
    }
    items = items.where((i) => i.id != menuItemId).toList();
    return const Success(null);
  }
}

class _DummyAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(super.repo, {required bool loggedIn}) {
    if (loggedIn) {
      state = AuthState(
        user: User(id: 'u-1', name: 'User', email: 'test@test.com', createdAt: DateTime(2026)),
        isLoggedIn: true,
      );
    } else {
      state = const AuthState(isLoggedIn: false);
    }
  }
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform({});
  });

  group('ApiFavoritesRepository Behavior', () {
    test('addFavorite calls POST /me/favorites', () async {
      final adapter = _ScriptedAdapter([
        _jsonSuccess([
          {
            'id': 'item-1',
            'categoryId': 'cat-1',
            'name': 'Kebda',
            'description': 'Delicious',
            'imageUrl': '',
            'basePrice': 50.0,
          }
        ]),
      ]);

      final apiClient = ApiClient(
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage()..accessToken = 'test-token',
      );
      apiClient.dio.httpClientAdapter = adapter;

      final repo = ApiFavoritesRepository(apiClient);
      final result = await repo.addFavorite('item-1');

      expect(result.isSuccess, isTrue);
      expect(adapter.recordedRequests.length, 1);
      expect(adapter.recordedRequests.first.method, 'POST');
      expect(adapter.recordedRequests.first.path, '/me/favorites');
      expect(adapter.recordedRequests.first.data, {'menuItemId': 'item-1'});
    });

    test('removeFavorite calls DELETE /me/favorites/:id', () async {
      final adapter = _ScriptedAdapter([
        (options) async => ResponseBody.fromString('', 204),
      ]);

      final apiClient = ApiClient(
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage()..accessToken = 'test-token',
      );
      apiClient.dio.httpClientAdapter = adapter;

      final repo = ApiFavoritesRepository(apiClient);
      final result = await repo.removeFavorite('item-1');

      expect(result.isSuccess, isTrue);
      expect(adapter.recordedRequests.length, 1);
      expect(adapter.recordedRequests.first.method, 'DELETE');
      expect(adapter.recordedRequests.first.path, '/me/favorites/item-1');
    });
  });

  group('CustomerFavoritesNotifier Behavior', () {
    test('unauthenticated state blocks favorites API requests', () async {
      final mockRepo = _MockFavoritesRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_DummyAuthRepository()),
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
          authNotifierProvider.overrideWith((ref) => _FakeAuthNotifier(ref.read(authRepositoryProvider), loggedIn: false)),
        ],
      );

      final notifier = container.read(customerFavoritesProvider.notifier);
      await notifier.loadFavorites();

      final res = await notifier.toggleFavorite('item-1');

      expect(res, isFalse);
      expect(mockRepo.addCallCount, 0);
      expect(mockRepo.removeCallCount, 0);
    });

    test('rapid repeated taps for the same item do not trigger duplicate API calls', () async {
      final mockRepo = _MockFavoritesRepository();
      mockRepo.addCompleter = Completer<Result<List<MenuItem>>>();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_DummyAuthRepository()),
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
          authNotifierProvider.overrideWith((ref) => _FakeAuthNotifier(ref.read(authRepositoryProvider), loggedIn: true)),
        ],
      );

      final notifier = container.read(customerFavoritesProvider.notifier);
      await notifier.loadFavorites();

      // Trigger two concurrent toggles for the same item
      final future1 = notifier.toggleFavorite('item-1');
      final future2 = notifier.toggleFavorite('item-1');

      // Complete the first call after both are triggered
      mockRepo.addCompleter!.complete(const Success([]));

      final res1 = await future1;
      final res2 = await future2;

      expect(res1, isTrue);
      expect(res2, isFalse); // Second call blocked by mutation guard
      expect(mockRepo.addCallCount, 1);
    });

    test('failure on add restores the previous favorite state', () async {
      final mockRepo = _MockFavoritesRepository(failAdd: true);
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_DummyAuthRepository()),
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
          authNotifierProvider.overrideWith((ref) => _FakeAuthNotifier(ref.read(authRepositoryProvider), loggedIn: true)),
        ],
      );

      final notifier = container.read(customerFavoritesProvider.notifier);
      await notifier.loadFavorites();

      expect(container.read(customerFavoritesProvider).favoriteIds.contains('item-1'), isFalse);

      final res = await notifier.toggleFavorite('item-1');

      expect(res, isFalse);
      final state = container.read(customerFavoritesProvider);
      expect(state.favoriteIds.contains('item-1'), isFalse); // Restored
      expect(state.errorMessage, equals('Simulated add error'));
    });

    test('failure on remove restores the previous favorite state', () async {
      final initialItem = MenuItem(
        id: 'item-1',
        categoryId: 'cat-1',
        name: 'Kebda',
        description: 'Desc',
        imageUrl: '',
        basePrice: 50,
      );
      final mockRepo = _MockFavoritesRepository(items: [initialItem], failRemove: true);
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_DummyAuthRepository()),
          favoritesRepositoryProvider.overrideWithValue(mockRepo),
          authNotifierProvider.overrideWith((ref) => _FakeAuthNotifier(ref.read(authRepositoryProvider), loggedIn: true)),
        ],
      );

      final notifier = container.read(customerFavoritesProvider.notifier);
      await notifier.loadFavorites();

      expect(container.read(customerFavoritesProvider).favoriteIds.contains('item-1'), isTrue);

      final res = await notifier.toggleFavorite('item-1');

      expect(res, isFalse);
      final state = container.read(customerFavoritesProvider);
      expect(state.favoriteIds.contains('item-1'), isTrue); // Restored
      expect(state.errorMessage, equals('Simulated remove error'));
    });
  });
}
