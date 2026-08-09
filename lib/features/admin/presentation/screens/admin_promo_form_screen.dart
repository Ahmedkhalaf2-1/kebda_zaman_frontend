import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_settings_sections.dart'
    show AdminSettingsSectionHeading;
import 'package:kebda_zaman/features/shared/domain/models/promo_code.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/offers_admin_notifier.dart';

const double _kFormMaxWidth = 640;

class AdminPromoFormScreen extends ConsumerStatefulWidget {
  final PromoCode? existingPromo;

  const AdminPromoFormScreen({super.key, this.existingPromo});

  @override
  ConsumerState<AdminPromoFormScreen> createState() =>
      _AdminPromoFormScreenState();
}

class _AdminPromoFormScreenState extends ConsumerState<AdminPromoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _minOrderCtrl;
  // Blank means unlimited — the exact same null-means-unlimited convention
  // as the backend's `maxUsage`/`perUserLimit` fields (see promo_code.dart).
  late TextEditingController _usageLimitCtrl;
  late TextEditingController _perUserLimitCtrl;

  DiscountType _discountType = DiscountType.percentage;
  bool _isActive = true;
  bool _isSaving = false;

  late DateTime _startDate;
  late DateTime _endDate;

  bool get _isEditing => widget.existingPromo != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPromo;
    _codeCtrl = TextEditingController(text: existing?.code ?? '');
    _valueCtrl = TextEditingController(text: existing?.value.toString() ?? '');
    _minOrderCtrl = TextEditingController(
      text: existing?.minOrderValue.toString() ?? '0',
    );
    _usageLimitCtrl = TextEditingController(
      text: existing?.usageLimit?.toString() ?? '',
    );
    _perUserLimitCtrl = TextEditingController(
      text: existing?.perUserLimit?.toString() ?? '',
    );

    _discountType = existing?.discountType ?? DiscountType.percentage;
    _isActive = existing?.isActive ?? true;
    _startDate = existing?.startDate ?? DateTime.now();
    _endDate = existing?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _minOrderCtrl.dispose();
    _usageLimitCtrl.dispose();
    _perUserLimitCtrl.dispose();
    super.dispose();
  }

  /// Blank -> null (unlimited); otherwise a validated positive integer.
  /// Mirrors the backend's own `int>=1` constraint on `maxUsage`/
  /// `perUserLimit` so the admin gets fast feedback, without inventing any
  /// rule the backend doesn't already enforce.
  int? _parseLimit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  String? _validateLimitField(String? v, String invalidKey) {
    final trimmed = v?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final n = int.tryParse(trimmed);
    if (n == null || n < 1) return invalidKey.tr();
    return null;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final value = double.tryParse(_valueCtrl.text) ?? 0.0;
    final minOrderValue = double.tryParse(_minOrderCtrl.text) ?? 0.0;

    final promo = PromoCode(
      id: widget.existingPromo?.id ?? const Uuid().v4(),
      code: _codeCtrl.text.toUpperCase(),
      discountType: _discountType,
      value: value,
      minOrderValue: minOrderValue,
      startDate: _startDate,
      endDate: _endDate,
      isActive: _isActive,
      usageLimit: _parseLimit(_usageLimitCtrl.text),
      perUserLimit: _parseLimit(_perUserLimitCtrl.text),
      // Read-only/server-tracked — never sent in the create/update payload
      // (see ApiPromoRepository._buildPayload). Preserved here only so the
      // in-memory object stays accurate until the list re-fetches.
      usageCount: widget.existingPromo?.usageCount ?? 0,
    );

    final repo = ref.read(promoRepositoryProvider);
    final res = widget.existingPromo == null
        ? await repo.createPromo(promo)
        : await repo.updatePromo(promo);

    if (mounted) {
      setState(() => _isSaving = false);
      res.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: KZ.error,
            ),
          );
        },
        (_) {
          ref.invalidate(offersAdminProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('form.save_promo_success'.tr()),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existingPromo == null;
    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: KZ.formAppBar(
        context: context,
        title: isNew
            ? 'form.add_promo_title'.tr()
            : 'form.edit_promo_title'.tr(),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(KZ.screenPadding),
              children: [
                AdminSettingsSectionHeading('form.code_discount_section'.tr()),
                const SizedBox(height: KZ.sp12),
                TextFormField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: KZ.inputDecoration(
                    label: 'form.promo_code_hint'.tr(),
                    prefixIcon: const Icon(
                      Icons.confirmation_number_outlined,
                      color: KZ.onSurfaceVariant,
                    ),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 16,
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'form.promo_code_required'.tr()
                      : null,
                ),
                const SizedBox(height: KZ.sp12),
                DropdownButtonFormField<DiscountType>(
                  value: _discountType,
                  isExpanded: true,
                  decoration: KZ.inputDecoration(
                    label: 'form.discount_type'.tr(),
                    prefixIcon: const Icon(
                      Icons.percent_rounded,
                      color: KZ.onSurfaceVariant,
                    ),
                  ),
                  items: DiscountType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t == DiscountType.percentage
                                ? 'form.discount_percentage'.tr()
                                : 'form.discount_fixed'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _discountType = v!),
                ),
                const SizedBox(height: KZ.sp12),
                TextFormField(
                  controller: _valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: KZ.inputDecoration(
                    label: 'form.discount_value'.tr(),
                    suffixText: _discountType == DiscountType.percentage
                        ? '%'
                        : 'common.egp'.tr(),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'form.value_required'.tr()
                      : null,
                ),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading('form.conditions_section'.tr()),
                const SizedBox(height: KZ.sp12),
                TextFormField(
                  controller: _minOrderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: KZ.inputDecoration(
                    label: 'form.min_order'.tr(),
                    prefixIcon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: KZ.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading('form.usage_limits_section'.tr()),
                if (_isEditing) ...[
                  const SizedBox(height: 2),
                  Text(
                    'form.current_usage_note'.tr(
                      namedArgs: {
                        'count': '${widget.existingPromo!.usageCount}',
                      },
                    ),
                    style: KZ.caption,
                  ),
                ],
                const SizedBox(height: KZ.sp12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usageLimitCtrl,
                        keyboardType: TextInputType.number,
                        decoration: KZ.inputDecoration(
                          label: 'form.total_usage_limit'.tr(),
                          hint: 'offers.unlimited'.tr(),
                          prefixIcon: const Icon(
                            Icons.confirmation_number_outlined,
                            color: KZ.onSurfaceVariant,
                          ),
                        ),
                        validator: (v) => _validateLimitField(
                          v,
                          'form.total_usage_limit_invalid',
                        ),
                      ),
                    ),
                    const SizedBox(width: KZ.sp12),
                    Expanded(
                      child: TextFormField(
                        controller: _perUserLimitCtrl,
                        keyboardType: TextInputType.number,
                        decoration: KZ.inputDecoration(
                          label: 'form.per_user_limit'.tr(),
                          hint: 'offers.unlimited'.tr(),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: KZ.onSurfaceVariant,
                          ),
                        ),
                        validator: (v) => _validateLimitField(
                          v,
                          'form.per_user_limit_invalid',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KZ.sp6),
                Text('form.total_usage_limit_hint'.tr(), style: KZ.caption),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading('form.validity_section'.tr()),
                const SizedBox(height: KZ.sp12),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'form.start_date'.tr(),
                        date: _startDate,
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: KZ.sp12),
                    Expanded(
                      child: _DateField(
                        label: 'form.end_date'.tr(),
                        date: _endDate,
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading('form.visibility'.tr()),
                const SizedBox(height: KZ.sp12),
                KZ.toggleRow(
                  label: 'form.active_promo_toggle'.tr(),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: KZ.sp32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          KZ.screenPadding,
          KZ.sp16,
          KZ.screenPadding,
          KZ.sp20,
        ),
        decoration: BoxDecoration(
          color: KZ.surface,
          boxShadow: KZ.bottomBarShadow,
        ),
        child: KZButton(
          label: isNew
              ? 'form.create_promo'.tr()
              : 'addresses.save_changes'.tr(),
          icon: isNew ? Icons.add_circle_outline_rounded : Icons.check_rounded,
          fullWidth: true,
          pill: true,
          loading: _isSaving,
          onPressed: _isSaving ? () {} : _save,
        ),
      ),
    );
  }
}

/// A tap-to-pick date field styled like every other KZ text field. Uses
/// `InputDecorator` (not a real `TextFormField`) since there's no text being
/// edited — just a static display value — so no `TextEditingController`
/// needs creating/disposing for something that's never actually typed into.
class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KZ.radiusMd),
      child: InputDecorator(
        decoration: KZ.inputDecoration(
          label: label,
          prefixIcon: const Icon(
            Icons.calendar_today_rounded,
            color: KZ.onSurfaceVariant,
            size: 18,
          ),
        ),
        child: Text(formatShortDate(date), style: KZ.body),
      ),
    );
  }
}
