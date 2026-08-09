import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/domain/models/staff_account.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/staff_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_person_card.dart';

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('staff.title'.tr(), style: KZ.pageTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: KZ.sp16),
            child: _AddCashierButton(
              onPressed: () => _showStaffForm(context, ref),
            ),
          ),
        ],
      ),
      body: staffAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (e, st) => KZErrorState(
          message: 'common.something_wrong'.tr(),
          retryLabel: 'common.retry'.tr(),
          onRetry: () => ref.invalidate(staffProvider),
        ),
        data: (staffList) {
          if (staffList.isEmpty) {
            return KZEmptyState(
              icon: Icons.badge_outlined,
              title: 'staff.empty'.tr(),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return _StaffCard(
                staff: staff,
                onEdit: () => _showStaffForm(context, ref, staff: staff),
                onToggleActive: () async {
                  final failure = await ref
                      .read(staffProvider.notifier)
                      .updateStaff(staff.id, isActive: !staff.isActive);
                  if (failure != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('staff.error_generic'.tr())),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showStaffForm(
    BuildContext context,
    WidgetRef ref, {
    StaffAccount? staff,
  }) {
    showDialog(
      context: context,
      builder: (context) => _StaffFormDialog(staff: staff),
    );
  }
}

/// The one dominant primary action for this screen — a compact filled
/// header button rather than a floating action button, matching the
/// pattern already established on the Menu Items screen.
class _AddCashierButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddCashierButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
        label: Text(
          'staff.add_cashier'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: KZ.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: KZ.sp14),
          textStyle: KZ.buttonLabel.copyWith(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
          ),
        ),
      ),
    );
  }
}

/// Priority fields: name, active/inactive state, contact. No per-record
/// "role" field exists on [StaffAccount] — every account managed here is
/// implicitly a cashier (the whole screen/dialog is scoped to that), so no
/// role badge was invented. Edit and the active-toggle are both per-record
/// management actions, not this screen's primary workflow — moved into one
/// compact overflow menu; the status pill itself stays always visible so
/// the state is still immediately readable without opening anything.
class _StaffCard extends StatelessWidget {
  final StaffAccount staff;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const _StaffCard({
    required this.staff,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final contactParts = [
      if (staff.email != null && staff.email!.isNotEmpty) staff.email!,
      if (staff.phone != null && staff.phone!.isNotEmpty) staff.phone!,
    ];

    return AdminPersonCard(
      name: staff.name,
      badges: [
        AdminStatusPill(
          label: staff.isActive ? 'staff.active'.tr() : 'staff.inactive'.tr(),
          color: staff.isActive ? KZ.tertiary : KZ.error,
        ),
      ],
      subtitle: contactParts.isEmpty ? null : contactParts.join('  ·  '),
      trailing: SizedBox(
        height: 32,
        width: 32,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: KZ.onSurfaceVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
          ),
          onSelected: (val) {
            if (val == 'edit') {
              onEdit();
            } else if (val == 'toggle') {
              onToggleActive();
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    color: KZ.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: KZ.sp8),
                  Text('common.edit'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    staff.isActive
                        ? Icons.toggle_off_outlined
                        : Icons.toggle_on_rounded,
                    color: staff.isActive ? KZ.error : KZ.tertiary,
                    size: 18,
                  ),
                  const SizedBox(width: KZ.sp8),
                  Text(
                    staff.isActive
                        ? 'staff.deactivate'.tr()
                        : 'staff.activate'.tr(),
                    style: TextStyle(
                      color: staff.isActive ? KZ.error : KZ.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffFormDialog extends ConsumerStatefulWidget {
  final StaffAccount? staff;

  const _StaffFormDialog({this.staff});

  @override
  ConsumerState<_StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends ConsumerState<_StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final _passwordCtrl = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.staff?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.staff?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.staff?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final notifier = ref.read(staffProvider.notifier);
    final failure = _isEditing
        ? await notifier.updateStaff(
            widget.staff!.id,
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            password: _passwordCtrl.text.trim().isNotEmpty
                ? _passwordCtrl.text.trim()
                : null,
          )
        : await notifier.createStaff(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isNotEmpty
                ? _phoneCtrl.text.trim()
                : null,
          );

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'staff.error_generic'.tr();
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'staff.edit_cashier'.tr() : 'staff.add_cashier'.tr(),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: 'staff.name'.tr()),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'staff.error_name'.tr()
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: 'staff.email'.tr()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'staff.error_email'.tr()
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(labelText: 'staff.phone'.tr()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'staff.password_optional'.tr()
                      : 'staff.password'.tr(),
                ),
                obscureText: true,
                validator: (v) {
                  if (_isEditing) return null;
                  if (v == null || v.length < 8) {
                    return 'staff.error_password'.tr();
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: KZ.error, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        KZButton(
          label: 'common.save'.tr(),
          loading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}
