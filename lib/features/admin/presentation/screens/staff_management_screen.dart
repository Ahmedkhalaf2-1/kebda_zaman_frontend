import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/admin/domain/models/staff_account.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/staff_notifier.dart';

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'staff.title'.tr(),
          style: const TextStyle(
            color: KZ.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: KZ.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showStaffForm(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text('staff.add_cashier'.tr()),
      ),
      body: staffAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'common.something_wrong'.tr(),
                style: const TextStyle(color: KZ.onSurface),
              ),
              const SizedBox(height: 12),
              KZButton(
                label: 'common.retry'.tr(),
                onPressed: () => ref.invalidate(staffProvider),
              ),
            ],
          ),
        ),
        data: (staffList) {
          if (staffList.isEmpty) {
            return Center(
              child: Text(
                'staff.empty'.tr(),
                style: const TextStyle(color: KZ.secondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: KZ.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (staff.isActive ? KZ.tertiary : KZ.error)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        staff.isActive
                            ? 'staff.active'.tr()
                            : 'staff.inactive'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: staff.isActive ? KZ.tertiary : KZ.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (staff.email != null)
                  Text(
                    staff.email!,
                    style: const TextStyle(fontSize: 13, color: KZ.secondary),
                  ),
                if (staff.phone != null)
                  Text(
                    staff.phone!,
                    style: const TextStyle(fontSize: 13, color: KZ.secondary),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: KZ.secondary),
          ),
          IconButton(
            onPressed: onToggleActive,
            tooltip: staff.isActive
                ? 'staff.deactivate'.tr()
                : 'staff.activate'.tr(),
            icon: Icon(
              staff.isActive
                  ? Icons.toggle_on_rounded
                  : Icons.toggle_off_outlined,
              color: staff.isActive ? KZ.tertiary : KZ.secondary,
              size: 28,
            ),
          ),
        ],
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
