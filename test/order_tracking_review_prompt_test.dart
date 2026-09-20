import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/order_tracking_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/orders_reset_summary.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';
import 'package:kebda_zaman/features/shared/domain/models/review_comment_patch.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/review_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Covers the automatic post-delivery/pickup review prompt on
/// [OrderTrackingScreen]: it must be backend-eligibility-driven (never
/// inferred from local state alone), hidden for guests and non-reviewable
/// statuses, dismissible per-order without affecting backend eligibility or
/// the manual "Rate Order" entry point, and must navigate to the existing
/// `/orders/review/:id` screen rather than duplicating any review UI.
///
/// Uses PICKUP orders throughout so `_LiveTrackingSection` (delivery-only)
/// never renders and never needs a tracking-repository override — the
/// prompt itself is reviewable for both DELIVERY (delivered) and PICKUP
/// (pickedUp) orders per the app's existing `OrderStatus.isReviewable`.
class _FakeOrderRepository implements OrderRepository {
  final Order order;
  _FakeOrderRepository(this.order);

  @override
  Stream<Order> watchOrder(String id) => Stream.value(order);
  @override
  Future<Result<Order>> getOrderById(String id) => throw UnimplementedError();
  @override
  Future<Result<Order>> getAdminOrderById(String id) =>
      throw UnimplementedError();
  @override
  Future<Result<Order>> assignDriver(String orderId, String driverId) =>
      throw UnimplementedError();
  @override
  Future<Result<Order>> unassignDriver(String orderId) =>
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
  @override
  Future<Result<OrdersResetSummary>> previewResetOrders() =>
      throw UnimplementedError();
  @override
  Future<Result<OrdersResetSummary>> resetOrders() =>
      throw UnimplementedError();
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.currentUser});
  final User? currentUser;

  @override
  Future<Result<User?>> getCurrentUser() async => Success(currentUser);
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

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository(this.details);
  final OrderReviewDetails details;

  @override
  Future<Result<OrderReviewDetails>> getOrderReviews(String orderId) async =>
      Success(details);
  @override
  Future<Result<ItemReview>> createItemReview({
    required String orderItemId,
    required int rating,
    String? comment,
  }) => throw UnimplementedError();
  @override
  Future<Result<ItemReview>> updateItemReview(
    String reviewId, {
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  }) => throw UnimplementedError();
  @override
  Future<Result<OrderFeedback>> createOrderFeedback({
    required String orderId,
    required int rating,
    String? comment,
  }) => throw UnimplementedError();
  @override
  Future<Result<OrderFeedback>> updateOrderFeedback(
    String feedbackId, {
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  }) => throw UnimplementedError();
  @override
  Future<Result<List<AdminItemReview>>> getAdminItemReviews({
    DateTime? from,
    DateTime? to,
  }) => throw UnimplementedError();
  @override
  Future<Result<List<AdminOrderFeedback>>> getAdminOrderFeedback({
    DateTime? from,
    DateTime? to,
  }) => throw UnimplementedError();
  @override
  Future<Result<AdminReviewsSummary>> getAdminReviewsSummary({
    DateTime? from,
    DateTime? to,
  }) => throw UnimplementedError();
}

Order _order({
  OrderStatus status = OrderStatus.pickedUp,
  String id = 'order-1',
}) => Order(
  id: id,
  orderNumber: 'ORD-1',
  userId: 'user-1',
  items: const [],
  fulfillmentType: FulfillmentType.pickup,
  status: status,
  subtotal: 10,
  grandTotal: 10,
  placedAt: DateTime(2026, 7, 1),
);

OrderReviewDetails _reviewDetails({
  required String orderId,
  bool eligible = true,
  List<OrderReviewItem> items = const [],
  OrderFeedback? orderFeedback,
}) => OrderReviewDetails(
  orderId: orderId,
  orderStatus: 'PICKED_UP',
  eligible: eligible,
  items: items,
  orderFeedback: orderFeedback,
);

OrderReviewItem _unreviewedItem() => const OrderReviewItem(
  orderItemId: 'item-1',
  nameAr: 'صنف',
  nameEn: 'Item',
  quantity: 1,
  review: null,
);

OrderReviewItem _reviewedItem() => OrderReviewItem(
  orderItemId: 'item-1',
  nameAr: 'صنف',
  nameEn: 'Item',
  quantity: 1,
  review: ItemReview(
    id: 'review-1',
    orderItemId: 'item-1',
    rating: 5,
    createdAt: DateTime(2026, 7, 2),
    updatedAt: DateTime(2026, 7, 2),
  ),
);

