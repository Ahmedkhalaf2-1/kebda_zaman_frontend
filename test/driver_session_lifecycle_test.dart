import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/providers/polling_notifier_mixin.dart';
import 'package:kebda_zaman/core/session/session_coordinator.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
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

class TestDriverOrderRepository implements DriverOrderRepository {
  int getActiveOrdersCalls = 0;

  @override
  Future<Result<List<DriverOrder>>> getActiveOrders({
    int page = 1,
    int limit = 20,
  }) async {
    getActiveOrdersCalls++;
    return const Success([]);
  }

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

  group('Driver session lifecycle', () {
    test(
      'logging out a DRIVER session invalidates driverActiveOrdersProvider, '
      'stops its poll timer, and a fresh reader gets a genuine re-fetch',
      () async {
        final testAuthRepo = TestAuthRepository();
        final mockDriverOrderRepo = TestDriverOrderRepository();

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(testAuthRepo),
            driverOrderRepositoryProvider.overrideWithValue(
              mockDriverOrderRepo,
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(sessionLifecycleProvider);

        final driverUser = User(
          id: 'drv-A',
          name: 'Driver A',
          email: 'drivera@test.com',
          role: 'DRIVER',
          createdAt: DateTime.now(),
        );
        testAuthRepo.loginUser = driverUser;

        // At this point driverActiveOrdersProvider has never been read, so
        // session_coordinator's post-login invalidate is a guarded no-op
        // (see `_clearDriverScopedState`'s `Ref.exists` check) — exactly
        // matching real usage, where the driver screen never mounts before
        // login resolves.
        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'drivera@test.com', password: 'password');

        // `container.read(...future)` alone both builds the provider and
        // keeps it alive for the container's lifetime — same precedent as
        // `admin_polling_notifiers_test.dart`'s "timer starts on build and
        // stops on dispose" test. No wall-clock wait: the count is exact
        // because nothing else can race a build here anymore.
        await container.read(driverActiveOrdersProvider.future);
        expect(mockDriverOrderRepo.getActiveOrdersCalls, 1);

        final notifier = container.read(driverActiveOrdersProvider.notifier);
        expect(
          (notifier as PollingNotifierMixin).hasActiveTimerForTesting,
          isTrue,
        );

        await container.read(authNotifierProvider.notifier).logout();

        // The old notifier is torn down synchronously as part of the
        // invalidate — its timer is cancelled immediately (`ref.onDispose`
        // runs during teardown, not on a later tick), independent of
        // whether the replacement build has finished yet.
        expect(notifier.hasActiveTimerForTesting, isFalse);

        // A fresh, real re-fetch happened for the new (torn-down) session —
        // never a stale cached value silently kept — and the *new*
        // notifier instance has its own timer running again.
        await container.read(driverActiveOrdersProvider.future);
        expect(mockDriverOrderRepo.getActiveOrdersCalls, 2);
        expect(
          container.read(driverActiveOrdersProvider).valueOrNull,
          isNot(isNull),
        );
        expect(
          (container.read(driverActiveOrdersProvider.notifier)
                  as PollingNotifierMixin)
              .hasActiveTimerForTesting,
          isTrue,
        );
      },
    );

    test(
      'switching from one DRIVER account to another invalidates the previous account\'s cached orders',
      () async {
        final testAuthRepo = TestAuthRepository();
        final mockDriverOrderRepo = TestDriverOrderRepository();

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(testAuthRepo),
            driverOrderRepositoryProvider.overrideWithValue(
              mockDriverOrderRepo,
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(sessionLifecycleProvider);

        final driverA = User(
          id: 'drv-A',
          name: 'Driver A',
          role: 'DRIVER',
          createdAt: DateTime.now(),
        );
        final driverB = User(
          id: 'drv-B',
          name: 'Driver B',
          role: 'DRIVER',
          createdAt: DateTime.now(),
        );

        testAuthRepo.loginUser = driverA;
        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'a@test.com', password: 'password');

        await container.read(driverActiveOrdersProvider.future);
        expect(mockDriverOrderRepo.getActiveOrdersCalls, 1);

        testAuthRepo.loginUser = driverB;
        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'b@test.com', password: 'password');

        // A fresh fetch for Driver B's own session — the provider was
        // invalidated (and its predecessor's timer cancelled) on the
        // account switch rather than silently keeping Driver A's
        // last-fetched list. Exact count: no wall-clock wait needed now
        // that invalidating a never-built provider can't race a build.
        await container.read(driverActiveOrdersProvider.future);
        expect(mockDriverOrderRepo.getActiveOrdersCalls, 2);
      },
    );
  });
}
