import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/domain/models/driver_account.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/driver_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_page_header.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_person_card.dart';

class DriverManagementScreen extends ConsumerStatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  ConsumerState<DriverManagementScreen> createState() =>
      _DriverManagementScreenState();
}

class _DriverManagementScreenState
    extends ConsumerState<DriverManagementScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(driverListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(driverListProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            AdminPageHeader(
              title: 'driver.title'.tr(),
              trailingActions: [
                _AddDriverButton(
                  onPressed: () => _showDriverForm(context, ref),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: (v) =>
                    ref.read(driverListProvider.notifier).setQuery(v.trim()),
                decoration: InputDecoration(
                  hintText: 'driver.search_hint'.tr(),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(driverListProvider.notifier).setQuery('');
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _StatusFilterChip(
                    label: 'driver.filter_all'.tr(),
                    selected: listAsync.valueOrNull?.isActiveFilter == null,
                    onTap: () => ref
                        .read(driverListProvider.notifier)
                        .setActiveFilter(null),
                  ),
                  const SizedBox(width: KZ.sp8),
                  _StatusFilterChip(
                    label: 'driver.active'.tr(),
                    selected: listAsync.valueOrNull?.isActiveFilter == true,
                    onTap: () => ref
                        .read(driverListProvider.notifier)
                        .setActiveFilter(true),
                  ),
                  const SizedBox(width: KZ.sp8),
                  _StatusFilterChip(
                    label: 'driver.inactive'.tr(),
                    selected: listAsync.valueOrNull?.isActiveFilter == false,
                    onTap: () => ref
                        .read(driverListProvider.notifier)
                        .setActiveFilter(false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: listAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: KZ.primary),
                ),
                error: (e, st) => KZErrorState(
                  message: 'common.something_wrong'.tr(),
                  retryLabel: 'common.retry'.tr(),
                  onRetry: () => ref.invalidate(driverListProvider),
                ),
                data: (listState) {
                  if (listState.drivers.isEmpty) {
                    return KZEmptyState(
                      icon: Icons.two_wheeler_outlined,
                      title: 'driver.empty'.tr(),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount:
                        listState.drivers.length +
                        (listState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= listState.drivers.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: KZ.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      final driver = listState.drivers[index];
                      return _DriverCard(
                        driver: driver,
                        onEdit: () =>
                            _showDriverForm(context, ref, driver: driver),
                        onToggleActive: () =>
                            _confirmToggleActive(context, ref, driver),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverForm(
    BuildContext context,
    WidgetRef ref, {
    DriverAccount? driver,
  }) {
    showDialog(
      context: context,
      builder: (context) => _DriverFormDialog(driver: driver),
    );
  }

  Future<void> _confirmToggleActive(
    BuildContext context,
    WidgetRef ref,
    DriverAccount driver,
  ) async {
    final activating = !driver.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          activating ? 'driver.activate'.tr() : 'driver.deactivate'.tr(),
        ),
        content: Text(
          activating
              ? 'driver.confirm_activate'.tr(namedArgs: {'name': driver.name})
              : 'driver.confirm_deactivate'.tr(
                  namedArgs: {'name': driver.name},
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          KZButton(
            label: activating
                ? 'driver.activate'.tr()
                : 'driver.deactivate'.tr(),
            variant: activating
                ? KZButtonVariant.primary
                : KZButtonVariant.destructive,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final failure = await ref
        .read(driverListProvider.notifier)
        .updateDriver(driver.id, isActive: activating);
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('driver.error_generic'.tr())));
    }
  }
}

class _AddDriverButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddDriverButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
        label: Text(
          'driver.add_driver'.tr(),
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

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KZ.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? KZ.primary : KZ.surface,
          borderRadius: BorderRadius.circular(KZ.radiusFull),
          border: Border.all(color: selected ? KZ.primary : KZ.outlineVariant),
        ),
        child: Text(
          label,
          style: KZ.label.copyWith(
            color: selected ? Colors.white : KZ.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverAccount driver;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const _DriverCard({
    required this.driver,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final contactParts = [
      if (driver.email != null && driver.email!.isNotEmpty) driver.email!,
      if (driver.phone != null && driver.phone!.isNotEmpty) driver.phone!,
    ];

    return AdminPersonCard(
      name: driver.name,
      badges: [
        AdminStatusPill(
          label: driver.isActive
              ? 'driver.active'.tr()
              : 'driver.inactive'.tr(),
          color: driver.isActive ? KZ.tertiary : KZ.error,
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
                    driver.isActive
                        ? Icons.toggle_off_outlined
                        : Icons.toggle_on_rounded,
                    color: driver.isActive ? KZ.error : KZ.tertiary,
                    size: 18,
                  ),
                  const SizedBox(width: KZ.sp8),
                  Text(
                    driver.isActive
                        ? 'driver.deactivate'.tr()
                        : 'driver.activate'.tr(),
                    style: TextStyle(
                      color: driver.isActive ? KZ.error : KZ.tertiary,
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

class _DriverFormDialog extends ConsumerStatefulWidget {
  final DriverAccount? driver;

  const _DriverFormDialog({this.driver});

  @override
  ConsumerState<_DriverFormDialog> createState() => _DriverFormDialogState();
}

class _DriverFormDialogState extends ConsumerState<_DriverFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final _passwordCtrl = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.driver != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.driver?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.driver?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.driver?.phone ?? '');
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

    final notifier = ref.read(driverListProvider.notifier);
    final failure = _isEditing
        ? await notifier.updateDriver(
            widget.driver!.id,
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            password: _passwordCtrl.text.trim().isNotEmpty
                ? _passwordCtrl.text.trim()
                : null,
          )
        : await notifier.createDriver(
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
        _errorMessage = failure.message;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'driver.edit_driver'.tr() : 'driver.add_driver'.tr(),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: 'driver.name'.tr()),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'driver.error_name'.tr()
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: 'driver.email'.tr()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'driver.error_email'.tr()
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(labelText: 'driver.phone'.tr()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'driver.password_optional'.tr()
                      : 'driver.password'.tr(),
                ),
                obscureText: true,
                validator: (v) {
                  if (_isEditing) return null;
                  if (v == null || v.length < 8) {
                    return 'driver.error_password'.tr();
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
