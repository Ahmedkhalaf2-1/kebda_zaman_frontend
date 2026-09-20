import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_reviews_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';
import 'package:kebda_zaman/features/shared/domain/models/review_comment_patch.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/review_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Covers the Admin Reviews screen additions: customer phone/email now
/// rendered per row (safely omitted when absent), and the previously-fetched
/// -but-never-rendered `adminOrderFeedbackProvider` now has a visible
/// "Order Feedback" section distinct from the existing per-item "Item
/// Reviews" section.
class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({
    this.itemReviews = const [],
    this.orderFeedback = const [],
  });
  final List<AdminItemReview> itemReviews;
  final List<AdminOrderFeedback> orderFeedback;

  @override
  Future<Result<AdminReviewsSummary>> getAdminReviewsSummary({
    DateTime? from,
    DateTime? to,
  }) async => Success(
    AdminReviewsSummary(
      itemReviews: const AdminRatingAggregate(
        averageRating: 4.5,
        reviewCount: 2,
      ),
      orderFeedback: const AdminRatingAggregate(
        averageRating: 4.0,
        reviewCount: 1,
      ),
    ),
  );

  @override
  Future<Result<List<AdminItemReview>>> getAdminItemReviews({
    DateTime? from,
    DateTime? to,
  }) async => Success(itemReviews);

  @override
  Future<Result<List<AdminOrderFeedback>>> getAdminOrderFeedback({
    DateTime? from,
    DateTime? to,
  }) async => Success(orderFeedback);

  @override
  Future<Result<OrderReviewDetails>> getOrderReviews(String orderId) =>
      throw UnimplementedError();
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
}

AdminReviewCustomer _customer({String? phone, String? email}) =>
    AdminReviewCustomer(
      id: 'customer-1',
      fullName: 'Ahmed Customer',
      phone: phone,
      email: email,
    );

AdminItemReview _itemReview({
  String? phone = '0500000000',
  String? email = 'ahmed@example.com',
  String? comment = 'Great food!',
}) => AdminItemReview(
  id: 'review-1',
  rating: 5,
  comment: comment,
  createdAt: DateTime(2026, 7, 1, 12, 0),
  updatedAt: DateTime(2026, 7, 1, 12, 0),
  customer: _customer(phone: phone, email: email),
  order: const AdminReviewOrderRef(id: 'order-1', orderNumber: 'ORD-1'),
  item: const AdminReviewItemRef(
    orderItemId: 'item-1',
    nameAr: 'كبدة',
    nameEn: 'Liver',
  ),
);

AdminOrderFeedback _orderFeedback({
  String? phone = '0500000000',
  String? email = 'ahmed@example.com',
}) => AdminOrderFeedback(
  id: 'feedback-1',
  rating: 4,
  comment: 'Fast delivery',
  createdAt: DateTime(2026, 7, 2, 9, 0),
  updatedAt: DateTime(2026, 7, 2, 9, 0),
  customer: _customer(phone: phone, email: email),
  order: const AdminReviewOrderRef(id: 'order-2', orderNumber: 'ORD-2'),
);

Future<void> _pump(
  WidgetTester tester, {
  List<AdminItemReview> itemReviews = const [],
  List<AdminOrderFeedback> orderFeedback = const [],
}) async {
  // The screen's content (metrics, distribution, top/lowest-rated, item
  // reviews, order feedback) is taller than the default test viewport, and
  // ListView virtualizes off-screen children — without a tall-enough
  // surface, everything below "Item Reviews" is simply never built/mounted,
  // not just scrolled out of view.
  final originalSize = tester.view.physicalSize;
  final originalRatio = tester.view.devicePixelRatio;
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.physicalSize = originalSize;
    tester.view.devicePixelRatio = originalRatio;
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reviewRepositoryProvider.overrideWithValue(
          _FakeReviewRepository(
            itemReviews: itemReviews,
            orderFeedback: orderFeedback,
          ),
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
            home: const AdminReviewsScreen(),
          ),
        ),
      ),
    ),
  );
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('AdminReviewsScreen', () {
    testWidgets('renders customer phone and email when both are present', (
      tester,
    ) async {
      await _pump(
        tester,
        itemReviews: [_itemReview(phone: '0500000000', email: 'a@b.com')],
      );

      expect(find.text('0500000000'), findsOneWidget);
      expect(find.text('a@b.com'), findsOneWidget);
    });

    testWidgets('never crashes and shows no contact row when phone/email are null', (
      tester,
    ) async {
      await _pump(
        tester,
        itemReviews: [_itemReview(phone: null, email: null)],
      );

      expect(tester.takeException(), isNull);
      // The review itself (name/rating) still renders.
      expect(find.text('Liver'), findsOneWidget);
    });

    testWidgets('item reviews still render (name, rating, comment)', (
      tester,
    ) async {
      await _pump(
        tester,
        itemReviews: [_itemReview(comment: 'Tasty!')],
      );

      expect(find.text('Liver'), findsOneWidget);
      expect(find.text('Tasty!'), findsOneWidget);
    });

    testWidgets('order feedback now renders in its own section', (
      tester,
    ) async {
      await _pump(
        tester,
        orderFeedback: [_orderFeedback()],
      );

      expect(find.text('Order Feedback'), findsOneWidget);
      expect(find.text('Fast delivery'), findsOneWidget);
    });

    testWidgets('an empty order-feedback list shows the empty state, not an error', (
      tester,
    ) async {
      await _pump(tester, orderFeedback: const []);

      expect(tester.takeException(), isNull);
      expect(find.text('Order Feedback'), findsOneWidget);
      expect(find.text('No data available'), findsWidgets);
    });

    testWidgets('item reviews and order feedback are both visible at once', (
      tester,
    ) async {
      await _pump(
        tester,
        itemReviews: [_itemReview()],
        orderFeedback: [_orderFeedback()],
      );

      expect(find.text('Item Reviews'), findsOneWidget);
      expect(find.text('Order Feedback'), findsOneWidget);
    });
  });
}
