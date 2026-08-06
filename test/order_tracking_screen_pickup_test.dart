import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/order_tracking_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Widget-level coverage for the fulfillment-aware customer tracking
/// timeline (Fix 12D — pickup-specific status flow). Verifies:
///  - the Delivery timeline contains exactly its 5 steps and never a Pickup
///    step, and vice versa;
///  - the readyForPickup / pickedUp EN and AR labels render correctly;
///  - a picked-up order renders the completed-Pickup wording.
class _FakeOrderRepository implements OrderRepository {
  final Order order;
  _FakeOrderRepository(this.order);

  @override
  Stream<Order> watchOrder(String id) => Stream.value(order);

  @override
  Future<Result<Order>> getOrderById(String id) async => Success(order);

  @override
  Future<Result<Order>> getAdminOrderById(String id) async => Success(order);

  @override
  Future<Result<List<Order>>> getOrders({
    String? userId,
    int? page,
    int? limit,
    String? status,
  }) async => Success([order]);

  @override
  Future<Result<Order>> checkout({
    required FulfillmentType deliveryMethod,
    required String paymentMethod,
    Map<String, dynamic>? deliveryAddress,
    String? promoCode,
    String? redeemRewardId,
    String? notes,
    required String idempotencyKey,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Order>> createOrder(Order order) async =>
      throw UnimplementedError();

  @override
  Future<Result<Order>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async => throw UnimplementedError();

  @override
  Future<Result<List<Order>>> getAllOrders() async => Success([order]);
}

Order _order({
  required FulfillmentType fulfillmentType,
  required OrderStatus status,
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
);

Future<void> _pump(
  WidgetTester tester,
  Order order, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orderRepositoryProvider.overrideWithValue(_FakeOrderRepository(order)),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        useOnlyLangCode: true,
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: OrderTrackingScreen(orderId: order.id),
          ),
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

  testWidgets(
    'Delivery timeline shows exactly the 5 Delivery steps, no Pickup step',
    (tester) async {
      final order = _order(
        fulfillmentType: FulfillmentType.delivery,
        status: OrderStatus.outForDelivery,
      );
      await _pump(tester, order);

      expect(tester.takeException(), isNull);
      expect(find.text('Order Received'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Preparing in Kitchen'), findsOneWidget);
      expect(find.text('On the Way'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      // Never contains the Pickup-only steps.
      expect(find.text('Ready for Pickup'), findsNothing);
      expect(find.text('Picked Up'), findsNothing);
    },
  );

  testWidgets(
    'Pickup timeline shows exactly the 5 Pickup steps, no Delivery step',
    (tester) async {
      final order = _order(
        fulfillmentType: FulfillmentType.pickup,
        status: OrderStatus.readyForPickup,
      );
      await _pump(tester, order);

      expect(tester.takeException(), isNull);
      expect(find.text('Order Received'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Preparing in Kitchen'), findsOneWidget);
      expect(find.text('Ready for Pickup'), findsOneWidget);
      expect(find.text('Picked Up'), findsOneWidget);

      // Never contains the Delivery-only steps.
      expect(find.text('On the Way'), findsNothing);
      expect(find.text('Delivered'), findsNothing);
    },
  );

  testWidgets('readyForPickup status description renders in English', (
    tester,
  ) async {
    final order = _order(
      fulfillmentType: FulfillmentType.pickup,
      status: OrderStatus.readyForPickup,
    );
    await _pump(tester, order);

    // Renders both in the status header and as the active timeline step's
    // subtitle, so at least one (and only ever these two) instances.
    expect(
      find.text('Your order is ready to be collected.'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('readyForPickup status description renders in Arabic', (
    tester,
  ) async {
    final order = _order(
      fulfillmentType: FulfillmentType.pickup,
      status: OrderStatus.readyForPickup,
    );
    await _pump(tester, order, locale: const Locale('ar'));

    expect(find.text('طلبك جاهز للاستلام.'), findsAtLeastNWidgets(1));
  });

  testWidgets(
    'pickedUp order renders the completed-Pickup wording in English',
    (tester) async {
      final order = _order(
        fulfillmentType: FulfillmentType.pickup,
        status: OrderStatus.pickedUp,
      );
      await _pump(tester, order);

      expect(
        find.text('Your order has been picked up. Enjoy!'),
        findsAtLeastNWidgets(1),
      );
      // Timeline step title for the completed Pickup step.
      expect(find.text('Picked Up'), findsOneWidget);
    },
  );

  testWidgets('pickedUp order renders the completed-Pickup wording in Arabic', (
    tester,
  ) async {
    final order = _order(
      fulfillmentType: FulfillmentType.pickup,
      status: OrderStatus.pickedUp,
    );
    await _pump(tester, order, locale: const Locale('ar'));

    expect(
      find.text('تم استلام طلبك، بالهنا والشفا.'),
      findsAtLeastNWidgets(1),
    );
  });
}
