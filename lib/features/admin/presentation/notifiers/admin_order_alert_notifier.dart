import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/services/admin_order_alert_sound_player.dart';
import 'package:kebda_zaman/core/services/admin_order_sound_preference_store.dart';
import 'package:kebda_zaman/features/admin/domain/models/order_notification.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_notification_notifier.dart';

/// Wire value of [OrderNotification.type] for a new-order event — same
/// constant `notification_service.dart` checks for its FCM side effect.
const String kNewOrderNotificationType = 'NEW_ORDER';

/// One alerting order, carrying just enough for the banner — never the full
/// [OrderNotification] object, so this state doesn't accidentally grow a
/// second copy of notification-inbox data.
@immutable
class AlertingOrder {
  final String notificationId;
  final String orderId;
  final String orderNumber;
  final String customerName;
  final double totalAmount;

  const AlertingOrder({
    required this.notificationId,
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.totalAmount,
  });
}

@immutable
class AdminOrderAlertState {
  /// Currently unacknowledged new-order alerts, oldest first.
  final List<AlertingOrder> alerting;

  /// Set when the last playback attempt was blocked (Chrome's autoplay
  /// restriction, most commonly) — the UI should offer an explicit
  /// "Enable order sound" action rather than this notifier retrying on its
  /// own in a loop.
  final bool soundBlocked;

  final bool soundEnabled;
  final double volume;

  const AdminOrderAlertState({
    required this.alerting,
    required this.soundBlocked,
    required this.soundEnabled,
    required this.volume,
  });

  const AdminOrderAlertState.initial()
    : alerting = const [],
      soundBlocked = false,
      soundEnabled = true,
      volume = 1.0;

  AdminOrderAlertState copyWith({
    List<AlertingOrder>? alerting,
    bool? soundBlocked,
    bool? soundEnabled,
    double? volume,
  }) => AdminOrderAlertState(
    alerting: alerting ?? this.alerting,
    soundBlocked: soundBlocked ?? this.soundBlocked,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    volume: volume ?? this.volume,
  );
}

/// Session-scoped (not screen-scoped) coordinator for the admin new-order
/// bell. Deliberately a plain (non-`autoDispose`) [Notifier] — it must
/// survive navigating between admin screens, only ever reset by an explicit
/// [reset] call (wired to logout/account-switch/loss-of-admin-access from
/// `session_coordinator.dart`), never by a screen going out of view. Kept
/// alive for the whole admin session because `admin_shell.dart` watches it
/// continuously (same pattern as the driver app's tracking status banner).
///
/// Detection reuses the existing admin notification inbox
/// ([adminOrderNotificationProvider], `GET /admin/notifications`) as the
/// sole incoming-order source — this class adds no second polling/push
/// mechanism of its own; it only diffs each successive list (however it got
/// refreshed: the provider's own poll, an FCM-triggered invalidate, or a
/// manual pull-to-refresh) against notification ids already seen.
class AdminOrderAlertNotifier extends Notifier<AdminOrderAlertState> {
  AdminOrderAlertNotifier({AdminAlertSoundPlayer? soundPlayer})
    : _injectedSoundPlayer = soundPlayer;

  final AdminAlertSoundPlayer? _injectedSoundPlayer;
  late final AdminAlertSoundPlayer _soundPlayer =
      _injectedSoundPlayer ?? AudioplayersAdminAlertSoundPlayer();

  Timer? _ringTimer;
  final Set<String> _knownNotificationIds = {};
  final Set<String> _acknowledgedOrderIds = {};
  bool _seededInitialBacklog = false;

  static const Duration _ringGap = Duration(milliseconds: 600);
  // Matches the asset's own length (~2.3s) so the periodic re-ring never
  // overlaps the previous chime's tail.
  static const Duration _ringInterval = Duration(milliseconds: 2450 + 600);

