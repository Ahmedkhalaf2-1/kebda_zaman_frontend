import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';

/// Drives the full two-step "Delete Account" confirmation flow and returns
/// `true` only once the backend has confirmed deletion (204). Returns
/// `false` if the user cancels at any point, or if the request failed and
/// the session was preserved — the caller should only react (clear
/// providers, navigate away, show a success message) on `true`.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _DeleteAccountDialog(),
  );
  return result ?? false;
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  /// 1 = the initial warning, 2 = the final typed/checked confirmation.
  int _step = 1;
  bool _acknowledged = false;
  bool _submitting = false;

  Future<void> _handleDelete() async {
    // Guards against a double-tap racing ahead of the disabled-button
    // rebuild — the same pattern AuthNotifier.googleSignIn already uses.
    if (_submitting) return;
    setState(() => _submitting = true);

    final result = await ref
        .read(authNotifierProvider.notifier)
        .deleteAccount();
    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop(true);
      return;
    }

    final failure = result.failure;

    // A genuine auth rejection means the session is already being torn down
    // by the app's existing global expired-session handling (the Dio 401
    // interceptor's refresh-and-retry, and AuthNotifier.clearLocalSession
    // once that's exhausted) — showing a second, competing error here would
    // duplicate that flow rather than follow it. Just close.
    if (failure is AuthFailure) {
      Navigator.of(context).pop(false);
      return;
    }

    final code = failure.cause is ApiException
        ? (failure.cause as ApiException).code
        : null;

    final message = switch (code) {
      'ACTIVE_ORDER_EXISTS' => 'delete_account.error_active_order'.tr(),
      'FIREBASE_DELETE_FAILED' => 'delete_account.error_firebase'.tr(),
      // GUEST_NOT_ELIGIBLE is handled defensively — this UI is never shown
      // to guests in the first place (see ProfileScreen), so this is only
      // reachable if the backend disagrees with the client's guest check.
      'GUEST_NOT_ELIGIBLE' => 'delete_account.error_generic'.tr(),
      _ => 'delete_account.error_generic'.tr(),
    };

    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: KZ.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Blocks the back gesture/button and the barrier tap while a delete
    // request is actively in flight — the flow must not be dismissible
    // mid-submit.
    return PopScope(
      canPop: !_submitting,
      child: _step == 1
          ? _buildWarningStep(context)
          : _buildConfirmStep(context),
    );
  }

  Widget _buildWarningStep(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: KZ.error, size: 32),
      title: Text(
        'delete_account.warning_title'.tr(),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'delete_account.warning_body'.tr(),
        textAlign: TextAlign.center,
        style: KZ.body,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: () => setState(() => _step = 2),
          child: Text(
            'delete_account.warning_continue'.tr(),
            style: const TextStyle(
              color: KZ.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep(BuildContext context) {
    return AlertDialog(
      title: Text('delete_account.confirm_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('delete_account.confirm_body'.tr(), style: KZ.body),
          const SizedBox(height: KZ.sp16),
          InkWell(
            onTap: _submitting
                ? null
                : () => setState(() => _acknowledged = !_acknowledged),
            borderRadius: BorderRadius.circular(KZ.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: KZ.sp4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _acknowledged,
                      activeColor: KZ.error,
                      onChanged: _submitting
                          ? null
                          : (val) =>
                                setState(() => _acknowledged = val ?? false),
                    ),
                  ),
                  const SizedBox(width: KZ.sp12),
                  Expanded(
                    child: Text(
                      'delete_account.confirm_acknowledge'.tr(),
                      style: KZ.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text('common.cancel'.tr()),
        ),
        KZButton(
          label: 'delete_account.confirm_button'.tr(),
          onPressed: _acknowledged ? _handleDelete : null,
          loading: _submitting,
          variant: KZButtonVariant.destructive,
          pill: false,
        ),
      ],
    );
  }
}
