import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/core/notifications/notification_model.dart';
import 'package:kebda_zaman/core/notifications/notification_navigation_service.dart';

Widget _screen(String key) => SizedBox(key: Key(key));

GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => _screen('home')),
      GoRoute(path: '/orders', builder: (context, state) => _screen('orders')),
      GoRoute(
        path: '/orders/tracking/:id',
        builder: (context, state) =>
            _screen('order-tracking-${state.pathParameters['id']}'),
      ),
      GoRoute(
        path: '/admin/order-notifications',
        builder: (context, state) => _screen('admin-notification-center'),
      ),
      GoRoute(
        path: '/admin/orders/:id',
        builder: (context, state) =>
            _screen('admin-order-details-${state.pathParameters['id']}'),
      ),
    ],
  );
}

Finder _screenFinder(String key) => find.byKey(Key(key));

AppNotificationPayload _newOrderPayload({String? orderId}) {
  return AppNotificationPayload(
    id: 'n1',
    type: NotificationType.unknown,
    title: 'New order received',
    body: 'Ahmed Hassan placed order KZ-1001',
    timestamp: DateTime(2026, 7, 25),
    rawData: {
      'type': 'NEW_ORDER',
      'notificationId': 'n1',
      'orderId': orderId ?? '',
      'orderNumber': 'KZ-1001',
    },
  );
}

void main() {
  // IMPORTANT: NotificationNavigationService.instance is a process-wide
  // singleton (matches the app's own architecture — it must be reachable
  // from plain, non-widget FCM callback code). Its `_pendingPayload`
  // buffering can only be observed once, before any router has ever been
  // attached, so that specific behavior is asserted in the very first test
  // below, before any other test calls setRouter.
  //
  // GoRouter only resolves navigation while pumped inside a widget tree, so
  // each test pumps a real MaterialApp.router and awaits pumpAndSettle()
  // after every handleNotificationTap call, then asserts on which screen
  // widget actually got built (more robust than reading
  // currentConfiguration, whose timing relative to the initial route parse
  // is less predictable in a bare test harness).
  group('NotificationNavigationService', () {
    testWidgets(
      'buffers a tap that arrives before the router is ready, and replays it exactly once',
      (tester) async {
        final payload = _newOrderPayload(orderId: 'order-buffered');

        // No router attached yet — must not throw, must buffer instead.
        expect(
          () => NotificationNavigationService.instance.handleNotificationTap(
            payload,
          ),
          returnsNormally,
        );

        final router = _buildTestRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        expect(_screenFinder('home'), findsOneWidget);

        NotificationNavigationService.instance.setRouter(router);
        await tester.pumpAndSettle();
        expect(
          _screenFinder('admin-order-details-order-buffered'),
          findsOneWidget,
        );

        // A second router attach (mirrors KebdaZamanApp.build() re-running
        // on every rebuild) must NOT replay the stale buffered payload again.
        final secondRouter = _buildTestRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: secondRouter));
        await tester.pumpAndSettle();

        NotificationNavigationService.instance.setRouter(secondRouter);
        await tester.pumpAndSettle();
        expect(_screenFinder('home'), findsOneWidget);
      },
    );

    testWidgets(
      'NEW_ORDER tap with a non-empty orderId opens Admin Order Details',
      (tester) async {
        final router = _buildTestRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        NotificationNavigationService.instance.setRouter(router);

        NotificationNavigationService.instance.handleNotificationTap(
          _newOrderPayload(orderId: 'order-42'),
        );
        await tester.pumpAndSettle();

        expect(_screenFinder('admin-order-details-order-42'), findsOneWidget);
      },
    );

    testWidgets(
      'NEW_ORDER tap with a missing/empty orderId opens the Admin Notification Center',
      (tester) async {
        final router = _buildTestRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        NotificationNavigationService.instance.setRouter(router);

        NotificationNavigationService.instance.handleNotificationTap(
          _newOrderPayload(),
        );
        await tester.pumpAndSettle();

        expect(_screenFinder('admin-notification-center'), findsOneWidget);
      },
    );

    testWidgets(
      'a non-NEW_ORDER message never triggers the admin routing branch',
      (tester) async {
        final router = _buildTestRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        NotificationNavigationService.instance.setRouter(router);

        final customerPayload = AppNotificationPayload(
          id: 'n2',
          type: NotificationType.orderCreated,
          title: 'Order placed',
          body: 'Your order was placed',
          entityId: 'order-99',
          timestamp: DateTime(2026, 7, 25),
          rawData: {'type': 'order_created', 'entityId': 'order-99'},
        );

        NotificationNavigationService.instance.handleNotificationTap(
          customerPayload,
        );
        await tester.pumpAndSettle();

        expect(_screenFinder('order-tracking-order-99'), findsOneWidget);
        expect(_screenFinder('admin-notification-center'), findsNothing);
        expect(_screenFinder('admin-order-details-order-99'), findsNothing);
      },
    );

    testWidgets(
      'tapping a NEW_ORDER notification for the order already being viewed does nothing',
      (tester) async {
        final router = _buildTestRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        NotificationNavigationService.instance.setRouter(router);

        NotificationNavigationService.instance.handleNotificationTap(
          _newOrderPayload(orderId: 'order-42'),
        );
        await tester.pumpAndSettle();
        expect(_screenFinder('admin-order-details-order-42'), findsOneWidget);
        // Diagnostic: confirm the exact signal the dedup guard reads
        // (`router.state.uri.path`) reflects the top of the match stack.
        expect(router.state.uri.path, '/admin/orders/order-42');

        // Same order tapped again — must not push a second, duplicate page.
        // (If it did, two widgets sharing Key('admin-order-details-order-42')
        // would coexist in the Navigator's page stack, which Flutter itself
        // rejects with a duplicate-GlobalKey-style error — so this call must
        // not throw either.)
        expect(
          () => NotificationNavigationService.instance.handleNotificationTap(
            _newOrderPayload(orderId: 'order-42'),
          ),
          returnsNormally,
        );
        await tester.pumpAndSettle();

        expect(_screenFinder('admin-order-details-order-42'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a NEW_ORDER notification for a different order while one is open navigates normally',
      (tester) async {
        final router = _buildTestRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        NotificationNavigationService.instance.setRouter(router);

        NotificationNavigationService.instance.handleNotificationTap(
          _newOrderPayload(orderId: 'order-42'),
        );
        await tester.pumpAndSettle();
        expect(_screenFinder('admin-order-details-order-42'), findsOneWidget);

        NotificationNavigationService.instance.handleNotificationTap(
          _newOrderPayload(orderId: 'order-77'),
        );
        await tester.pumpAndSettle();

        expect(_screenFinder('admin-order-details-order-77'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a NEW_ORDER notification while on an unrelated admin screen navigates normally',
      (tester) async {
        final router = _buildTestRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        NotificationNavigationService.instance.setRouter(router);

        router.go('/admin/order-notifications');
        await tester.pumpAndSettle();
        expect(_screenFinder('admin-notification-center'), findsOneWidget);

        NotificationNavigationService.instance.handleNotificationTap(
          _newOrderPayload(orderId: 'order-5'),
        );
        await tester.pumpAndSettle();

        expect(_screenFinder('admin-order-details-order-5'), findsOneWidget);
      },
    );
  });
}
