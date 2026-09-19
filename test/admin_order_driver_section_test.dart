import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/driver_account.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/driver_repository.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_order_driver_section.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/orders_reset_summary.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Widget-level coverage for the admin driver-assignment picker's
/// availability rules: AVAILABLE is selectable, BUSY is disabled (no
/// confirm-tap escape hatch), `unknown` stays selectable (pre-availability
/// backend behavior), and a rejected assignment (simulating a `409
/// DRIVER_ALREADY_BUSY` race) surfaces the backend's message and refreshes
/// the driver directory rather than crashing or leaving stale state.
class _FakeDriverRepository implements DriverRepository {
  _FakeDriverRepository(this.drivers);
  List<DriverAccount> drivers;
  int getDriversCallCount = 0;

  @override
  Future<Result<List<DriverAccount>>> getDrivers({
    String? query,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    getDriversCallCount++;
    return Success(drivers);
  }

  @override
  Future<Result<DriverAccount>> getDriverById(String id) =>
      throw UnimplementedError();
  @override
  Future<Result<DriverAccount>> createDriver({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => throw UnimplementedError();
  @override
  Future<Result<DriverAccount>> updateDriver(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? password,
    bool? isActive,
  }) => throw UnimplementedError();
}

class _FakeOrderRepository implements OrderRepository {
  _FakeOrderRepository(this.order, {this.assignDriverResult});
  final Order order;
  final Result<Order>? assignDriverResult;
  String? lastAssignedDriverId;

  @override
  Future<Result<Order>> getAdminOrderById(String id) async => Success(order);
  @override
  Future<Result<Order>> assignDriver(String orderId, String driverId) async {
    lastAssignedDriverId = driverId;
    return assignDriverResult ??
        Success(order.copyWith(driverId: driverId));
  }

  @override
  Future<Result<Order>> unassignDriver(String orderId) =>
      throw UnimplementedError();
  @override
  Future<Result<List<Order>>> getAllOrders() => throw UnimplementedError();
  @override
  Future<Result<Order>> checkout({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
    required String idempotencyKey,
  }) => throw UnimplementedError();
  @override
  Future<Result<Order>> createOrder(Order order) => throw UnimplementedError();
  @override
  Future<Result<Order>> getOrderById(String id) => throw UnimplementedError();
  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  }) => throw UnimplementedError();
  @override
  Future<Result<Order>> updateOrderStatus(String orderId, OrderStatus status) =>
      throw UnimplementedError();
  @override
  Stream<Order> watchOrder(String id) => throw UnimplementedError();
  @override
  Future<Result<OrdersResetSummary>> previewResetOrders() =>
      throw UnimplementedError();
  @override
  Future<Result<OrdersResetSummary>> resetOrders() =>
      throw UnimplementedError();
}

Order _buildOrder() {
  return Order(
    id: 'order-1',
    orderNumber: 'ORD-1',
    userId: 'user-1',
    items: const [],
    fulfillmentType: FulfillmentType.delivery,
    status: OrderStatus.confirmed,
    subtotal: 10,
    grandTotal: 10,
    placedAt: DateTime(2026, 1, 1),
  );
}

DriverAccount _driver(
  String id,
  String name,
  DriverAvailability availability,
) {
  return DriverAccount(
    id: id,
    name: name,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    availability: availability,
  );
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required _FakeDriverRepository driverRepo,
  required _FakeOrderRepository orderRepo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        driverRepositoryProvider.overrideWithValue(driverRepo),
        orderRepositoryProvider.overrideWithValue(orderRepo),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        startLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        saveLocale: false,
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: Scaffold(
                body: AdminOrderDriverSection(
                  orderId: 'order-1',
                  order: orderRepo.order,
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('AdminOrderDriverSection driver picker availability', () {
    testWidgets('an AVAILABLE driver is selectable and assigns', (
      tester,
    ) async {
      final driverRepo = _FakeDriverRepository([
        _driver('driver-1', 'Ahmed', DriverAvailability.available),
      ]);
      final orderRepo = _FakeOrderRepository(_buildOrder());
      await _pumpSection(tester, driverRepo: driverRepo, orderRepo: orderRepo);

      await tester.tap(find.text('Assign Driver'));
      await tester.pumpAndSettle();
      expect(find.text('Ahmed'), findsOneWidget);

      await tester.tap(find.text('Ahmed'));
      await tester.pumpAndSettle();

      expect(orderRepo.lastAssignedDriverId, 'driver-1');
    });

    testWidgets('a BUSY driver is visible but not selectable', (
      tester,
    ) async {
      final driverRepo = _FakeDriverRepository([
        _driver('driver-1', 'Busy Driver', DriverAvailability.busy),
      ]);
      final orderRepo = _FakeOrderRepository(_buildOrder());
      await _pumpSection(tester, driverRepo: driverRepo, orderRepo: orderRepo);

      await tester.tap(find.text('Assign Driver'));
      await tester.pumpAndSettle();
      expect(find.text('Busy Driver'), findsOneWidget);
      expect(find.text('Busy'), findsOneWidget);

      await tester.tap(find.text('Busy Driver'));
      await tester.pumpAndSettle();

      // No confirm dialog, no assignment — the picker dialog is still open.
      expect(orderRepo.lastAssignedDriverId, isNull);
      expect(find.text('Select a Driver'), findsOneWidget);
    });

    testWidgets(
      'unknown availability (older backend response) stays selectable',
      (tester) async {
        final driverRepo = _FakeDriverRepository([
          _driver('driver-1', 'Legacy Driver', DriverAvailability.unknown),
        ]);
        final orderRepo = _FakeOrderRepository(_buildOrder());
        await _pumpSection(
          tester,
          driverRepo: driverRepo,
          orderRepo: orderRepo,
        );

        await tester.tap(find.text('Assign Driver'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Legacy Driver'));
        await tester.pumpAndSettle();

        expect(orderRepo.lastAssignedDriverId, 'driver-1');
      },
    );

    testWidgets(
      '409 DRIVER_ALREADY_BUSY (race after the list loaded) shows the backend message and refreshes the driver list',
      (tester) async {
        final driverRepo = _FakeDriverRepository([
          _driver('driver-1', 'Ahmed', DriverAvailability.available),
        ]);
        final orderRepo = _FakeOrderRepository(
          _buildOrder(),
          assignDriverResult: const Err(
            ValidationFailure('This driver is already on another delivery'),
          ),
        );
        await _pumpSection(
          tester,
          driverRepo: driverRepo,
          orderRepo: orderRepo,
        );

        await tester.tap(find.text('Assign Driver'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ahmed'));
        await tester.pumpAndSettle();

        expect(
          find.text('This driver is already on another delivery'),
          findsOneWidget,
        );
        // Initial load + the post-failure refresh.
        expect(driverRepo.getDriversCallCount, greaterThanOrEqualTo(2));
      },
    );
  });
}
