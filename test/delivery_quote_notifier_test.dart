import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/delivery_quote_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_quote.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/delivery_quote_repository.dart';

class _MockDeliveryQuoteRepository implements DeliveryQuoteRepository {
  int callCount = 0;
  final List<({double latitude, double longitude})> calls = [];
  Result<DeliveryQuote> Function()? nextResult;
  Completer<Result<DeliveryQuote>>? pending;

  @override
  Future<Result<DeliveryQuote>> getQuote({
    required double latitude,
    required double longitude,
  }) async {
    callCount++;
    calls.add((latitude: latitude, longitude: longitude));
    if (pending != null) return pending!.future;
    return nextResult!();
  }
}

const _deliverableQuote = DeliveryQuote(
  deliverable: true,
  distanceMeters: 5000,
  distanceKm: 5.0,
  deliveryFee: 10.0,
  currency: 'SAR',
  tier: DeliveryQuoteTier(id: 't1', minDistanceKm: 0, maxDistanceKm: 15),
);

void main() {
  group('DeliveryQuoteNotifier', () {
    test(
      'PICKUP never calls the repository and clears state to null',
      () async {
        final mockRepo = _MockDeliveryQuoteRepository();
        final container = ProviderContainer(
          overrides: [
            deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(deliveryQuoteProvider.notifier);
        await notifier.requestQuote(
          deliveryMethod: FulfillmentType.pickup,
          latitude: 21.57,
          longitude: 39.16,
        );

        expect(mockRepo.callCount, 0);
        expect(container.read(deliveryQuoteProvider).value, isNull);
      },
    );

    test('missing/invalid coordinates never call the repository', () async {
      final mockRepo = _MockDeliveryQuoteRepository();
      final container = ProviderContainer(
        overrides: [
          deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(deliveryQuoteProvider.notifier);

      await notifier.requestQuote(
        deliveryMethod: FulfillmentType.delivery,
        latitude: null,
        longitude: null,
      );
      expect(mockRepo.callCount, 0);

      // Null-island sentinel is treated as invalid, never sent.
      await notifier.requestQuote(
        deliveryMethod: FulfillmentType.delivery,
        latitude: 0.0,
        longitude: 0.0,
      );
      expect(mockRepo.callCount, 0);

      await notifier.requestQuote(
        deliveryMethod: FulfillmentType.delivery,
        latitude: 200.0,
        longitude: 39.16,
      );
      expect(mockRepo.callCount, 0);
    });

    test(
      'loading then success state transition for a deliverable quote',
      () async {
        final mockRepo = _MockDeliveryQuoteRepository();
        mockRepo.pending = Completer<Result<DeliveryQuote>>();
        final container = ProviderContainer(
          overrides: [
            deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(deliveryQuoteProvider.notifier);

        final future = notifier.requestQuote(
          deliveryMethod: FulfillmentType.delivery,
          latitude: 21.57,
          longitude: 39.16,
        );

        expect(container.read(deliveryQuoteProvider).isLoading, isTrue);

        mockRepo.pending!.complete(const Success(_deliverableQuote));
        await future;

        final state = container.read(deliveryQuoteProvider);
        expect(state.hasValue, isTrue);
        expect(state.value!.deliverable, isTrue);
        expect(state.value!.deliveryFee, equals(10.0));
        expect(mockRepo.callCount, 1);
      },
    );

    test(
      'out-of-range quote surfaces as a successful, non-deliverable value',
      () async {
        final mockRepo = _MockDeliveryQuoteRepository();
        mockRepo.nextResult = () => const Success(
          DeliveryQuote(
            deliverable: false,
            distanceMeters: 30500,
            currency: 'SAR',
            reason: 'OUTSIDE_DELIVERY_RANGE',
          ),
        );
        final container = ProviderContainer(
          overrides: [
            deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(deliveryQuoteProvider.notifier);

        await notifier.requestQuote(
          deliveryMethod: FulfillmentType.delivery,
          latitude: 25.0,
          longitude: 40.0,
        );

        final state = container.read(deliveryQuoteProvider);
        expect(state.hasValue, isTrue);
        expect(state.value!.deliverable, isFalse);
        expect(state.value!.reason, equals('OUTSIDE_DELIVERY_RANGE'));
      },
    );

    test('repository/provider failure surfaces as an error state', () async {
      final mockRepo = _MockDeliveryQuoteRepository();
      mockRepo.nextResult = () =>
          const Err(NetworkFailure('Failed to calculate delivery fee'));
      final container = ProviderContainer(
        overrides: [
          deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(deliveryQuoteProvider.notifier);

      await notifier.requestQuote(
        deliveryMethod: FulfillmentType.delivery,
        latitude: 21.57,
        longitude: 39.16,
      );

      final state = container.read(deliveryQuoteProvider);
      expect(state.hasError, isTrue);
    });

    test(
      'repeat calls with identical method+coordinates do not re-hit the repository',
      () async {
        final mockRepo = _MockDeliveryQuoteRepository();
        mockRepo.nextResult = () => const Success(_deliverableQuote);
        final container = ProviderContainer(
          overrides: [
            deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(deliveryQuoteProvider.notifier);

        await notifier.requestQuote(
          deliveryMethod: FulfillmentType.delivery,
          latitude: 21.57,
          longitude: 39.16,
        );
        // Simulates a widget rebuild re-triggering the same request.
        await notifier.requestQuote(
          deliveryMethod: FulfillmentType.delivery,
          latitude: 21.57,
          longitude: 39.16,
        );
        await notifier.requestQuote(
          deliveryMethod: FulfillmentType.delivery,
          latitude: 21.57,
          longitude: 39.16,
        );

        expect(mockRepo.callCount, 1);
      },
    );

    test('a changed coordinate does trigger a new request', () async {
      final mockRepo = _MockDeliveryQuoteRepository();
      mockRepo.nextResult = () => const Success(_deliverableQuote);
      final container = ProviderContainer(
        overrides: [
          deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(deliveryQuoteProvider.notifier);

      await notifier.requestQuote(
        deliveryMethod: FulfillmentType.delivery,
        latitude: 21.57,
        longitude: 39.16,
      );
      await notifier.requestQuote(
        deliveryMethod: FulfillmentType.delivery,
        latitude: 21.60,
        longitude: 39.16,
      );

      expect(mockRepo.callCount, 2);
    });

    test(
      'switching to PICKUP then back to DELIVERY for the same address re-requests',
      () async {
        final mockRepo = _MockDeliveryQuoteRepository();
        mockRepo.nextResult = () => const Success(_deliverableQuote);
        final container = ProviderContainer(
          overrides: [
            deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(deliveryQuoteProvider.notifier);

        await notifier.requestQuote(
          deliveryMethod: FulfillmentType.delivery,
          latitude: 21.57,
          longitude: 39.16,
        );
        expect(mockRepo.callCount, 1);

        await notifier.requestQuote(deliveryMethod: FulfillmentType.pickup);
        expect(container.read(deliveryQuoteProvider).value, isNull);

        await notifier.requestQuote(
          deliveryMethod: FulfillmentType.delivery,
          latitude: 21.57,
          longitude: 39.16,
        );
        expect(mockRepo.callCount, 2);
      },
    );

    test(
      'retry re-requests the last-attempted coordinates after a failure',
      () async {
        final mockRepo = _MockDeliveryQuoteRepository();
        var attempt = 0;
        mockRepo.nextResult = () {
          attempt++;
          if (attempt == 1) {
            return const Err(NetworkFailure('temporary'));
          }
          return const Success(_deliverableQuote);
        };
        final container = ProviderContainer(
          overrides: [
            deliveryQuoteRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(deliveryQuoteProvider.notifier);

        await notifier.requestQuote(
          deliveryMethod: FulfillmentType.delivery,
          latitude: 21.57,
          longitude: 39.16,
        );
        expect(container.read(deliveryQuoteProvider).hasError, isTrue);

        await notifier.retry();

        expect(mockRepo.callCount, 2);
        expect(
          container.read(deliveryQuoteProvider).value!.deliverable,
          isTrue,
        );
      },
    );
  });
}
