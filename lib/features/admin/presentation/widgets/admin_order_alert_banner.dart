import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_alert_notifier.dart';

/// Persistent, shell-level banner for the new-order alert bell — visible on
/// every `/admin/*` screen the current role can reach (ADMIN/CASHIER), so
/// navigating between admin screens never counts as silencing it. Renders
/// nothing while there is nothing to say (no alerting orders and sound
/// isn't blocked).
class AdminOrderAlertBanner extends ConsumerWidget {
  const AdminOrderAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOrderAlertProvider);
    final notifier = ref.read(adminOrderAlertProvider.notifier);

    // Only worth prompting to unblock sound if the admin actually wants it
    // on — no point nagging about a browser restriction for a feature
    // they've explicitly turned off.
    if (state.soundBlocked && state.soundEnabled) {
      return _Banner(
        color: KZ.error,
        icon: Icons.volume_off_rounded,
        text: 'admin.order_sound_blocked_banner'.tr(),
        actionLabel: 'admin.order_sound_blocked_action'.tr(),
        onAction: () => notifier.retryBlockedSound(),
      );
    }

    if (state.alerting.isEmpty) return const SizedBox.shrink();

    final count = state.alerting.length;
    return _Banner(
      color: KZ.primary,
      icon: Icons.notifications_active_rounded,
      text: 'admin.new_orders_banner_title'.tr(namedArgs: {'count': '$count'}),
      actionLabel: 'admin.new_orders_banner_view'.tr(),
      onAction: () => context.go('/admin/orders'),
      secondaryLabel: 'admin.new_orders_banner_silence'.tr(),
      onSecondary: notifier.silenceCurrentAlerts,
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: KZ.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (secondaryLabel != null && onSecondary != null)
                TextButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 34),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