OrderFeedback _orderFeedback() => OrderFeedback(
  id: 'feedback-1',
  orderId: 'order-1',
  rating: 5,
  createdAt: DateTime(2026, 7, 2),
  updatedAt: DateTime(2026, 7, 2),
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

User _testUser() => User(
  id: 'user-1',
  name: 'Ahmed',
  role: 'CUSTOMER',
  createdAt: DateTime(2026, 1, 1),
);

/// Builds and pumps the tree, returning the [ProviderContainer] so the
/// caller can drive [AuthNotifier.confirmRestoredSession] directly —
/// `AuthNotifier`'s cached-display load (from SharedPreferences alone)
/// deliberately never sets `isLoggedIn: true` (see its own doc comment);
/// only a confirmed session restore or a fresh login does, so that's the
/// only correct way to simulate "logged in" for a test.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required Order order,
  required OrderReviewDetails reviewDetails,
  User? loggedInUser,
}) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        _FakeAuthRepository(currentUser: loggedInUser),
      ),
      orderRepositoryProvider.overrideWithValue(_FakeOrderRepository(order)),
      reviewRepositoryProvider.overrideWithValue(
        _FakeReviewRepository(reviewDetails),
      ),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/orders/tracking/${order.id}',
    routes: [
      GoRoute(
        path: '/orders/tracking/:id',
        builder: (context, state) =>
            OrderTrackingScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/orders/review/:id',
        builder: (context, state) => Scaffold(
          body: Text('REVIEW_SCREEN_${state.pathParameters['id']}'),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        useOnlyLangCode: true,
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) => MaterialApp.router(
            routerConfig: router,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
          ),
        ),
      ),
    ),
  );
  await _settle(tester);

  if (loggedInUser != null) {
    await container
        .read(authNotifierProvider.notifier)
        .confirmRestoredSession();
    await _settle(tester);
  }

  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('automatic review prompt', () {
    testWidgets(
      'a DELIVERED/reviewable, eligible, unreviewed order shows the prompt',
      (tester) async {
        await _pump(
          tester,
          order: _order(status: OrderStatus.pickedUp),
          reviewDetails: _reviewDetails(
            orderId: 'order-1',
            items: [_unreviewedItem()],
          ),
          loggedInUser: _testUser(),
        );

        expect(find.text('How was your order?'), findsOneWidget);
        expect(find.text('Rate Order'), findsWidgets);
        expect(find.text('Not now'), findsOneWidget);
      },
    );

    testWidgets('a non-reviewable order status does not show the prompt', (
      tester,
    ) async {
      await _pump(
        tester,
        order: _order(status: OrderStatus.preparing),
        reviewDetails: _reviewDetails(
          orderId: 'order-1',
          items: [_unreviewedItem()],
        ),
        loggedInUser: _testUser(),
      );

      expect(find.text('How was your order?'), findsNothing);
    });

    testWidgets('a guest (not logged in) never sees the prompt', (
      tester,
    ) async {
      // loggedInUser omitted — default unauthenticated state.
      await _pump(
        tester,
        order: _order(status: OrderStatus.pickedUp),
        reviewDetails: _reviewDetails(
          orderId: 'order-1',
          items: [_unreviewedItem()],
        ),
      );

      expect(find.text('How was your order?'), findsNothing);
    });

    testWidgets(
      'a fully-reviewed order (all items + order feedback) does not show the prompt',
      (tester) async {
        await _pump(
          tester,
          order: _order(status: OrderStatus.pickedUp),
          reviewDetails: _reviewDetails(
            orderId: 'order-1',
            items: [_reviewedItem()],
            orderFeedback: _orderFeedback(),
          ),
          loggedInUser: _testUser(),
        );

        expect(find.text('How was your order?'), findsNothing);
      },
    );

    testWidgets(
      'a partially-reviewed order (items done, order feedback missing) still shows the prompt',
      (tester) async {
        await _pump(
          tester,
          order: _order(status: OrderStatus.pickedUp),
          reviewDetails: _reviewDetails(
            orderId: 'order-1',
            items: [_reviewedItem()],
            orderFeedback: null,
          ),
          loggedInUser: _testUser(),
        );

        expect(find.text('How was your order?'), findsOneWidget);
      },
    );

    testWidgets('the backend eligible:false flag hides the prompt', (
      tester,
    ) async {
      await _pump(
        tester,
        order: _order(status: OrderStatus.pickedUp),
        reviewDetails: _reviewDetails(
          orderId: 'order-1',
          eligible: false,
          items: [_unreviewedItem()],
        ),
        loggedInUser: _testUser(),
      );

      expect(find.text('How was your order?'), findsNothing);
    });

    testWidgets('a previously-dismissed order does not show the prompt again', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'kz_review_prompt_dismissed_order_ids': ['order-1'],
      });
      await _pump(
        tester,
        order: _order(status: OrderStatus.pickedUp),
        reviewDetails: _reviewDetails(
          orderId: 'order-1',
          items: [_unreviewedItem()],
        ),
        loggedInUser: _testUser(),
      );

      expect(find.text('How was your order?'), findsNothing);
    });

    testWidgets(
      'a dismissal recorded for one order does not suppress a different order\'s prompt',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'kz_review_prompt_dismissed_order_ids': ['some-other-order'],
        });
        await _pump(
          tester,
          order: _order(status: OrderStatus.pickedUp, id: 'order-1'),
          reviewDetails: _reviewDetails(
            orderId: 'order-1',
            items: [_unreviewedItem()],
          ),
          loggedInUser: _testUser(),
        );

        expect(find.text('How was your order?'), findsOneWidget);
      },
    );

    testWidgets('tapping "Not now" hides the prompt and persists the dismissal', (
      tester,
    ) async {
      await _pump(
        tester,
        order: _order(status: OrderStatus.pickedUp),
        reviewDetails: _reviewDetails(
          orderId: 'order-1',
          items: [_unreviewedItem()],
        ),
        loggedInUser: _testUser(),
      );

      expect(find.text('How was your order?'), findsOneWidget);

      await tester.tap(find.text('Not now'));
      await _settle(tester);

      expect(find.text('How was your order?'), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList('kz_review_prompt_dismissed_order_ids'),
        contains('order-1'),
      );
    });

    testWidgets('tapping "Rate Order" navigates to /orders/review/:id', (
      tester,
    ) async {
      await _pump(
        tester,
        order: _order(status: OrderStatus.pickedUp),
        reviewDetails: _reviewDetails(
          orderId: 'order-1',
          items: [_unreviewedItem()],
        ),
        loggedInUser: _testUser(),
      );

      await tester.tap(find.text('Rate Order').first);
      await _settle(tester);

      expect(find.text('REVIEW_SCREEN_order-1'), findsOneWidget);
    });
  });
}