  @override
  AdminOrderAlertState build() {
    _ringTimer?.cancel();
    _ringTimer = null;
    _knownNotificationIds.clear();
    _acknowledgedOrderIds.clear();
    _seededInitialBacklog = false;

    ref.onDispose(() {
      _ringTimer?.cancel();
      _ringTimer = null;
      unawaited(_soundPlayer.stop());
    });

    // Load the saved sound preference (or the documented default: enabled,
    // full app volume) without blocking the initial state.
    unawaited(_loadPreferences());

    ref.listen<AsyncValue<List<OrderNotification>>>(
      adminOrderNotificationProvider,
      (previous, next) => next.whenData(_onNotificationsUpdated),
      fireImmediately: true,
    );

    return const AdminOrderAlertState.initial();
  }

  Future<void> _loadPreferences() async {
    final enabled = await AdminOrderSoundPreferenceStore.isEnabled();
    final volume = await AdminOrderSoundPreferenceStore.getVolume();
    state = state.copyWith(soundEnabled: enabled, volume: volume);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await AdminOrderSoundPreferenceStore.setEnabled(enabled);
    if (!enabled) {
      _stopRinging();
    } else if (state.alerting.isNotEmpty) {
      _startRingingIfNeeded();
    }
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped);
    await AdminOrderSoundPreferenceStore.setVolume(clamped);
  }

  /// Settings screen's "Test sound" button — plays the bell once at the
  /// current volume so the admin can preview it while deciding whether to
  /// enable/adjust it. Also doubles as a browser-audio unlock: since this
  /// is a direct user tap, a success here clears [AdminOrderAlertState.
  /// soundBlocked] and resumes ringing for any orders still alerting.
  Future<bool> testSound() => _playFromUserGesture();

  /// The alert banner's "Enable order sound" action, shown only after a
  /// playback attempt was blocked (Chrome's autoplay restriction). Same
  /// underlying call as [testSound] — kept as a separate, clearly-named
  /// method so call sites read as what they are.
  Future<bool> retryBlockedSound() => _playFromUserGesture();

  Future<bool> _playFromUserGesture() async {
    final started = await _soundPlayer.playOnce(volume: state.volume);
    state = state.copyWith(soundBlocked: !started);
    if (started && state.alerting.isNotEmpty) {
      _startRingingIfNeeded();
    }
    return started;
  }

  void _onNotificationsUpdated(List<OrderNotification> notifications) {
    final newOrderNotifications = notifications
        .where((n) => n.type == kNewOrderNotificationType)
        .toList();

    if (!_seededInitialBacklog) {
      // First load: an existing backlog of pending orders is shown
      // elsewhere (Order Management's own list) already — never ring for
      // orders that were already sitting there before this admin session
      // started observing them.
      _seededInitialBacklog = true;
      for (final n in newOrderNotifications) {
        _knownNotificationIds.add(n.id);
      }
      return;
    }

    final freshlyArrived = <OrderNotification>[];
    for (final n in newOrderNotifications) {
      if (_knownNotificationIds.contains(n.id)) {
        continue; // already seen this exact notification id — dedup
      }
      _knownNotificationIds.add(n.id);
      if (n.isRead) continue; // already handled elsewhere before we saw it
      if (_acknowledgedOrderIds.contains(n.orderId)) {
        continue; // e.g. accepted before the list itself caught up
      }
      freshlyArrived.add(n);
    }

    // Reconcile the existing queue: drop anything that disappeared from the
    // list (cleared), became read (handled elsewhere), or was separately
    // acknowledged (accepted/cancelled) since the last update.
    final latestById = {for (final n in newOrderNotifications) n.id: n};
    final stillAlerting = state.alerting.where((a) {
      final match = latestById[a.notificationId];
      if (match == null) return false;
      if (match.isRead) return false;
      if (_acknowledgedOrderIds.contains(a.orderId)) return false;
      return true;
    }).toList();

    final updatedAlerting = [
      ...stillAlerting,
      ...freshlyArrived.map(_toAlertingOrder),
    ];

    state = state.copyWith(alerting: updatedAlerting);

    if (updatedAlerting.isEmpty) {
      _stopRinging();
    } else if (freshlyArrived.isNotEmpty) {
      // Only a genuinely new arrival (re)starts ringing here. Deliberately
      // NOT "or the timer isn't running" — that would silently retry a
      // previously blocked chime on every later refresh of the very same
      // still-unresolved backlog, which is exactly the "keep trying in a
      // loop" behavior this feature must never do. A blocked chime resumes
      // only via an explicit user gesture (`retryBlockedSound`/
      // `testSound`) or `setSoundEnabled(true)` after being off.
      _startRingingIfNeeded();
    }
  }

  AlertingOrder _toAlertingOrder(OrderNotification n) => AlertingOrder(
    notificationId: n.id,
    orderId: n.orderId,
    orderNumber: n.orderNumber,
    customerName: n.customerName,
    totalAmount: n.totalAmount,
  );

  void _startRingingIfNeeded() {
    if (!state.soundEnabled) return;
    _ringTimer?.cancel();
    _ringOnce();
    _ringTimer = Timer.periodic(_ringInterval, (_) => _ringOnce());
  }

  Future<void> _ringOnce() async {
    if (state.alerting.isEmpty || !state.soundEnabled) {
      _stopRinging();
      return;
    }
    final started = await _soundPlayer.playOnce(volume: state.volume);
    if (!started) {
      // Blocked (most likely a browser autoplay restriction) — surface it
      // and stop trying automatically; only an explicit user action
      // (testSound()/the "Enable order sound" banner button) tries again.
      state = state.copyWith(soundBlocked: true);
      _stopRinging();
    }
  }

  void _stopRinging() {
    _ringTimer?.cancel();
    _ringTimer = null;
  }

  /// Silences the currently alerting orders — a purely local UI action
  /// (the "Silence" banner button). Never touches backend read-state: an
  /// order silenced this way is still an unread `OrderNotification`
  /// server-side, and will alert again from scratch if this alert engine
  /// itself resets (e.g. a fresh login).
  void silenceCurrentAlerts() {
    for (final a in state.alerting) {
      _acknowledgedOrderIds.add(a.orderId);
    }
    state = state.copyWith(alerting: const []);
    _stopRinging();
  }

  /// Acknowledges one order's alert — called after a successful order
  /// status transition (accept -> CONFIRMED, or cancel -> CANCELLED) from
  /// `OrderManagementNotifier.updateOrderStatus`, so accepting/cancelling
  /// an order silences its own alert immediately without waiting for the
  /// next notification-list refresh to notice `isRead`/absence.
  void acknowledgeOrder(String orderId) {
    _acknowledgedOrderIds.add(orderId);
    if (state.alerting.any((a) => a.orderId == orderId)) {
      state = state.copyWith(
        alerting: state.alerting.where((a) => a.orderId != orderId).toList(),
      );
      if (state.alerting.isEmpty) _stopRinging();
    }
  }

  /// Full reset for logout / account switch / loss of admin access — stops
  /// playback and clears every bit of this session's local state so a
  /// newly (re)authenticated admin session starts from a genuine first
  /// load, never inheriting a previous account's alert queue or
  /// acknowledgements.
  void reset() {
    _stopRinging();
    unawaited(_soundPlayer.stop());
    _knownNotificationIds.clear();
    _acknowledgedOrderIds.clear();
    _seededInitialBacklog = false;
    state = state.copyWith(alerting: const [], soundBlocked: false);
  }

  @visibleForTesting
  bool get isRingingForTesting => _ringTimer != null;
}

final adminOrderAlertProvider =
    NotifierProvider<AdminOrderAlertNotifier, AdminOrderAlertState>(
      AdminOrderAlertNotifier.new,
    );
