import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/driver/data/driver_location_permission_service.dart';
import 'package:kebda_zaman/features/driver/presentation/notifiers/driver_tracking_coordinator.dart';

/// A thin status strip shown above the driver shell's tab content whenever
/// tracking is anything other than fully stopped (no eligible order) or
/// actively sending — so the driver always has an honest, current answer to
/// "is my location actually going out right now", never just "is a
/// service/timer running".
class DriverTrackingStatusBanner extends ConsumerWidget {
  const DriverTrackingStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(driverTrackingStatusProvider);

    switch (status) {
      case DriverTrackingStatus.stopped:
      case DriverTrackingStatus.sendingUpdates:
        return const SizedBox.shrink();
      case DriverTrackingStatus.permissionRequired:
        return _Banner(
          color: KZ.error,
          icon: Icons.location_off_rounded,
          text: 'driver_app.tracking_permission_required'.tr(),
          actionLabel: 'driver_app.tracking_permission_action'.tr(),
          onAction: () => _requestPermission(context, ref),
        );
      case DriverTrackingStatus.acquiringGps:
        return _Banner(
          color: KZ.secondary,
          icon: Icons.gps_not_fixed_rounded,
          text: 'driver_app.tracking_acquiring_gps'.tr(),
        );
      case DriverTrackingStatus.offline:
        return _Banner(
          color: KZ.error,
          icon: Icons.cloud_off_rounded,
          text: 'driver_app.tracking_offline'.tr(),
        );
    }
  }

  Future<void> _requestPermission(BuildContext context, WidgetRef ref) async {
    final service = DriverLocationPermissionService();
    if (!await service.isLocationServiceEnabled()) {
      if (context.mounted) {
        _showMessage(context, 'driver_app.tracking_service_disabled'.tr());
      }
      return;
    }

    final proceed = context.mounted
        ? await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('driver_app.tracking_permission_dialog_title'.tr()),
              content: Text('driver_app.tracking_permission_dialog_body'.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    'driver_app.tracking_permission_dialog_not_now'.tr(),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    'driver_app.tracking_permission_dialog_allow'.tr(),
                  ),
                ),
              ],
            ),
          )
        : null;
    if (proceed != true) return;

    var status = await service.requestForegroundAccess();
    if (status == DriverLocationPermissionStatus.foregroundOnly) {
      // A second, OS-driven prompt for "Always" may or may not appear here
      // depending on platform/version — this call is a no-op wherever it
      // doesn't apply, never a forced second dialog.
      status = await service.requestBackgroundAccess();
    }

    if (status == DriverLocationPermissionStatus.deniedForever) {
      if (context.mounted) {
        _showMessage(
          context,
          'driver_app.tracking_permission_denied_forever'.tr(),
          actionLabel: 'driver_app.tracking_open_settings'.tr(),
          onAction: service.openAppSettings,
        );
      }
      return;
    }

    if (status == DriverLocationPermissionStatus.always ||
        status == DriverLocationPermissionStatus.foregroundOnly) {
      ref.read(driverTrackingCoordinatorProvider).onPermissionGranted();
    }
  }

  void _showMessage(
    BuildContext context,
    String text, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: KZ.bodySmall.copyWith(color: color)),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
