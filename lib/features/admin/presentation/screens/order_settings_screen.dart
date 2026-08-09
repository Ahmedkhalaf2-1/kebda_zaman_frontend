import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_settings_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_settings_sections.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

/// Orders & Operations group destination: the manual order-acceptance gate
/// plus the customer-facing closed message. Owns only `acceptingOrders` /
/// `closedMessageAr` / `closedMessageEn` on [RestaurantSettings] — saving
/// here `copyWith`s just those fields onto the freshly-loaded settings
/// object, so the restaurant profile and working hours values are always
/// preserved untouched (see admin_settings_sections.dart).
class OrderSettingsScreen extends ConsumerStatefulWidget {
  const OrderSettingsScreen({super.key});

  @override
  ConsumerState<OrderSettingsScreen> createState() =>
      _OrderSettingsScreenState();
}

class _OrderSettingsScreenState extends ConsumerState<OrderSettingsScreen> {
  late TextEditingController _closedMessageArCtrl;
  late TextEditingController _closedMessageEnCtrl;

  bool _acceptingOrders = true;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    if (_initialized) {
      _closedMessageArCtrl.dispose();
      _closedMessageEnCtrl.dispose();
    }
    super.dispose();
  }

  void _initFields(RestaurantSettings settings) {
    if (_initialized) return;
    _closedMessageArCtrl = TextEditingController(
      text: settings.closedMessageAr ?? '',
    );
    _closedMessageEnCtrl = TextEditingController(
      text: settings.closedMessageEn ?? '',
    );
    _acceptingOrders = settings.acceptingOrders;
    _initialized = true;
  }

  Future<void> _save(RestaurantSettings current, {bool? overrideAccepting}) async {
    setState(() => _isSaving = true);
    try {
      final updated = current.copyWith(
        acceptingOrders: overrideAccepting ?? _acceptingOrders,
        closedMessageAr: _closedMessageArCtrl.text.trim().isEmpty
            ? null
            : _closedMessageArCtrl.text.trim(),
        closedMessageEn: _closedMessageEnCtrl.text.trim().isEmpty
            ? null
            : _closedMessageEnCtrl.text.trim(),
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

  Future<void> _confirmAndSaveAcceptance(
    RestaurantSettings current,
    bool newValue,
  ) async {
    if (newValue == false) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('admin_settings.close_restaurant_title'.tr()),
          content: Text('admin_settings.close_restaurant_body'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: KZ.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('admin_settings.close_restaurant_confirm'.tr()),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => _acceptingOrders = newValue);
    await _save(current, overrideAccepting: newValue);
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
        title: Text('nav.order_settings'.tr(), style: KZ.pageTitle),
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
          return AdminSettingsAcceptanceSection(
            acceptingOrders: _acceptingOrders,
            closedMessageArCtrl: _closedMessageArCtrl,
            closedMessageEnCtrl: _closedMessageEnCtrl,
            isSaving: _isSaving,
            onToggle: (v) => _confirmAndSaveAcceptance(settings, v),
            onSaveMessages: () => _save(settings),
          );
        },
      ),
    );
  }
}
