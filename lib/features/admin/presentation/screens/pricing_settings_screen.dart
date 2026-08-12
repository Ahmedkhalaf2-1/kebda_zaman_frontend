import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_settings_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_settings_sections.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

/// Orders & Operations group destination: tax rate, minimum order amount,
/// and currency — the order-economics fields every checkout total is
/// computed from. Owns only `taxRatePercent` / `minOrderAmount` / `currency`
/// on [RestaurantSettings] — saving here `copyWith`s just those fields onto
/// the freshly-loaded settings object, so the restaurant profile, working
/// hours, order-acceptance, and `deliveryFee` values are always preserved
/// untouched (see admin_settings_sections.dart). `deliveryFee` specifically
/// is never edited here: real delivery pricing is distance-based (Google
/// Maps zone quote via `POST /delivery/quote`), not this flat contract
/// field.
class PricingSettingsScreen extends ConsumerStatefulWidget {
  const PricingSettingsScreen({super.key});

  @override
  ConsumerState<PricingSettingsScreen> createState() =>
      _PricingSettingsScreenState();
}

class _PricingSettingsScreenState
    extends ConsumerState<PricingSettingsScreen> {
  late TextEditingController _taxRatePercentCtrl;
  late TextEditingController _minOrderAmountCtrl;
  late TextEditingController _currencyCtrl;

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    if (_initialized) {
      _taxRatePercentCtrl.dispose();
      _minOrderAmountCtrl.dispose();
      _currencyCtrl.dispose();
    }
    super.dispose();
  }

  void _initFields(RestaurantSettings settings) {
    if (_initialized) return;
    _taxRatePercentCtrl = TextEditingController(
      text: settings.taxRatePercent.toString(),
    );
    _minOrderAmountCtrl = TextEditingController(
      text: settings.minOrderAmount.toString(),
    );
    _currencyCtrl = TextEditingController(text: settings.currency);
    _initialized = true;
  }

  Future<void> _save(RestaurantSettings current) async {
    if (!hasValidPricingInputs(
      _taxRatePercentCtrl.text,
      _minOrderAmountCtrl.text,
      _currencyCtrl.text,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('admin_settings.invalid_pricing_error'.tr()),
            backgroundColor: KZ.error,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = current.copyWith(
        taxRatePercent: double.parse(_taxRatePercentCtrl.text.trim()),
        minOrderAmount: double.parse(_minOrderAmountCtrl.text.trim()),
        currency: _currencyCtrl.text.trim(),
      );
      await ref.read(adminSettingsProvider.notifier).updateSettings(updated);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('admin.settings_saved'.tr())));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('common.something_wrong'.tr()),
            backgroundColor: KZ.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(adminSettingsProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('nav.pricing_settings'.tr(), style: KZ.pageTitle),
      ),
      body: stateAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (e, st) => KZErrorState(
          message: 'common.something_wrong'.tr(),
          retryLabel: 'common.retry'.tr(),
          onRetry: () => ref.invalidate(adminSettingsProvider),
        ),
        data: (settings) {
          _initFields(settings);
          return AdminSettingsPricingSection(
            taxRatePercentCtrl: _taxRatePercentCtrl,
            minOrderAmountCtrl: _minOrderAmountCtrl,
            currencyCtrl: _currencyCtrl,
            isSaving: _isSaving,
            onSave: () => _save(settings),
          );
        },
      ),
    );
  }
}
