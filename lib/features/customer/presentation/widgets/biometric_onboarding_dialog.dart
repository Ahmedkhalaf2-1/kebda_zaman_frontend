import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/services/biometric_service.dart';
import 'package:kebda_zaman/core/services/biometric_preference_store.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';

/// Call right after a successful Signup or normal email/password Login (the
/// authenticated session must already be established) — shows a one-time
/// opt-in prompt offering to enable biometric login, if all of the
/// following hold: the device has enrolled biometrics, biometric login
/// isn't already enabled for this user, the user hasn't already been shown
/// (and dismissed/declined/failed) this prompt before, and this isn't a
/// guest session. A no-op otherwise. Never throws, never blocks entry into
/// the app on failure/cancellation.
Future<void> maybeShowBiometricOnboardingDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final user = ref.read(authNotifierProvider).user;
  if (user == null || user.isGuest) return;

  final biometricService = ref.read(biometricServiceProvider);
  if (!await biometricService.hasEnrolledBiometrics()) return;
  if (await BiometricPreferenceStore.isEnabledFor(user.id)) return;
  if (await BiometricPreferenceStore.hasSeenOnboardingFor(user.id)) return;

  // Marked "seen" before the dialog is even shown — this is a "don't ask
  // again on every login" flag, not a record of what the user chose, so it
  // must be set unconditionally rather than only on a particular button.
  await BiometricPreferenceStore.markOnboardingSeenFor(user.id);
  if (!context.mounted) return;

  final kind = await biometricService.availableKind();
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _BiometricOnboardingDialog(userId: user.id, kind: kind),
  );
}

class _BiometricOnboardingDialog extends ConsumerStatefulWidget {
  final String userId;
  final KZBiometricKind kind;

  const _BiometricOnboardingDialog({required this.userId, required this.kind});

  @override
  ConsumerState<_BiometricOnboardingDialog> createState() =>
      _BiometricOnboardingDialogState();
}

class _BiometricOnboardingDialogState
    extends ConsumerState<_BiometricOnboardingDialog> {
  bool _busy = false;

  Future<void> _handleEnable() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await ref
        .read(biometricServiceProvider)
        .authenticate(reasonKey: 'biometric.enable_reason'.tr());
    if (!mounted) return;

    if (result is BiometricAuthSuccess) {
      await BiometricPreferenceStore.enableFor(widget.userId);
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    // Failure/cancellation: preference stays disabled, user stays logged
    // in, entry into the app is never blocked — just close the prompt.
    setState(() => _busy = false);
    if (result is! BiometricAuthCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('biometric.enable_failed'.tr()),
          backgroundColor: KZ.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  IconData get _icon => switch (widget.kind) {
    KZBiometricKind.face => Icons.face_retouching_natural_rounded,
    _ => Icons.fingerprint_rounded,
  };

  String get _body => switch (widget.kind) {
    KZBiometricKind.face => 'biometric.onboarding_body_face'.tr(),
    KZBiometricKind.fingerprint => 'biometric.onboarding_body_fingerprint'.tr(),
    _ => 'biometric.onboarding_body_generic'.tr(),
  };

  @override
  Widget build(BuildContext context) {
    // Blocks the back gesture while a biometric check is in flight — the
    // barrier itself is already non-dismissible (barrierDismissible: false).
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        icon: Icon(_icon, color: KZ.primary, size: 32),
        title: Text(
          'biometric.onboarding_title'.tr(),
          textAlign: TextAlign.center,
        ),
        content: Text(_body, textAlign: TextAlign.center, style: KZ.body),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text('biometric.onboarding_not_now'.tr()),
          ),
          KZButton(
            label: 'biometric.onboarding_enable'.tr(),
            onPressed: _busy ? null : _handleEnable,
            loading: _busy,
            variant: KZButtonVariant.primary,
            pill: false,
          ),
        ],
      ),
    );
  }
}
