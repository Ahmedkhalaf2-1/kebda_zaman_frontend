import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_settings_group.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_alert_notifier.dart';

/// New-order sound alert settings — enable/disable, volume, and a "Test
/// sound" preview. Routed at `/admin/orders/sound-alerts` (a path prefixed
/// with `/admin/orders`) so CASHIER, who is confined to that prefix, can
/// reach it exactly like ADMIN — this is a front-of-house device setting,
/// not an owner-only one.
class AdminOrderSoundSettingsScreen extends ConsumerWidget {
  const AdminOrderSoundSettingsScreen({super.key});

  Future<void> _handleTestSound(BuildContext context, WidgetRef ref) async {
    final started = await ref
        .read(adminOrderAlertProvider.notifier)
        .testSound();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          started
              ? 'admin.order_sound_test_playing'.tr()
              : 'admin.order_sound_test_blocked'.tr(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOrderAlertProvider);
    final notifier = ref.read(adminOrderAlertProvider.notifier);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'admin.order_sound_settings_title'.tr(),
          style: KZ.pageTitle.copyWith(fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KZ.sp16),
        children: [
          const KZSettingsGroupHeader('admin.order_sound_settings_title'),
          const SizedBox(height: KZ.sp8),
          KZSettingsGroup(
            rows: [
              KZSettingsSwitchRow(
                icon: Icons.notifications_active_rounded,
                title: 'admin.order_sound_enable_label'.tr(),
                subtitle: 'admin.order_sound_enable_subtitle'.tr(),
                value: state.soundEnabled,
                onChanged: notifier.setSoundEnabled,
              ),
              const KZSettingsDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.volume_up_rounded,
                      color: KZ.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'admin.order_sound_volume_label'.tr(),
                            style: KZ.labelLarge.copyWith(
                              fontSize: 15,
                              color: KZ.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Slider(
                            value: state.volume,
                            onChanged: state.soundEnabled
                                ? notifier.setVolume
                                : null,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: '${(state.volume * 100).round()}%',
                            activeColor: KZ.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KZ.sp24),
          KZButton(
            label: 'admin.order_sound_test_button'.tr(),
            icon: Icons.play_arrow_rounded,
            onPressed: () => _handleTestSound(context, ref),
            fullWidth: true,
          ),
          const SizedBox(height: KZ.sp12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'admin.order_sound_note'.tr(),
              style: KZ.caption.copyWith(color: KZ.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
