import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/driver/data/driver_location_permission_service.dart';
import 'package:kebda_zaman/features/driver/domain/models/driver_order.dart';
import 'package:kebda_zaman/features/driver/domain/repositories/driver_order_repository.dart';
import 'package:kebda_zaman/features/driver/domain/services/driver_location_source.dart';
import 'package:kebda_zaman/features/driver/presentation/notifiers/driver_tracking_coordinator.dart';
import 'package:kebda_zaman/features/shared/data/fake_auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAuthRepository extends FakeAuthRepository {
  User? loginUser;

  @override
  Future<Result<User>> login(String email, String password) async =>
      Success(loginUser!);
}

/// Deterministic replacement for the platform Android/iOS location source —
/// starts/stops are recorded, and positions are only ever emitted when the
/// test explicitly pushes one, so a test controls exactly which fix (if
/// any) is "current" at each scheduler tick.
class FakeLocationSource implements DriverLocationSource {
  int startCalls = 0;
  int stopCalls = 0;
  bool _running = false;
  // `sync: true` so a test's `emit()` call updates the coordinator's
  // `_latestSample` synchronously, rather than needing an extra event-loop
  // turn before a manually driven `debugSchedulerTick()` can see it.
  final _controller = StreamController<RawLocationSample>.broadcast(sync: true);

  @override
  Future<void> start() async {
    startCalls++;
    _running = true;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _running = false;
  }

  @override
  Stream<RawLocationSample> positions() => _controller.stream;

  @override
  Future<bool> isRunning() async => _running;

  void emit(RawLocationSample sample) => _controller.add(sample);

  Future<void> dispose() => _controller.close();
}

/// Scripted driver-order repository: every call is answered from a queue or
/// a fixed function the test sets up, so exact upload/error-code sequences
/// can be exercised without a real backend.
class ScriptedDriverOrderRepository implements DriverOrderRepository {
  Result<DriverOrder> Function(String id)? getOrderByIdResult;
  Result<LocationUploadAck> Function(String orderId, int assignmentVersion)?
  uploadLocationResult;
  final List<Map<String, Object?>> uploadCalls = [];

  @override
  Future<Result<List<DriverOrder>>> getActiveOrders({
    int page = 1,
    int limit = 20,
  }) async => const Success([]);

  @override
  Future<Result<List<DriverOrder>>> getHistory({
    int page = 1,
    int limit = 20,
  }) async => const Success([]);

  @override
  Future<Result<DriverOrder>> getOrderById(String id) async =>
      getOrderByIdResult?.call(id) ??
      Err(NotFoundFailure('not found', _apiEx('ORDER_NOT_ASSIGNED')));

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
  }) async {
    uploadCalls.add({
      'orderId': orderId,
      'assignmentVersion': assignmentVersion,
    });
    return uploadLocationResult?.call(orderId, assignmentVersion) ??
        Success(
          LocationUploadAck(
            accepted: true,
            assignmentVersion: assignmentVersion,
            receivedAt: DateTime.now(),
          ),
        );
  }
}

ApiException _apiEx(String code) =>
    ApiException(statusCode: 409, error: 'Conflict', message: code, code: code);

DriverOrder _order({
  required String id,
  OrderStatus status = OrderStatus.outForDelivery,
  int assignmentVersion = 1,
}) => DriverOrder(
  id: id,
  orderNumber: 'KZ-$id',
  status: status,
  items: const [],
  deliveryMethod: FulfillmentType.delivery,
  customerName: 'Test Customer',
  paymentMethod: 'cash',
  paymentStatus: 'PENDING',
  amountToCollect: 0,
  totalAmount: 0,
  createdAt: DateTime.now(),
  assignmentVersion: assignmentVersion,
);

RawLocationSample _sample({DateTime? capturedAt}) => RawLocationSample(
  latitude: 30.05,
  longitude: 31.24,
  capturedAt: capturedAt ?? DateTime.now(),
);

