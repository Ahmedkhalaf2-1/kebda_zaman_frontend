import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_settings_notifier.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _logoCtrl;
  late TextEditingController _deliveryFeeCtrl;

  // Loyalty Rules
  late TextEditingController _loyaltyEgpStepCtrl;
  late TextEditingController _loyaltyPointsPerStepCtrl;
  late TextEditingController _loyaltyMinPointsCtrl;
  late TextEditingController _loyaltyMaxDiscountCtrl;

  bool _isOpen = true;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _logoCtrl.dispose();
    _deliveryFeeCtrl.dispose();
    _loyaltyEgpStepCtrl.dispose();
    _loyaltyPointsPerStepCtrl.dispose();
    _loyaltyMinPointsCtrl.dispose();
    _loyaltyMaxDiscountCtrl.dispose();
    super.dispose();
  }

  void _initFields(settings) {
    if (_initialized) return;
    _nameCtrl = TextEditingController(text: settings.name);
    _logoCtrl = TextEditingController(text: settings.logoUrl);
    _deliveryFeeCtrl = TextEditingController(
      text: settings.deliveryFee.toString(),
    );
    _loyaltyEgpStepCtrl = TextEditingController(
      text: settings.loyaltyEgpStep.toStringAsFixed(0),
    );
    _loyaltyPointsPerStepCtrl = TextEditingController(
      text: settings.loyaltyPointsPerStep.toString(),
    );
    _loyaltyMinPointsCtrl = TextEditingController(
      text: settings.loyaltyMinRedemptionPoints.toString(),
    );
    _loyaltyMaxDiscountCtrl = TextEditingController(
      text: settings.loyaltyMaxDiscountFromPoints.toStringAsFixed(0),
    );
    _isOpen = settings.isOpen;
    _initialized = true;
  }

  void _save(settings) async {
    if (!_formKey.currentState!.validate()) return;

    final egpStep = double.tryParse(_loyaltyEgpStepCtrl.text) ?? 10.0;
    final pointsStep = int.tryParse(_loyaltyPointsPerStepCtrl.text) ?? 1;

    final updated = settings.copyWith(
      name: _nameCtrl.text,
      logoUrl: _logoCtrl.text,
      deliveryFee: double.tryParse(_deliveryFeeCtrl.text) ?? 15.0,
      loyaltyEgpStep: egpStep,
      loyaltyPointsPerStep: pointsStep,
      loyaltyEarnRatePerCurrencyUnit: egpStep > 0
          ? (pointsStep / egpStep)
          : 0.1,
      loyaltyMinRedemptionPoints:
          int.tryParse(_loyaltyMinPointsCtrl.text) ?? 100,
      loyaltyMaxDiscountFromPoints:
          double.tryParse(_loyaltyMaxDiscountCtrl.text) ?? 50.0,
      isOpen: _isOpen,
    );

    await ref.read(adminSettingsProvider.notifier).updateSettings(updated);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('admin.settings_saved'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(adminSettingsProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: AppBar(title: Text('admin.settings'.tr())),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (settings) {
          _initFields(settings);

          final currentEgp = double.tryParse(_loyaltyEgpStepCtrl.text) ?? 10.0;
          final currentPoints =
              int.tryParse(_loyaltyPointsPerStepCtrl.text) ?? 1;
          final sampleEarned = currentEgp > 0
              ? ((100 / currentEgp) * currentPoints).floor()
              : 10;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.screenPadding,
                vertical: KZ.sp20,
              ),
              children: [
                // ── General Settings ──────────────────────
                _sectionHeader('admin.general'.tr(), Icons.storefront_rounded),
                const SizedBox(height: KZ.sp12),
                _card(
                  children: [
                    // Open toggle
                    KZ.toggleRow(
                      label: 'admin.open_for_orders'.tr(),
                      value: _isOpen,
                      onChanged: (v) => setState(() => _isOpen = v),
                    ),
                    const SizedBox(height: KZ.sp12),
                    KZ.divider,
                    const SizedBox(height: KZ.sp12),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: KZ.inputDecoration(
                        label: 'admin.restaurant_name'.tr(),
                        prefixIcon: const Icon(
                          Icons.restaurant,
                          color: KZ.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: KZ.sp12),
                    TextFormField(
                      controller: _deliveryFeeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: KZ.inputDecoration(
                        label: 'admin.delivery_fee'.tr(),
                        suffixText: 'common.egp'.tr(),
                        prefixIcon: const Icon(
                          Icons.delivery_dining,
                          color: KZ.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KZ.sp24),

                // ── Loyalty Program ────────────────────────
                _sectionHeader(
                  'admin.loyalty_program'.tr(),
                  Icons.stars_rounded,
                ),
                const SizedBox(height: KZ.sp12),
                _card(
                  children: [
                    Text(
                      'admin.points_earning_rule'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: KZ.onSurface,
                      ),
                    ),
                    const SizedBox(height: KZ.sp12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _loyaltyEgpStepCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: KZ.inputDecoration(
                              label: 'admin.for_every_egp'.tr(),
                              suffixText: 'common.egp'.tr(),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: KZ.sp10),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: KZ.primary,
                            size: 20,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _loyaltyPointsPerStepCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: KZ.inputDecoration(
                              label: 'admin.earn_points'.tr(),
                              suffixText: 'common.pts'.tr(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KZ.sp12),

                    // Live calculation preview
                    Container(
                      padding: const EdgeInsets.all(KZ.sp12),
                      decoration: BoxDecoration(
                        color: KZ.primaryFixed.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(KZ.radiusMd),
                        border: Border.all(color: KZ.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: KZ.primary,
                            size: 18,
                          ),
                          const SizedBox(width: KZ.sp8),
                          Expanded(
                            child: Text(
                              'admin.spending_preview'.tr(
                                namedArgs: {'pts': '$sampleEarned'},
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5F1900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: KZ.sp16),
                    KZ.divider,
                    const SizedBox(height: KZ.sp16),

                    Text(
                      'admin.redemption_rules'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: KZ.onSurface,
                      ),
                    ),
                    const SizedBox(height: KZ.sp12),
                    TextFormField(
                      controller: _loyaltyMinPointsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: KZ.inputDecoration(
                        label: 'admin.min_points_redeem'.tr(),
                        prefixIcon: const Icon(
                          Icons.lock_clock,
                          color: KZ.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: KZ.sp12),
                    TextFormField(
                      controller: _loyaltyMaxDiscountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: KZ.inputDecoration(
                        label: 'admin.max_discount'.tr(),
                        prefixIcon: const Icon(
                          Icons.local_offer,
                          color: KZ.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KZ.sp32),

                KZButton(
                  label: 'admin.save_settings'.tr(),
                  icon: Icons.save_rounded,
                  fullWidth: true,
                  onPressed: () => _save(settings),
                ),
                const SizedBox(height: KZ.sp48),
              ],
            ),
          );
        },
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

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: KZ.primary, size: 20),
        const SizedBox(width: KZ.sp8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: KZ.onSurface,
          ),
        ),
      ],
    );
  }
}
