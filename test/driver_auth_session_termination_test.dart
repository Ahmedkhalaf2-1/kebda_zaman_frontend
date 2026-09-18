import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/providers/polling_notifier_mixin.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/driver/domain/models/driver_order.dart';
import 'package:kebda_zaman/features/driver/domain/repositories/driver_order_repository.dart';
import 'package:kebda_zaman/features/driver/presentation/notifiers/driver_orders_notifier.dart';
import 'package:kebda_zaman/features/shared/data/fake_auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';

class TestAuthRepository extends FakeAuthRepository {
  User? loginUser;

  @override
  Future<Result<User>> login(String email, String password) async =>
      Success(loginUser!);
}

/// A driver-order repository whose [getActiveOrders] result is scripted per
/// call, so tests can exercise exactly one failure type at a time without a
/// real backend.
class ScriptedDriverOrderRepository implements DriverOrderRepository {
  Result<List<DriverOrder>> Function() nextResult = () => const Success([]);

  @override
  Future<Result<List<DriverOrder>>> getActiveOrders({
    int page = 1,
    int limit = 20,
  }) async => nextResult();

  @override
  Future<Result<List<DriverOrder>>> getHistory({
    int page = 1,
    int limit = 20,
  }) async => const Success([]);

  @override
  Future<Result<DriverOrder>> getOrderById(String id) async =>
      throw UnimplementedError();

  @override
  Future<Result<DriverOrder>> pickup(String id) async =>
      throw UnimplementedError();

  @override
  Future<Result<DriverOrder>> delivered(String id) async =>
      throw UnimplementedError();

  @override
  Future<Result<LocationUploadAck>> uploadLocation(
    String orderId, {
    required double latitude,
    required double longitude,
    required DateTime capturedAt,
    required int assignmentVersion,
    double? accuracyMeters,
    double? headingDegrees,
    double? speedMps,
  }) async => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  Future<ProviderContainer> loginAsDriver(
    TestAuthRepository authRepo,
    ScriptedDriverOrderRepository driverRepo,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        driverOrderRepositoryProvider.overrideWithValue(driverRepo),
      ],
    );
    addTearDown(container.dispose);

    final driverUser = User(
      id: 'drv-A',
      name: 'Driver A',
      role: 'DRIVER',
      createdAt: DateTime.now(),
    );
    authRepo.loginUser = driverUser;
    await container
        .read(authNotifierProvider.notifier)
        .login(identifier: 'a@test.com', password: 'password');
    return container;
  }

  group('Driver session is only ended by a genuine AuthFailure', () {
    test(
      'a NetworkFailure on the active-orders fetch does NOT log the driver out',
      () async {
        final authRepo = TestAuthRepository();
        final driverRepo = ScriptedDriverOrderRepository();
        final container = await loginAsDriver(authRepo, driverRepo);

        driverRepo.nextResult = () =>
            const Err(NetworkFailure('Could not reach the server'));

        final sub = container.listen(driverActiveOrdersProvider, (_, __) {});
        addTearDown(sub.close);
        await container
            .read(driverActiveOrdersProvider.future)
            .catchError((_) => <DriverOrder>[]);

        expect(container.read(authNotifierProvider).isLoggedIn, isTrue);
      },
    );

    test(
      'a ValidationFailure (e.g. a 422/409 from an unrelated mutation) does NOT log the driver out',
      () async {
        final authRepo = TestAuthRepository();
        final driverRepo = ScriptedDriverOrderRepository();
        final container = await loginAsDriver(authRepo, driverRepo);

        driverRepo.nextResult = () =>
            const Err(ValidationFailure('Order already delivered'));

        final sub = container.listen(driverActiveOrdersProvider, (_, __) {});
        addTearDown(sub.close);
        await container
            .read(driverActiveOrdersProvider.future)
            .catchError((_) => <DriverOrder>[]);

        expect(container.read(authNotifierProvider).isLoggedIn, isTrue);
      },
    );

    test('a NotFoundFailure does NOT log the driver out', () async {
      final authRepo = TestAuthRepository();
      final driverRepo = ScriptedDriverOrderRepository();
      final container = await loginAsDriver(authRepo, driverRepo);

      driverRepo.nextResult = () =>
          const Err(NotFoundFailure('Order not found'));

      final sub = container.listen(driverActiveOrdersProvider, (_, __) {});
      addTearDown(sub.close);
      await container
          .read(driverActiveOrdersProvider.future)
          .catchError((_) => <DriverOrder>[]);

      expect(container.read(authNotifierProvider).isLoggedIn, isTrue);
    });

    test(
      'an AuthFailure (e.g. DRIVER_DEACTIVATED or a rejected refresh) DOES end the session',
      () async {
        final authRepo = TestAuthRepository();
        final driverRepo = ScriptedDriverOrderRepository();
        final container = await loginAsDriver(authRepo, driverRepo);

        driverRepo.nextResult = () =>
            const Err(AuthFailure('This driver account has been deactivated'));

        final sub = container.listen(driverActiveOrdersProvider, (_, __) {});
        addTearDown(sub.close);
        await container
            .read(driverActiveOrdersProvider.future)
            .catchError((_) => <DriverOrder>[]);

        expect(container.read(authNotifierProvider).isLoggedIn, isFalse);
      },
    );

    test(
      'a successful fetch after login never touches the session either way',
      () async {
        final authRepo = TestAuthRepository();
        final driverRepo = ScriptedDriverOrderRepository();
        final container = await loginAsDriver(authRepo, driverRepo);

        driverRepo.nextResult = () => const Success([]);

        final sub = container.listen(driverActiveOrdersProvider, (_, __) {});
        addTearDown(sub.close);
        await container.read(driverActiveOrdersProvider.future);

        expect(container.read(authNotifierProvider).isLoggedIn, isTrue);
      },
    );
  });

  group('Polling is cancelled when the provider is invalidated', () {
    test(
      'the active-orders poll timer stops once the notifier is disposed (e.g. via logout invalidation)',
      () async {
        final authRepo = TestAuthRepository();
        final driverRepo = ScriptedDriverOrderRepository();
        final container = await loginAsDriver(authRepo, driverRepo);

        final sub = container.listen(driverActiveOrdersProvider, (_, __) {});
        await container.read(driverActiveOrdersProvider.future);

        final notifier = container.read(driverActiveOrdersProvider.notifier);
        expect(
          (notifier as PollingNotifierMixin).hasActiveTimerForTesting,
          isTrue,
        );

        // Simulate what session_coordinator does on logout/account switch.
        sub.close();
        container.invalidate(driverActiveOrdersProvider);
        // Give the disposal callback (ref.onDispose) a chance to run.
        await Future<void>.delayed(Duration.zero);

        expect(notifier.hasActiveTimerForTesting, isFalse);
      },
    );
  });
}
