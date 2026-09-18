import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/services/admin_order_alert_sound_player.dart';
import 'package:kebda_zaman/features/admin/domain/models/order_notification.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/admin_order_notification_repository.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_alert_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_notification_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAdminOrderNotificationRepository
    implements AdminOrderNotificationRepository {
  List<OrderNotification> notifications = [];

  @override
  Future<Result<List<OrderNotification>>> getNotifications({
    int? page,
    int? limit,
  }) async => Success(List.of(notifications));

  @override
  Future<Result<int>> getUnreadCount() async =>
      Success(notifications.where((n) => !n.isRead).length);

  @override
  Future<Result<OrderNotification>> markAsRead(String id) async {
    notifications = [
      for (final n in notifications)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    return Success(notifications.firstWhere((n) => n.id == id));
  }

  @override
  Future<Result<int>> markAllAsRead() async {
    notifications = [for (final n in notifications) n.copyWith(isRead: true)];
    return Success(notifications.length);
  }

  @override
  Future<Result<void>> clearAll() async {
    notifications = [];
    return const Success(null);
  }
}

class FakeAlertSoundPlayer implements AdminAlertSoundPlayer {
  int playCount = 0;
  int stopCount = 0;
  bool blocked = false;

  @override
  Future<bool> playOnce({required double volume}) async {
    playCount++;
    return !blocked;
  }

  @override
  Future<void> stop() async => stopCount++;
}

OrderNotification _newOrderNotification(
  String id, {
  String? orderId,
  bool isRead = false,
}) => OrderNotification(
  id: id,
  type: kNewOrderNotificationType,
  title: 'New order',
  body: 'New order placed',
  orderId: orderId ?? 'order-$id',
  customerId: 'cust-$id',
  customerName: 'Customer $id',
  orderNumber: 'KZ-$id',
  totalAmount: 100,
  isRead: isRead,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

/// Builds the alert notifier via a fresh `NotifierProvider` in [container]
/// so a fake sound player can be injected — mirrors the driver tracking
/// coordinator tests' `_buildCoordinator` helper.
AdminOrderAlertNotifier _buildAlertNotifier(
  ProviderContainer container, {
  required AdminAlertSoundPlayer soundPlayer,
}) {
  final provider =
      NotifierProvider<AdminOrderAlertNotifier, AdminOrderAlertState>(
        () => AdminOrderAlertNotifier(soundPlayer: soundPlayer),
      );
  return container.read(provider.notifier);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAdminOrderNotificationRepository fakeRepo;
  late FakeAlertSoundPlayer fakeSound;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeRepo = FakeAdminOrderNotificationRepository();
    fakeSound = FakeAlertSoundPlayer();
    container = ProviderContainer(
      overrides: [
        adminOrderNotificationRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  group('initial backlog', () {
    test(
      'existing pending-order notifications at first load never ring',
      () async {
        fakeRepo.notifications = [
          _newOrderNotification('n1'),
          _newOrderNotification('n2'),
        ];
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();

        expect(notifier.state.alerting, isEmpty);
        expect(fakeSound.playCount, 0);
      },
    );
  });

  group('new-order detection', () {
    test(
      'one genuinely new order rings and appears in the banner queue',
      () async {
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();
        expect(fakeSound.playCount, 0); // nothing yet — empty backlog seeded

        fakeRepo.notifications = [_newOrderNotification('n1')];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();

        expect(notifier.state.alerting.length, 1);
        expect(notifier.state.alerting.first.notificationId, 'n1');
        expect(fakeSound.playCount, 1);
        expect(notifier.isRingingForTesting, isTrue);
      },
    );

    test('repeated delivery of the same event never double-alerts', () async {
      final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
      await pump();
      await pump();

      fakeRepo.notifications = [_newOrderNotification('n1')];
      await container.read(adminOrderNotificationProvider.notifier).refresh();
      await pump();
      expect(notifier.state.alerting.length, 1);
      final playsAfterFirst = fakeSound.playCount;

      // The same event delivered again (e.g. a duplicate FCM push, or a
      // poll tick re-fetching the same unread list) must not add a second
      // queue entry.
      await container.read(adminOrderNotificationProvider.notifier).refresh();
      await pump();
      await container.read(adminOrderNotificationProvider.notifier).refresh();
      await pump();

      expect(notifier.state.alerting.length, 1);
      // No *new arrival* occurred on the repeats, so no extra immediate
      // ring was triggered by them (the ongoing repeat timer is separate).
      expect(fakeSound.playCount, playsAfterFirst);
    });

    test('several new orders in one refresh all queue and ring once', () async {
      final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
      await pump();
      await pump();

      fakeRepo.notifications = [
        _newOrderNotification('n1'),
        _newOrderNotification('n2'),
        _newOrderNotification('n3'),
      ];
      await container.read(adminOrderNotificationProvider.notifier).refresh();
      await pump();

      expect(notifier.state.alerting.length, 3);
      expect(fakeSound.playCount, 1); // one immediate ring, not one per order
    });

    test('ordinary status updates (isRead already true) never ring', () async {
      final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
      await pump();
      await pump();

      fakeRepo.notifications = [_newOrderNotification('n1', isRead: true)];
      await container.read(adminOrderNotificationProvider.notifier).refresh();
      await pump();

      expect(notifier.state.alerting, isEmpty);
      expect(fakeSound.playCount, 0);
    });
  });

  group('acknowledgment', () {
    test(
      'silencing clears the queue and stops ringing without changing backend state',
      () async {
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();
        fakeRepo.notifications = [_newOrderNotification('n1')];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();
        expect(notifier.state.alerting, isNotEmpty);

        notifier.silenceCurrentAlerts();

        expect(notifier.state.alerting, isEmpty);
        expect(notifier.isRingingForTesting, isFalse);
        // Silencing is purely local — the backend notification is still
        // unread.
        expect(fakeRepo.notifications.first.isRead, isFalse);
      },
    );

    test('accepting an order acknowledges its alert', () async {
      final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
      await pump();
      await pump();
      fakeRepo.notifications = [
        _newOrderNotification('n1', orderId: 'order-1'),
      ];
      await container.read(adminOrderNotificationProvider.notifier).refresh();
      await pump();
      expect(notifier.state.alerting, isNotEmpty);

      notifier.acknowledgeOrder('order-1');

      expect(notifier.state.alerting, isEmpty);
      expect(notifier.isRingingForTesting, isFalse);
    });

    test(
      'if other unacknowledged orders remain, alerting continues for them',
      () async {
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();
        fakeRepo.notifications = [
          _newOrderNotification('n1', orderId: 'order-1'),
          _newOrderNotification('n2', orderId: 'order-2'),
        ];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();

        notifier.acknowledgeOrder('order-1');

        expect(notifier.state.alerting.length, 1);
        expect(notifier.state.alerting.first.orderId, 'order-2');
        expect(notifier.isRingingForTesting, isTrue);
      },
    );

    test(
      'a cancelled/no-longer-actionable order is removed from the queue too',
      () async {
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();
        fakeRepo.notifications = [
          _newOrderNotification('n1', orderId: 'order-1'),
        ];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();

        // Cancelling goes through the same acknowledgeOrder() call site as
        // accepting (order_management_notifier.dart) — same effect either way.
        notifier.acknowledgeOrder('order-1');

        expect(notifier.state.alerting, isEmpty);
      },
    );

    test(
      'a later new order rings again after previous alerts were silenced',
      () async {
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();
        fakeRepo.notifications = [_newOrderNotification('n1')];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();
        notifier.silenceCurrentAlerts();
        expect(notifier.state.alerting, isEmpty);
        final playsBeforeSecond = fakeSound.playCount;

        fakeRepo.notifications = [
          _newOrderNotification('n1'),
          _newOrderNotification('n2'),
        ];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();

        expect(notifier.state.alerting.length, 1);
        expect(notifier.state.alerting.first.notificationId, 'n2');
        expect(fakeSound.playCount, greaterThan(playsBeforeSecond));
      },
    );
  });

  group('reconnect', () {
    test(
      'a new order arriving on the first refresh after a gap (simulated reconnect) still triggers',
      () async {
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();

        // Simulate a dropped connection: several refreshes return nothing.
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();
        expect(notifier.state.alerting, isEmpty);

        // Reconnected — the next refresh now sees a genuinely new order.
        fakeRepo.notifications = [_newOrderNotification('n1')];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();

        expect(notifier.state.alerting.length, 1);
        expect(fakeSound.playCount, 1);
      },
    );
  });

  group('sound blocked (browser autoplay)', () {
    test(
      'a blocked playback attempt surfaces as blocked and stops auto-retrying',
      () async {
        fakeSound.blocked = true;
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();

        fakeRepo.notifications = [_newOrderNotification('n1')];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();

        expect(notifier.state.soundBlocked, isTrue);
        expect(notifier.isRingingForTesting, isFalse); // stopped, not looping
        final attemptsWhileBlocked = fakeSound.playCount;

        // No further silent attempts just from time passing / more refreshes
        // of the same unresolved queue.
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();
        expect(fakeSound.playCount, attemptsWhileBlocked);
      },
    );

    test(
      'retryBlockedSound (Enable order sound tap) resumes ringing on success',
      () async {
        fakeSound.blocked = true;
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();
        fakeRepo.notifications = [_newOrderNotification('n1')];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();
        expect(notifier.state.soundBlocked, isTrue);

        fakeSound.blocked = false;
        final started = await notifier.retryBlockedSound();

        expect(started, isTrue);
        expect(notifier.state.soundBlocked, isFalse);
        expect(notifier.isRingingForTesting, isTrue);
      },
    );
  });

  group('logout / reset', () {
    test(
      'reset stops playback and clears the queue and acknowledgements',
      () async {
        final notifier = _buildAlertNotifier(container, soundPlayer: fakeSound);
        await pump();
        await pump();
        fakeRepo.notifications = [_newOrderNotification('n1')];
        await container.read(adminOrderNotificationProvider.notifier).refresh();
        await pump();
        expect(notifier.state.alerting, isNotEmpty);

        notifier.reset();

        expect(notifier.state.alerting, isEmpty);
        expect(notifier.isRingingForTesting, isFalse);
        expect(fakeSound.stopCount, greaterThan(0));
      },
    );
  });
}
