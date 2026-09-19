import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/kitchen_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/orders_reset_summary.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_order_details_screen.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Covers the admin `customerPhone` field end to end: it appears (and the
/// "Call Customer" action is offered) when the backend's admin order
/// response carries it, and is hidden gracefully — never a broken/empty
/// action — when it doesn't. Uses PICKUP orders so neither the driver-
/// assignment section nor the live tracking section (which need their own
/// repository overrides) render, keeping this test focused on the customer
/// info card.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<User?>> getCurrentUser() async => const Success(null);
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<void>> deleteAccount() => throw UnimplementedError();
  @override
  Future<Result<User>> login(String email, String password) =>
      throw UnimplementedError();
  @override
  Future<Result<User>> adminLogin(String email, String password) =>
      throw UnimplementedError();
  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) =>
      throw UnimplementedError();
  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<Result<User>> guestLogin() => throw UnimplementedError();
  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) => throw UnimplementedError();
  @override
  Future<Result<void>> forgotPassword(String email) async =>
      throw UnimplementedError();
  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async => throw UnimplementedError();
}

class _FakeOrderRepository implements OrderRepository {
  _FakeOrderRepository(this.order);
  final Order order;

  @override
  Future<Result<Order>> getAdminOrderById(String id) async => Success(order);
  @override
  Future<Result<Order>> assignDriver(String orderId, String driverId) =>
      throw UnimplementedError();
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

class _FakeKitchenRepository implements KitchenRepository {
  @override
  Future<Result<KitchenOrder>> getOrder(String id) => throw UnimplementedError();
  @override
  Future<Result<List<KitchenOrder>>> getQueue() => throw UnimplementedError();
  @override
  Future<Result<KitchenOrder>> setPreparationTime(String orderId, int minutes) =>
      throw UnimplementedError();
}

Order _buildOrder({String? customerPhone}) {
  return Order(
    id: 'order-1',
    orderNumber: 'ORD-1',
    userId: 'user-1',
    customerName: 'Ahmed Customer',
    items: const [],
    fulfillmentType: FulfillmentType.pickup,
    status: OrderStatus.confirmed,
    subtotal: 10,
    grandTotal: 10,
    placedAt: DateTime(2026, 1, 1),
    customerPhone: customerPhone,
  );
}

Future<void> _pumpScreen(WidgetTester tester, {required Order order}) async {
  final staffUser = User(
    id: 'staff-1',
    name: 'Staff',
    role: 'ADMIN',
    createdAt: DateTime(2026, 1, 1),
  );
  SharedPreferences.setMockInitialValues({
    AuthNotifier.isLoggedInKey: true,
    AuthNotifier.userKey: jsonEncode(staffUser.toJson()),
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        orderRepositoryProvider.overrideWithValue(_FakeOrderRepository(order)),
        kitchenRepositoryProvider.overrideWithValue(_FakeKitchenRepository()),
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
              home: const AdminOrderDetailsScreen(orderId: 'order-1'),
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

  group('AdminOrderDetailsScreen customer phone', () {
    testWidgets(
      'shows the phone and a Call Customer action when present',
      (tester) async {
        await _pumpScreen(
          tester,
          order: _buildOrder(customerPhone: '0500000000'),
        );

        expect(find.text('0500000000'), findsOneWidget);
        expect(find.text('Call Customer'), findsOneWidget);
      },
    );

    testWidgets(
      'hides the phone/Call Customer action gracefully when null',
      (tester) async {
        await _pumpScreen(tester, order: _buildOrder(customerPhone: null));

        expect(find.text('Call Customer'), findsNothing);
      },
    );

    testWidgets(
      'hides the phone/Call Customer action gracefully when empty',
      (tester) async {
        await _pumpScreen(tester, order: _buildOrder(customerPhone: '  '));

        expect(find.text('Call Customer'), findsNothing);
      },
    );
  });
}
