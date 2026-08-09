import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_settings_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_settings_sections.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

/// Orders & Operations group destination: the weekly open/close schedule.
/// Owns only `workingHours` on [RestaurantSettings] — saving here
/// `copyWith`s just that field onto the freshly-loaded settings object, so
/// the restaurant profile and order-acceptance values are always preserved
/// untouched (see admin_settings_sections.dart).
class WorkingHoursScreen extends ConsumerStatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  ConsumerState<WorkingHoursScreen> createState() =>
      _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends ConsumerState<WorkingHoursScreen> {
  List<DayWorkingHours> _workingHours = [];
  bool _initialized = false;
  bool _isSaving = false;

  void _initFields(RestaurantSettings settings) {
    if (_initialized) return;
    _workingHours = List.of(settings.workingHours);
    _initialized = true;
  }

  Future<void> _save(RestaurantSettings current) async {
    setState(() => _isSaving = true);
    try {
      final updated = current.copyWith(workingHours: _workingHours);
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
        title: Text('nav.working_hours'.tr(), style: KZ.pageTitle),
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
          return AdminSettingsHoursSection(
            workingHours: _workingHours,
            timezone: settings.timezone,
            isSaving: _isSaving,
            onChanged: (hours) => setState(() => _workingHours = hours),
            onSave: () => _save(settings),
          );
        },
      ),
    );
  }
}