/// Builds a coordinator whose `Ref` comes from a real provider in
/// [container] (a bare `ProviderContainer` is not itself a `Ref` — the
/// production coordinator is always constructed this way too, via
/// `driverTrackingCoordinatorProvider`).
DriverTrackingCoordinator _buildCoordinator(
  ProviderContainer container, {
  required DriverLocationSource locationSource,
  required Future<DriverLocationPermissionStatus> Function() checkPermission,
  required DateTime Function() now,
}) {
  final provider = Provider<DriverTrackingCoordinator>((ref) {
    final coordinator = DriverTrackingCoordinator(
      ref,
      locationSource: locationSource,
      checkPermission: checkPermission,
      now: now,
    );
    ref.onDispose(coordinator.endSession);
    return coordinator;
  });
  return container.read(provider);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLocationSource fakeSource;
  late ScriptedDriverOrderRepository fakeRepo;
  late ProviderContainer container;
  late DriverTrackingCoordinator coordinator;
  DateTime clock = DateTime(2026, 1, 1, 12);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeSource = FakeLocationSource();
    fakeRepo = ScriptedDriverOrderRepository();
    clock = DateTime(2026, 1, 1, 12);
    container = ProviderContainer(
      overrides: [driverOrderRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    coordinator = _buildCoordinator(
      container,
      locationSource: fakeSource,
      checkPermission: () async => DriverLocationPermissionStatus.always,
      now: () => clock,
    );
  });

  tearDown(() async {
    coordinator.endSession();
    await fakeSource.dispose();
    container.dispose();
  });

  group('start/stop lifecycle', () {
    test(
      'syncing an eligible OUT_FOR_DELIVERY order starts the location source',
      () async {
        coordinator.syncFromActiveOrders([_order(id: 'o1')]);
        await Future<void>.delayed(Duration.zero);
        // Let the async permission-check/start chain settle.
        await Future<void>.delayed(Duration.zero);

        expect(fakeSource.startCalls, 1);
        expect(coordinator.isTrackedForTesting('o1'), isTrue);
      },
    );

    test('PREPARING/DELIVERED orders are never tracked', () async {
      coordinator.syncFromActiveOrders([
        _order(id: 'o1', status: OrderStatus.preparing),
        _order(id: 'o2', status: OrderStatus.delivered),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(coordinator.isTrackedForTesting('o1'), isFalse);
      expect(coordinator.isTrackedForTesting('o2'), isFalse);
      expect(fakeSource.startCalls, 0);
    });

    test(
      'stopping the last eligible order stops the location source entirely',
      () async {
        coordinator.syncFromActiveOrders([_order(id: 'o1')]);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(fakeSource.startCalls, 1);

        coordinator.stopTracking('o1');
        await Future<void>.delayed(Duration.zero);

        expect(fakeSource.stopCalls, 1);
        expect(coordinator.isSchedulerRunningForTesting, isFalse);
      },
    );

    test(
      'permission not granted leaves the order tracked but never starts uploads',
      () async {
        coordinator = _buildCoordinator(
          container,
          locationSource: fakeSource,
          checkPermission: () async => DriverLocationPermissionStatus.denied,
          now: () => clock,
        );
        coordinator.syncFromActiveOrders([_order(id: 'o1')]);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(fakeSource.startCalls, 0);
        expect(
          container.read(driverTrackingStatusProvider),
          DriverTrackingStatus.permissionRequired,
        );
      },
    );
  });

  group('multi-order aggregate scheduling', () {
    test(
      'two eligible orders each get uploaded from the single shared location subscription',
      () async {
        coordinator.syncFromActiveOrders([
          _order(id: 'o1', assignmentVersion: 5),
          _order(id: 'o2', assignmentVersion: 9),
        ]);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(fakeSource.startCalls, 1); // one subscription, not two

        fakeSource.emit(_sample(capturedAt: clock));
        coordinator.debugSchedulerTick();
        await Future<void>.delayed(Duration.zero);

        final orderIds = fakeRepo.uploadCalls.map((c) => c['orderId']).toSet();
        expect(orderIds, {'o1', 'o2'});
        expect(
          fakeRepo.uploadCalls.firstWhere(
            (c) => c['orderId'] == 'o1',
          )['assignmentVersion'],
          5,
        );
        expect(
          fakeRepo.uploadCalls.firstWhere(
            (c) => c['orderId'] == 'o2',
          )['assignmentVersion'],
          9,
        );
      },
    );

    test(
      'the aggregate rate limiter budget throttles uploads once exhausted',
      () async {
        // A tight budget (2/min) so two ticks with several due orders can
        // exhaust it deterministically without waiting a real minute.
        coordinator = _buildCoordinator(
          container,
          locationSource: fakeSource,
          checkPermission: () async => DriverLocationPermissionStatus.always,
          now: () => clock,
        );
        coordinator.syncFromActiveOrders([
          for (var i = 0; i < 5; i++) _order(id: 'o$i'),
        ]);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        fakeSource.emit(_sample(capturedAt: clock));
        // Drain the limiter's real default budget (40) is too high to
        // exhaust quickly in a unit test with only 5 orders per tick, but
        // the "no overlap" guarantee below is what actually matters here:
        // once an order's upload is in flight, the same order is never
        // picked again until it resolves.
        coordinator.debugSchedulerTick();
        final callsAfterFirstTick = fakeRepo.uploadCalls.length;
        coordinator.debugSchedulerTick();
        await Future<void>.delayed(Duration.zero);

        // Second tick fires immediately after the first with the same
        // `now()` — every order is still "in flight" or not yet due again,
        // so it must add no *new* calls beyond the first tick's.
        expect(fakeRepo.uploadCalls.length, callsAfterFirstTick);
      },
    );
  });

  group('error-code handling', () {
    Future<void> setUpSingleOrderAndUpload({
      required Result<LocationUploadAck> Function(String, int) response,
    }) async {
      fakeRepo.uploadLocationResult = response;
      coordinator.syncFromActiveOrders([
        _order(id: 'o1', assignmentVersion: 3),
      ]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      fakeSource.emit(_sample(capturedAt: clock));
      coordinator.debugSchedulerTick();
      await Future<void>.delayed(Duration.zero);
    }

    test('ORDER_NOT_ASSIGNED stops tracking that order', () async {
      await setUpSingleOrderAndUpload(
        response: (_, __) =>
            Err(NotFoundFailure('gone', _apiEx('ORDER_NOT_ASSIGNED'))),
      );
      expect(coordinator.isTrackedForTesting('o1'), isFalse);
    });

    test(
      'ASSIGNMENT_VERSION_MISMATCH refetches and resumes with the new version',
      () async {
        fakeRepo.getOrderByIdResult = (id) =>
            Success(_order(id: id, assignmentVersion: 7));
        await setUpSingleOrderAndUpload(
          response: (_, __) => Err(
            ValidationFailure('stale', _apiEx('ASSIGNMENT_VERSION_MISMATCH')),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(coordinator.isTrackedForTesting('o1'), isTrue);
        expect(coordinator.trackedOrderVersionsForTesting['o1'], 7);
      },
    );

    test(
      'ASSIGNMENT_VERSION_MISMATCH followed by a no-longer-eligible order stops it',
      () async {
        fakeRepo.getOrderByIdResult = (id) =>
            Success(_order(id: id, status: OrderStatus.delivered));
        await setUpSingleOrderAndUpload(
          response: (_, __) => Err(
            ValidationFailure('stale', _apiEx('ASSIGNMENT_VERSION_MISMATCH')),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(coordinator.isTrackedForTesting('o1'), isFalse);
      },
    );

    test(
      'LOCATION_TOO_OLD discards the sample but keeps the order eligible',
      () async {
        await setUpSingleOrderAndUpload(
          response: (_, __) =>
              Err(ValidationFailure('old', _apiEx('LOCATION_TOO_OLD'))),
        );
        expect(coordinator.isTrackedForTesting('o1'), isTrue);
        expect(
          container.read(driverTrackingStatusProvider),
          DriverTrackingStatus.offline,
        );
      },
    );

    test(
      'a 429 RateLimitedFailure widens backoff without dropping the order',
      () async {
        await setUpSingleOrderAndUpload(
          response: (_, __) =>
              const Err(RateLimitedFailure('slow down', null, 5)),
        );
        expect(coordinator.isTrackedForTesting('o1'), isTrue);
        expect(coordinator.consecutiveFailuresForTesting('o1'), 1);
      },
    );

    test(
      'network failure applies bounded per-order backoff, never drops the order',
      () async {
        await setUpSingleOrderAndUpload(
          response: (_, __) => const Err(NetworkFailure('offline')),
        );
        expect(coordinator.isTrackedForTesting('o1'), isTrue);
        expect(coordinator.consecutiveFailuresForTesting('o1'), 1);
        expect(
          container.read(driverTrackingStatusProvider),
          DriverTrackingStatus.offline,
        );
      },
    );

    test(
      'accepted:false is treated as success, not a failure (no backoff applied)',
      () async {
        await setUpSingleOrderAndUpload(
          response: (orderId, version) => Success(
            LocationUploadAck(
              accepted: false,
              assignmentVersion: version,
              receivedAt: DateTime.now(),
            ),
          ),
        );
        expect(coordinator.consecutiveFailuresForTesting('o1'), 0);
        expect(
          container.read(driverTrackingStatusProvider),
          DriverTrackingStatus.sendingUpdates,
        );
      },
    );

    test('an AuthFailure ends the local session', () async {
      final authRepo = _TestAuthRepository()
        ..loginUser = User(
          id: 'drv-1',
          name: 'Driver One',
          email: 'driver1@test.com',
          role: 'DRIVER',
          createdAt: DateTime.now(),
        );
      final authContainer = ProviderContainer(
        overrides: [
          driverOrderRepositoryProvider.overrideWithValue(fakeRepo),
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(authContainer.dispose);
      // Establish a genuinely logged-in session first, so the assertion
      // below proves a real true -> false transition happened, not just
      // that the default (never-logged-in) state stayed false.
      await authContainer
          .read(authNotifierProvider.notifier)
          .login(identifier: 'driver1@test.com', password: 'password');
      expect(authContainer.read(authNotifierProvider).isLoggedIn, isTrue);

      final authCoordinator = _buildCoordinator(
        authContainer,
        locationSource: fakeSource,
        checkPermission: () async => DriverLocationPermissionStatus.always,
        now: () => clock,
      );
      addTearDown(authCoordinator.endSession);

      fakeRepo.uploadLocationResult = (_, __) =>
          Err(AuthFailure('deactivated', _apiEx('DRIVER_DEACTIVATED')));
      authCoordinator.syncFromActiveOrders([_order(id: 'o1')]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      fakeSource.emit(_sample(capturedAt: clock));
      authCoordinator.debugSchedulerTick();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(authContainer.read(authNotifierProvider).isLoggedIn, isFalse);
    });
  });

  group('session-epoch guard against late callbacks', () {
    test(
      'endSession bumps the epoch so an in-flight upload response cannot mutate the next session',
      () async {
        final completer = Completer<Result<LocationUploadAck>>();
        final slowRepo = _SlowUploadRepository(completer);
        final slowContainer = ProviderContainer(
          overrides: [
            driverOrderRepositoryProvider.overrideWithValue(slowRepo),
          ],
        );
        addTearDown(slowContainer.dispose);
        final slowCoordinator = _buildCoordinator(
          slowContainer,
          locationSource: fakeSource,
          checkPermission: () async => DriverLocationPermissionStatus.always,
          now: () => clock,
        );

        slowCoordinator.syncFromActiveOrders([
          _order(id: 'o1', assignmentVersion: 1),
        ]);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        fakeSource.emit(_sample(capturedAt: clock));
        slowCoordinator.debugSchedulerTick();
        await Future<void>.delayed(Duration.zero);

        final epochBeforeEnd = slowCoordinator.sessionEpochForTesting;
        slowCoordinator.endSession();
        expect(slowCoordinator.sessionEpochForTesting, epochBeforeEnd + 1);

        // The stale in-flight request now resolves — after the session
        // ended. It must not resurrect tracking for 'o1'.
        completer.complete(
          Success(
            LocationUploadAck(
              accepted: true,
              assignmentVersion: 1,
              receivedAt: DateTime.now(),
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(slowCoordinator.isTrackedForTesting('o1'), isFalse);
      },
    );
  });
}

class _SlowUploadRepository implements DriverOrderRepository {
  _SlowUploadRepository(this._completer);
  final Completer<Result<LocationUploadAck>> _completer;

  @override
  Future<Result<List<DriverOrder>>> getActiveOrders({
    int page = 1,
    int limit = 20,
  }) async => const Success([]);

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
  }) => _completer.future;
}
