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

/// [AdminOrderDetailsScreen] is reachable by both ADMIN and CASHIER
/// (`/admin/orders` is a shared route — see router.dart), so the
/// preparation-time override control must be gated client-side on the
/// signed-in user's role, not just left to the backend's 403. Covers that
/// gate through the real screen + the real [authNotifierProvider], seeding
/// its cached-user SharedPreferences read (`AuthNotifier._loadCachedUserForDisplay`)
/// with a user of the desired role rather than subclassing the notifier —
/// `authNotifierProvider`'s override type is pinned to the concrete
/// `AuthNotifier` class, so a lighter fake `StateNotifier<AuthState>` isn't
/// assignable to it.
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
}

class _FakeOrderRepository implements OrderRepository {
  final Order order;
  _FakeOrderRepository(this.order);

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

Order _buildOrder({
  FulfillmentType fulfillmentType = FulfillmentType.pickup,
  OrderStatus status = OrderStatus.confirmed,
}) {
  return Order(
    id: 'order-1',
    orderNumber: 'ORD-1',
    userId: 'user-1',
    items: const [],
    fulfillmentType: fulfillmentType,
    status: status,
    subtotal: 10,
    grandTotal: 10,
    placedAt: DateTime(2026, 1, 1),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required String role,
  Order? order,
}) async {
  final staffUser = User(
    id: 'staff-1',
    name: 'Staff',
    role: role,
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
        orderRepositoryProvider.overrideWithValue(
          _FakeOrderRepository(order ?? _buildOrder()),
        ),
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

  group('AdminOrderDetailsScreen preparation-time role gating', () {
    testWidgets('ADMIN sees the override control on an eligible order', (
      tester,
    ) async {
      await _pumpScreen(tester, role: 'ADMIN');

      expect(find.text('Preparation Time'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('CASHIER does NOT see the override control', (tester) async {
      await _pumpScreen(tester, role: 'CASHIER');

      expect(find.text('Preparation Time'), findsNothing);
    });

    testWidgets('ADMIN does not see the control on a non-editable status', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        role: 'ADMIN',
        order: _buildOrder(status: OrderStatus.pending),
      );

      expect(find.text('Preparation Time'), findsNothing);
    });
  });
}
