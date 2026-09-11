import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/kitchen_repository.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/kitchen_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Covers [KitchenOrderNotifier.setPreparationTime] (the single-ticket
/// mutation path): success updates ticket state with the authoritative
/// backend response, failure leaves the ticket untouched and returns an
/// error message, and a successful mutation nudges [kitchenQueueProvider]'s
/// list (when it's already alive) so the queue reflects the change promptly
/// rather than waiting for its next 5s poll tick.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  KitchenOrder buildKitchenOrder({
    required String id,
    OrderStatus status = OrderStatus.preparing,
    int? preparationTimeMinutes,
    String? estimatedDeliveryTime,
  }) {
    return KitchenOrder(
      id: id,
      orderNumber: id,
      status: status,
      deliveryMethod: FulfillmentType.pickup,
      createdAt: DateTime(2026, 1, 1),
      items: const [],
      preparationTimeMinutes: preparationTimeMinutes,
      estimatedDeliveryTime: estimatedDeliveryTime,
    );
  }

  group('KitchenOrderNotifier.setPreparationTime', () {
    test('success updates state with the authoritative response', () async {
      final repo = _FakeKitchenRepository(
        onGetOrder: (id) => Success(buildKitchenOrder(id: id)),
        onSetPreparationTime: (id, minutes) => Success(
          buildKitchenOrder(
            id: id,
            preparationTimeMinutes: minutes,
            estimatedDeliveryTime: '2026-01-01T12:20:00.000Z',
          ),
        ),
      );
      final container = ProviderContainer(
        overrides: [kitchenRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(kitchenOrderProvider('order-1').future);
      final notifier = container.read(kitchenOrderProvider('order-1').notifier);

      final error = await notifier.setPreparationTime(20);

      expect(error, isNull);
      final state = container.read(kitchenOrderProvider('order-1'));
      expect(state.value!.preparationTimeMinutes, 20);
      expect(state.value!.estimatedDeliveryTime, '2026-01-01T12:20:00.000Z');
    });

    test('failure returns an error message and leaves the ticket untouched', () async {
      final repo = _FakeKitchenRepository(
        onGetOrder: (id) =>
            Success(buildKitchenOrder(id: id, preparationTimeMinutes: 10)),
        onSetPreparationTime: (id, minutes) =>
            const Err(NetworkFailure('boom')),
      );
      final container = ProviderContainer(
        overrides: [kitchenRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(kitchenOrderProvider('order-1').future);
      final notifier = container.read(kitchenOrderProvider('order-1').notifier);

      final error = await notifier.setPreparationTime(20);

      expect(error, 'boom');
      final state = container.read(kitchenOrderProvider('order-1'));
      expect(state.value!.preparationTimeMinutes, 10);
    });

    test(
      'a successful mutation updates the queue list when it is already alive',
      () async {
        final repo = _FakeKitchenRepository(
          onGetQueue: () => Success([buildKitchenOrder(id: 'order-1')]),
          onGetOrder: (id) => Success(buildKitchenOrder(id: id)),
          onSetPreparationTime: (id, minutes) => Success(
            buildKitchenOrder(id: id, preparationTimeMinutes: minutes),
          ),
        );
        final container = ProviderContainer(
          overrides: [kitchenRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        // Keep the queue provider alive, as it would be while the Kitchen
        // Queue screen is mounted behind the ticket.
        await container.read(kitchenQueueProvider.future);
        await container.read(kitchenOrderProvider('order-1').future);
        final notifier = container.read(
          kitchenOrderProvider('order-1').notifier,
        );

        await notifier.setPreparationTime(30);

        final queue = container.read(kitchenQueueProvider).value!;
        expect(queue.single.preparationTimeMinutes, 30);
      },
    );
  });
}

class _FakeKitchenRepository implements KitchenRepository {
  final Result<List<KitchenOrder>> Function()? onGetQueue;
  final Result<KitchenOrder> Function(String id)? onGetOrder;
  final Result<KitchenOrder> Function(String id, int minutes)?
  onSetPreparationTime;

  _FakeKitchenRepository({
    this.onGetQueue,
    this.onGetOrder,
    this.onSetPreparationTime,
  });

  @override
  Future<Result<List<KitchenOrder>>> getQueue() async => onGetQueue!();

  @override
  Future<Result<KitchenOrder>> getOrder(String id) async => onGetOrder!(id);

  @override
  Future<Result<KitchenOrder>> setPreparationTime(
    String orderId,
    int minutes,
  ) async => onSetPreparationTime!(orderId, minutes);
}
