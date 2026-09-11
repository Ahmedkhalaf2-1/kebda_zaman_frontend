import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/order_tracking_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Covers the ETA display on OrderTrackingScreen's status banner: the
/// backend's raw ISO `estimatedTime` must always be formatted (never shown
/// raw), the label must be fulfillment-aware (Estimated arrival for
/// DELIVERY, Estimated ready time for PICKUP), a null/malformed ETA must
/// fall back to the existing "unavailable" copy, and an ETA-only stream
/// update (no status change) must still update the displayed ETA.
class _FakeOrderRepository implements OrderRepository {
  final Stream<Order> stream;
  _FakeOrderRepository(this.stream);

  @override
  Stream<Order> watchOrder(String id) => stream;

  @override
  Future<Result<Order>> getOrderById(String id) => throw UnimplementedError();
  @override
  Future<Result<Order>> getAdminOrderById(String id) =>
      throw UnimplementedError();
  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  }) => throw UnimplementedError();
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
  Future<Result<Order>> updateOrderStatus(String orderId, OrderStatus status) =>
      throw UnimplementedError();
  @override
  Future<Result<List<Order>>> getAllOrders() => throw UnimplementedError();
}

Order _order({
  FulfillmentType fulfillmentType = FulfillmentType.delivery,
  OrderStatus status = OrderStatus.preparing,
  String? estimatedTime,
}) => Order(
  id: 'order-1',
  orderNumber: 'ORD-1',
  userId: 'user-1',
  items: const [],
  fulfillmentType: fulfillmentType,
  status: status,
  subtotal: 10,
  grandTotal: 10,
  placedAt: DateTime(2026, 7, 1),
  estimatedTime: estimatedTime,
);

Future<void> _settle(
  WidgetTester tester, {
  int maxSteps = 20,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < maxSteps; i++) {
    await tester.pump(step);
  }
}

Future<void> _pumpStream(WidgetTester tester, Stream<Order> stream) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orderRepositoryProvider.overrideWithValue(
          _FakeOrderRepository(stream),
        ),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        useOnlyLangCode: true,
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: const OrderTrackingScreen(orderId: 'order-1'),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('DELIVERY order shows "Estimated Arrival" wording', (
    tester,
  ) async {
    final utc = DateTime.utc(2026, 9, 11, 17, 35).toIso8601String();
    await _pumpStream(
      tester,
      Stream.value(
        _order(
          fulfillmentType: FulfillmentType.delivery,
          estimatedTime: utc,
        ),
      ),
    );

    expect(find.text('ESTIMATED ARRIVAL'), findsOneWidget);
    expect(find.text('ESTIMATED READY TIME'), findsNothing);
  });

  testWidgets('PICKUP order shows "Estimated Ready Time" wording', (
    tester,
  ) async {
    final utc = DateTime.utc(2026, 9, 11, 17, 35).toIso8601String();
    await _pumpStream(
      tester,
      Stream.value(
        _order(fulfillmentType: FulfillmentType.pickup, estimatedTime: utc),
      ),
    );

    expect(find.text('ESTIMATED READY TIME'), findsOneWidget);
    expect(find.text('ESTIMATED ARRIVAL'), findsNothing);
  });

  testWidgets('the raw ISO timestamp is never rendered', (tester) async {
    final utc = DateTime.utc(2026, 9, 11, 17, 35).toIso8601String();
    await _pumpStream(tester, Stream.value(_order(estimatedTime: utc)));

    expect(find.textContaining('2026-09-11T'), findsNothing);
    expect(find.textContaining('.000Z'), findsNothing);
  });

  testWidgets('a null estimatedTime falls back to "unavailable"', (
    tester,
  ) async {
    await _pumpStream(tester, Stream.value(_order(estimatedTime: null)));

    expect(
      find.text('Estimated time will be updated soon'),
      findsOneWidget,
    );
  });

  testWidgets('a malformed estimatedTime falls back to "unavailable"', (
    tester,
  ) async {
    await _pumpStream(
      tester,
      Stream.value(_order(estimatedTime: 'not-a-real-timestamp')),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.text('Estimated time will be updated soon'),
      findsOneWidget,
    );
  });

  testWidgets(
    'an ETA-only stream update (same status) updates the displayed ETA',
    (tester) async {
      final controller = StreamController<Order>();
      addTearDown(controller.close);

      final firstEta = DateTime.utc(2026, 9, 11, 17, 35).toIso8601String();
      final secondEta = DateTime.utc(2026, 9, 11, 18, 5).toIso8601String();

      controller.add(_order(estimatedTime: firstEta));
      await _pumpStream(tester, controller.stream);

      expect(tester.takeException(), isNull);
      expect(find.text(formatEtaClockTime(firstEta)!), findsOneWidget);

      controller.add(_order(estimatedTime: secondEta));
      await _settle(tester);

      expect(find.text(formatEtaClockTime(secondEta)!), findsOneWidget);
    },
  );
}
