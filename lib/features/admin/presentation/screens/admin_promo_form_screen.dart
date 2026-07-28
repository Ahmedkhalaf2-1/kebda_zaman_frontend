import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/shared/domain/models/promo_code.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/offers_admin_notifier.dart';

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

  DiscountType _discountType = DiscountType.percentage;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.existingPromo?.code ?? '');
    _valueCtrl = TextEditingController(
      text: widget.existingPromo?.value.toString() ?? '',
    );
    _minOrderCtrl = TextEditingController(
      text: widget.existingPromo?.minOrderValue.toString() ?? '0',
    );

    _discountType =
        widget.existingPromo?.discountType ?? DiscountType.percentage;
    _isActive = widget.existingPromo?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _minOrderCtrl.dispose();
    super.dispose();
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
      startDate: widget.existingPromo?.startDate ?? DateTime.now(),
      endDate:
          widget.existingPromo?.endDate ??
          DateTime.now().add(const Duration(days: 30)),
      isActive: _isActive,
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
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(
        context: context,
        title: isNew
            ? 'form.add_promo_title'.tr()
            : 'form.edit_promo_title'.tr(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.screenPadding,
            vertical: KZ.sp20,
          ),
          children: [
            // ── Promo Code ──────────────────────────────
            _card(
              children: [
                _fieldLabel(
                  'form.promo_code'.tr(),
                  icon: Icons.confirmation_number_outlined,
                ),
                const SizedBox(height: KZ.sp8),
                TextFormField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: KZ.inputDecoration(
                    label: 'form.promo_code_hint'.tr(),
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
              ],
            ),
            const SizedBox(height: KZ.sp16),

            // ── Discount Settings ────────────────────────
            _card(
              children: [
                _fieldLabel(
                  'form.discount_settings'.tr(),
                  icon: Icons.percent_rounded,
                ),
                const SizedBox(height: KZ.sp12),
                DropdownButtonFormField<DiscountType>(
                  value: _discountType,
                  decoration: KZ.inputDecoration(
                    label: 'form.discount_type'.tr(),
                  ),
                  items: DiscountType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t == DiscountType.percentage
                                ? 'form.discount_percentage'.tr()
                                : 'form.discount_fixed'.tr(),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _discountType = v!),
                ),
                const SizedBox(height: KZ.sp12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
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
                    ),
                    const SizedBox(width: KZ.sp12),
                    Expanded(
                      child: TextFormField(
                        controller: _minOrderCtrl,
                        keyboardType: TextInputType.number,
                        decoration: KZ.inputDecoration(
                          label: 'form.min_order'.tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: KZ.sp16),

            // ── Visibility ───────────────────────────────
            _card(
              children: [
                _fieldLabel(
                  'form.visibility'.tr(),
                  icon: Icons.visibility_outlined,
                ),
                const SizedBox(height: KZ.sp12),
                KZ.toggleRow(
                  label: 'form.active_promo_toggle'.tr(),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
            const SizedBox(height: KZ.sp32),
          ],
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

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(KZ.sp16),
      decoration: KZ.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _fieldLabel(String text, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: KZ.primary, size: KZ.iconInline),
          const SizedBox(width: KZ.sp6),
        ],
        Text(text, style: KZ.labelLarge),
      ],
    );
  }
}
