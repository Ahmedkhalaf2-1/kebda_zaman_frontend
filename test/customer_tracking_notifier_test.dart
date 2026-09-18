import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/customer_tracking_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order_tracking.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/tracking_repository.dart';

class ScriptedTrackingRepository implements TrackingRepository {
  Result<OrderTracking> Function()? nextResult;
  int callCount = 0;

  @override
  Future<Result<OrderTracking>> getCustomerTracking(String orderId) async {
    callCount++;
    return nextResult?.call() ?? Success(_tracking(TrackingState.active));
  }

  @override
  Future<Result<OrderTracking>> getAdminTracking(String orderId) async =>
      throw UnimplementedError();
}

OrderTracking _tracking(
  TrackingState state, {
  TrackingLocationSample? location,
}) => OrderTracking(orderId: 'order-1', state: state, location: location);

TrackingLocationSample _sample() => TrackingLocationSample(
  latitude: 30.0,
  longitude: 31.0,
  capturedAt: DateTime(2026, 1, 1),
  receivedAt: DateTime(2026, 1, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScriptedTrackingRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = ScriptedTrackingRepository();
    container = ProviderContainer(
      overrides: [trackingRepositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() => container.dispose());

  test('polls periodically while the provider is active', () {
    fakeAsync((async) {
      repo.nextResult = () => Success(_tracking(TrackingState.active));
      container.listen(customerTrackingProvider('order-1'), (_, __) {});
      async.elapse(Duration.zero);
      expect(repo.callCount, 1);

      async.elapse(const Duration(seconds: 10));
      expect(repo.callCount, 2);

      async.elapse(const Duration(seconds: 10));
      expect(repo.callCount, 3);
    });
  });

  test('stops polling once the backend reports ENDED', () {
    fakeAsync((async) {
      var call = 0;
      repo.nextResult = () {
        call++;
        return Success(
          _tracking(call == 1 ? TrackingState.active : TrackingState.ended),
        );
      };
      container.listen(customerTrackingProvider('order-1'), (_, __) {});
      async.elapse(Duration.zero);
      expect(repo.callCount, 1);

      async.elapse(const Duration(seconds: 10));
      expect(repo.callCount, 2); // the tick that observes ENDED

      // No further ticks are scheduled once ENDED is observed.
      async.elapse(const Duration(seconds: 30));
      expect(repo.callCount, 2);
    });
  });

  test('disposing the provider (navigation away) cancels the poll timer', () {
    fakeAsync((async) {
      repo.nextResult = () => Success(_tracking(TrackingState.active));
      final sub = container.listen(
        customerTrackingProvider('order-1'),
        (_, __) {},
      );
      async.elapse(Duration.zero);
      final notifier = container.read(
        customerTrackingProvider('order-1').notifier,
      );
      expect(notifier.hasActiveTimerForTesting, isTrue);

      sub.close();
      container.invalidate(customerTrackingProvider('order-1'));
      async.elapse(Duration.zero);

      expect(notifier.hasActiveTimerForTesting, isFalse);
    });
  });

  test(
    'a failed background poll keeps showing the last-known tracking rather than an error',
    () {
      fakeAsync((async) {
        var call = 0;
        repo.nextResult = () {
          call++;
          if (call == 1)
            return Success(
              _tracking(TrackingState.active, location: _sample()),
            );
          return const Err(NetworkFailure('offline'));
        };
        container.listen(customerTrackingProvider('order-1'), (_, __) {});
        async.elapse(Duration.zero);
        final firstValue = container
            .read(customerTrackingProvider('order-1'))
            .valueOrNull;
        expect(firstValue, isNotNull);

        async.elapse(const Duration(seconds: 10));
        final afterFailedPoll = container.read(
          customerTrackingProvider('order-1'),
        );
        // Still holding the last successful data, not AsyncError.
        expect(afterFailedPoll.hasValue, isTrue);
        expect(afterFailedPoll.valueOrNull!.location, isNotNull);
      });
    },
  );

  test('an explicit refresh() surfaces a failure as AsyncError', () async {
    repo.nextResult = () => Success(_tracking(TrackingState.active));
    container.listen(customerTrackingProvider('order-1'), (_, __) {});
    await container.read(customerTrackingProvider('order-1').future);

    repo.nextResult = () => const Err(NetworkFailure('offline'));
    await container
        .read(customerTrackingProvider('order-1').notifier)
        .refresh();

    expect(
      container.read(customerTrackingProvider('order-1')).hasError,
      isTrue,
    );
  });

  test(
    'app backgrounding pauses polling and resuming forces an immediate tick',
    () {
      fakeAsync((async) {
        repo.nextResult = () => Success(_tracking(TrackingState.active));
        container.listen(customerTrackingProvider('order-1'), (_, __) {});
        async.elapse(Duration.zero);
        expect(repo.callCount, 1);

        final binding = WidgetsBinding.instance;
        binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        async.elapse(const Duration(seconds: 30));
        // No new ticks while paused.
        expect(repo.callCount, 1);

        binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        async.elapse(Duration.zero);
        expect(repo.callCount, 2); // immediate re-fetch on resume
      });
    },
  );
}
