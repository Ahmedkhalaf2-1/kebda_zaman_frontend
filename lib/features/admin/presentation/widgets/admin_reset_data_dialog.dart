import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';

/// One "X will be permanently deleted" line in the reset confirmation —
/// the caller (orders vs. customers screen) decides what its backend
/// summary's fields mean and how to label them; this dialog only ever
/// renders whatever lines it's handed.
class ResetCountLine {
  final String label;
  final int count;
  const ResetCountLine(this.label, this.count);
}

/// The literal word an admin must type to enable the destructive button —
/// deliberately not translated (matches the common "type DELETE/RESET to
/// confirm" convention) so it can't be typo'd via a translation mismatch.
const String _kResetConfirmWord = 'RESET';

/// Shows the shared two-step "reset data" flow: fetch + show a dry-run
/// count of what would be deleted, then require the admin's current
/// password (re-verified against the backend via a real login call — the
/// reset endpoints themselves don't check it) plus typing "RESET" before
/// enabling the destructive action. On success, calls [onSuccess] with the
/// backend's own final-counts summary so the caller can build its success
/// message and refresh its list.
Future<void> showAdminResetDataDialog<T>(
  BuildContext context, {
  required WidgetRef ref,
  required String title,
  required String warningBody,
  required Future<Result<T>> Function() fetchPreview,
  required Future<Result<T>> Function() performReset,
  required List<ResetCountLine> Function(T summary) toLines,
  required void Function(T finalSummary) onSuccess,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _AdminResetDataDialog<T>(
      ref: ref,
      title: title,
      warningBody: warningBody,
      fetchPreview: fetchPreview,
      performReset: performReset,
      toLines: toLines,
      onSuccess: onSuccess,
    ),
  );
}

class _AdminResetDataDialog<T> extends StatefulWidget {
  final WidgetRef ref;
  final String title;
  final String warningBody;
  final Future<Result<T>> Function() fetchPreview;
  final Future<Result<T>> Function() performReset;
  final List<ResetCountLine> Function(T summary) toLines;
  final void Function(T finalSummary) onSuccess;

  const _AdminResetDataDialog({
    required this.ref,
    required this.title,
    required this.warningBody,
    required this.fetchPreview,
    required this.performReset,
    required this.toLines,
    required this.onSuccess,
  });

  @override
  State<_AdminResetDataDialog<T>> createState() =>
      _AdminResetDataDialogState<T>();
}

class _AdminResetDataDialogState<T> extends State<_AdminResetDataDialog<T>> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;

  late final Future<Result<T>> _previewFuture;
  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _previewFuture = widget.fetchPreview();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Re-verifies the admin's password via a real backend call (the reset
  /// endpoints themselves don't check it) by re-issuing an admin login —
  /// confirmed safe by the backend team: it only adds a new refresh-token
  /// row and never revokes the admin's other active sessions/devices.
  Future<String?> _verifyPassword(String password) async {
    final email = widget.ref.read(authNotifierProvider).user?.email;
    if (email == null || email.isEmpty) {
      return 'admin_reset.verify_no_email'.tr();
    }
    final result = await widget.ref
        .read(authRepositoryProvider)
        .adminLogin(email, password);

    if (result.isSuccess) return null;

    final cause = result.failure.cause;
    final code = cause is ApiException ? cause.code : null;
    if (code == 'ACCOUNT_LOCKED') {
      return 'admin_reset.account_locked'.tr();
    }
    return 'admin_reset.wrong_password'.tr();
  }

  String _resetErrorMessage(Failure failure) {
    final cause = failure.cause;
    final code = cause is ApiException ? cause.code : null;
    if (code == 'RESET_DISABLED_IN_PRODUCTION') {
      return 'admin_reset.disabled_in_production'.tr();
    }
    if (code == 'FORBIDDEN') {
      return 'admin_reset.forbidden'.tr();
    }
    return failure.message;
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _submitError = null;
    });

    final passwordError = await _verifyPassword(_passwordCtrl.text);
    if (passwordError != null) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = passwordError;
      });
      return;
    }

    final result = await widget.performReset();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _submitting = false;
          _submitError = _resetErrorMessage(failure);
        });
      },
      (finalSummary) {
        Navigator.of(context).pop();
        widget.onSuccess(finalSummary);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_rounded, color: KZ.error),
          const SizedBox(width: KZ.sp8),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: FutureBuilder<Result<T>>(
          future: _previewFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: KZ.sp32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final result = snapshot.data!;
            return result.fold(
              (failure) => Text(
                failure.message,
                style: KZ.body.copyWith(color: KZ.error),
              ),
              (summary) => _buildConfirmForm(widget.toLines(summary)),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: Text('common.cancel'.tr()),
        ),
        FutureBuilder<Result<T>>(
          future: _previewFuture,
          builder: (context, snapshot) {
            final previewOk = snapshot.data?.isSuccess ?? false;
            final canSubmit =
                previewOk &&
                !_submitting &&
                _confirmCtrl.text.trim() == _kResetConfirmWord &&
                _passwordCtrl.text.isNotEmpty;
            return KZButton(
              label: 'admin_reset.confirm_button'.tr(),
              variant: KZButtonVariant.destructive,
              loading: _submitting,
              onPressed: canSubmit ? _submit : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfirmForm(List<ResetCountLine> lines) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.warningBody, style: KZ.body),
        const SizedBox(height: KZ.sp12),
        Container(
          padding: const EdgeInsets.all(KZ.sp12),
          decoration: BoxDecoration(
            color: KZ.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(KZ.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(line.label, style: KZ.bodySmall),
                      Text(
                        '${line.count}',
                        style: KZ.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: KZ.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: KZ.sp16),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: KZ.inputDecoration(
            label: 'admin_reset.password_label'.tr(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: KZ.sp12),
        TextField(
          controller: _confirmCtrl,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          decoration: KZ.inputDecoration(
            label: 'admin_reset.type_to_confirm'.tr(
              namedArgs: {'word': _kResetConfirmWord},
            ),
          ),
        ),
        if (_submitError != null) ...[
          const SizedBox(height: KZ.sp10),
          Text(_submitError!, style: KZ.bodySmall.copyWith(color: KZ.error)),
        ],
      ],
    );
  }
}
