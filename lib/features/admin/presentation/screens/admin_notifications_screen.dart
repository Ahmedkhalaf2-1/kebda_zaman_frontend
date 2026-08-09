import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/notifications/notification_model.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/admin/domain/models/notification_campaign.dart';

final adminCampaignsProvider = FutureProvider<List<NotificationCampaign>>((
  ref,
) async {
  final repo = ref.read(adminNotificationRepositoryProvider);
  final res = await repo.getCampaigns();
  return res.fold((l) => throw l, (r) => r);
});

const double _kDesktopBreakpoint = 900;
const double _kMaxContentWidth = 1280;

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends ConsumerState<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _campaignNameCtrl = TextEditingController(text: 'Special Summer Offer');
  final _titleCtrl = TextEditingController(
    text: 'خصم 20% على جميع سندوتشات الكبدة! 🔥',
  );
  final _bodyCtrl = TextEditingController(
    text: 'اطلب دلوقتي من تطبيق كبدة زمان واستمتع بأقوى العروض والطعم الأصلي!',
  );
  final _imageUrlCtrl = TextEditingController();

  NotificationType _selectedType = NotificationType.offer;
  String _selectedAudience = 'All Users';
  String _selectedDestination = '/menu';
  bool _isScheduled = false;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 14, minute: 0);

  bool _isSubmitting = false;

  static const List<String> _targetAudiences = [
    'All Users',
    'Selected Users (Backend Required)',
    'Customer Segment: VIP (Backend Required)',
    'City: Cairo (Backend Required)',
    'Branch: Heliopolis (Backend Required)',
  ];

  String _audienceLabel(String value) {
    switch (value) {
      case 'All Users':
        return 'admin_notifications.audience_all'.tr();
      case 'Selected Users (Backend Required)':
        return 'admin_notifications.audience_selected_users'.tr();
      case 'Customer Segment: VIP (Backend Required)':
        return 'admin_notifications.audience_vip'.tr();
      case 'City: Cairo (Backend Required)':
        return 'admin_notifications.audience_city_cairo'.tr();
      case 'Branch: Heliopolis (Backend Required)':
        return 'admin_notifications.audience_branch_heliopolis'.tr();
      default:
        return value;
    }
  }

  List<String> get _destinationOptions {
    switch (_selectedType) {
      case NotificationType.promotion:
      case NotificationType.offer:
        return ['/offers', '/item/item_001', '/item/item_002'];
      case NotificationType.newProduct:
      case NotificationType.category:
        return ['/menu', '/item/item_001', '/item/item_003'];
      case NotificationType.orderCreated:
      case NotificationType.orderConfirmed:
      case NotificationType.orderPreparing:
      case NotificationType.orderReady:
      case NotificationType.orderOutForDelivery:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
        return ['/orders', '/orders/tracking/ord_1001'];
      case NotificationType.paymentSuccess:
      case NotificationType.paymentFailed:
        return ['/orders'];
      case NotificationType.general:
      case NotificationType.unknown:
        return ['/home', '/menu', '/profile'];
    }
  }

  void _submitCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final campaign = NotificationCampaign(
      id: '',
      campaignName: _campaignNameCtrl.text,
      title: _titleCtrl.text,
      body: _bodyCtrl.text,
      imageUrl: _imageUrlCtrl.text.trim().isNotEmpty
          ? _imageUrlCtrl.text.trim()
          : null,
      type: _selectedType,
      targetAudience: _selectedAudience,
      destinationRoute: _selectedDestination,
      status: _isScheduled ? CampaignStatus.scheduled : CampaignStatus.sent,
      isScheduled: _isScheduled,
      scheduledAt: _isScheduled
          ? DateTime(
              _scheduledDate.year,
              _scheduledDate.month,
              _scheduledDate.day,
              _scheduledTime.hour,
              _scheduledTime.minute,
            )
          : null,
    );

    final repo = ref.read(adminNotificationRepositoryProvider);
    final result = _isScheduled
        ? await repo.scheduleCampaign(campaign)
        : await repo.sendCampaign(campaign);

    setState(() => _isSubmitting = false);

    if (mounted) {
      result.fold(
        (err) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('common.something_wrong'.tr()),
            backgroundColor: KZ.error,
          ),
        ),
        (created) {
          ref.invalidate(adminCampaignsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isScheduled
                    ? 'admin_notifications.schedule_success'.tr(
                        namedArgs: {
                          'date': _scheduledDate.toString().split(' ')[0],
                        },
                      )
                    : 'admin_notifications.send_success'.tr(),
              ),
              backgroundColor: KZ.tertiary,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(adminCampaignsProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'admin_notifications.title'.tr(),
          style: KZ.pageTitle.copyWith(fontSize: 19),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: KZ.onSurfaceVariant),
            tooltip: 'home.retry'.tr(),
            onPressed: () => ref.invalidate(adminCampaignsProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KZ.screenPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > _kDesktopBreakpoint;
                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildForm(includeInlinePreview: false),
                          ),
                          const SizedBox(width: KZ.sp32),
                          Expanded(flex: 2, child: _buildLivePreviewCard()),
                        ],
                      );
                    }
                    return _buildForm(includeInlinePreview: true);
                  },
                ),
                const SizedBox(height: KZ.sp32),
                _buildCampaignHistorySection(campaignsAsync),
                const SizedBox(height: KZ.sp24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The whole composer, top-to-bottom as one deliberate flow: Campaign
  /// Details -> Content -> Audience -> Destination -> Schedule -> Review &
  /// Send. Sections are separated by spacing and a small heading, not by
  /// wrapping each one in its own card — only the phone-notification preview
  /// (a genuinely distinct visual object) keeps a card treatment.
  Widget _buildForm({required bool includeInlinePreview}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'admin_notifications.section_campaign_details'.tr()),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: _campaignNameCtrl,
            decoration: KZ.inputDecoration(
              label: 'admin_notifications.campaign_name'.tr(),
              prefixIcon: const Icon(
                Icons.campaign_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
            validator: (v) => v == null || v.isEmpty
                ? 'admin_notifications.campaign_name_required'.tr()
                : null,
          ),
          const SizedBox(height: KZ.sp14),
          DropdownButtonFormField<NotificationType>(
            value: _selectedType,
            isExpanded: true,
            decoration: KZ.inputDecoration(
              label: 'admin_notifications.notification_type'.tr(),
              prefixIcon: const Icon(
                Icons.category_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
            items: NotificationType.values
                .where((t) => t != NotificationType.unknown)
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(
                      t.toPayloadString().toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedType = val;
                  _selectedDestination = _destinationOptions.first;
                });
              }
            },
          ),

          const SizedBox(height: KZ.sp28),
          _SectionHeader(title: 'admin_notifications.section_content'.tr()),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: _titleCtrl,
            onChanged: (_) => setState(() {}),
            decoration: KZ.inputDecoration(
              label: 'admin_notifications.notification_title'.tr(),
              prefixIcon: const Icon(
                Icons.title_rounded,
                color: KZ.onSurfaceVariant,
              ),
            ),
            validator: (v) => v == null || v.isEmpty
                ? 'admin_notifications.notification_title_required'.tr()
                : null,
          ),
          const SizedBox(height: KZ.sp14),
          TextFormField(
            controller: _bodyCtrl,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: KZ.inputDecoration(
              label: 'admin_notifications.notification_body'.tr(),
              prefixIcon: const Icon(
                Icons.notes_rounded,
                color: KZ.onSurfaceVariant,
              ),
            ),
            validator: (v) => v == null || v.isEmpty
                ? 'admin_notifications.notification_body_required'.tr()
                : null,
          ),
          const SizedBox(height: KZ.sp14),
          TextFormField(
            controller: _imageUrlCtrl,
            onChanged: (_) => setState(() {}),
            decoration: KZ.inputDecoration(
              label: 'admin_notifications.optional_image_url'.tr(),
              prefixIcon: const Icon(
                Icons.image_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: KZ.sp28),
          _SectionHeader(
            title: 'admin_notifications.section_audience'.tr(),
            subtitle: 'admin_notifications.section_audience_sub'.tr(),
          ),
          const SizedBox(height: KZ.sp12),
          _AudienceSelector(
            options: _targetAudiences,
            selected: _selectedAudience,
            labelOf: _audienceLabel,
            onChanged: (val) => setState(() => _selectedAudience = val),
          ),

          const SizedBox(height: KZ.sp28),
          _SectionHeader(title: 'admin_notifications.section_destination'.tr()),
          const SizedBox(height: KZ.sp12),
          DropdownButtonFormField<String>(
            value: _destinationOptions.contains(_selectedDestination)
                ? _selectedDestination
                : _destinationOptions.first,
            isExpanded: true,
            decoration: KZ.inputDecoration(
              label: 'admin_notifications.destination_link'.tr(),
              prefixIcon: const Icon(
                Icons.link_rounded,
                color: KZ.onSurfaceVariant,
              ),
            ),
            items: _destinationOptions
                .map(
                  (opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(
                      opt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedDestination = val);
              }
            },
          ),

          const SizedBox(height: KZ.sp28),
          _SectionHeader(title: 'admin_notifications.section_schedule'.tr()),
          const SizedBox(height: KZ.sp12),
          KZ.toggleRow(
            label: 'admin_notifications.schedule_for_later'.tr(),
            value: _isScheduled,
            onChanged: (v) => setState(() => _isScheduled = v),
          ),
          if (_isScheduled) ...[
            const SizedBox(height: KZ.sp12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(_scheduledDate.toString().split(' ')[0]),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _scheduledDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _scheduledDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: KZ.sp8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time_rounded, size: 18),
                    label: Text(_scheduledTime.format(context)),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _scheduledTime,
                      );
                      if (picked != null) {
                        setState(() => _scheduledTime = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: KZ.sp28),
          _SectionHeader(title: 'admin_notifications.section_review_send'.tr()),
          const SizedBox(height: KZ.sp12),
          if (includeInlinePreview) ...[
            _buildLivePreviewCard(),
            const SizedBox(height: KZ.sp16),
          ],
          KZButton(
            label: _isScheduled
                ? 'admin_notifications.schedule_campaign'.tr()
                : 'admin_notifications.send_now'.tr(),
            icon: _isScheduled
                ? Icons.schedule_send_rounded
                : Icons.send_rounded,
            loading: _isSubmitting,
            fullWidth: true,
            onPressed: _submitCampaign,
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    return Container(
      padding: const EdgeInsets.all(KZ.sp20),
      decoration: BoxDecoration(
        color: KZ.onSurface,
        borderRadius: BorderRadius.circular(KZ.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone_iphone_rounded,
                color: Colors.white,
                size: KZ.iconAction,
              ),
              const SizedBox(width: KZ.sp8),
              Expanded(
                child: Text(
                  'admin_notifications.live_preview_title'.tr(),
                  style: KZ.sectionTitle.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: KZ.sp16),

          // Smartphone Notification Banner Simulation
          Container(
            padding: const EdgeInsets.all(KZ.sp14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: KZ.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: KZ.sp8),
                    Flexible(
                      child: Text(
                        'app_name'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: KZ.onSurface,
                        ),
                      ),
                    ),
                    const Text(
                      ' • الآن',
                      style: TextStyle(fontSize: 12, color: KZ.secondary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: KZ.primaryFixed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedType.toPayloadString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: KZ.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KZ.sp8),
                Text(
                  _titleCtrl.text.isNotEmpty
                      ? _titleCtrl.text
                      : 'admin_notifications.title_placeholder'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: KZ.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _bodyCtrl.text.isNotEmpty
                      ? _bodyCtrl.text
                      : 'admin_notifications.body_placeholder'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: KZ.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                if (_imageUrlCtrl.text.trim().isNotEmpty) ...[
                  const SizedBox(height: KZ.sp10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _imageUrlCtrl.text.trim(),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        height: 60,
                        color: KZ.surfaceContainer,
                        child: Center(
                          child: Text(
                            'admin_notifications.invalid_image_url'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: KZ.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: KZ.sp20),
          const Divider(color: Colors.white24),
          const SizedBox(height: KZ.sp12),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: KZ.primaryContainer,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'admin_notifications.route_target'.tr(
                    namedArgs: {'route': _selectedDestination},
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignHistorySection(
    AsyncValue<List<NotificationCampaign>> campaignsAsync,
  ) {
    return KZCard(
      padding: const EdgeInsets.all(KZ.sp20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'admin_notifications.history_title'.tr()),
          const SizedBox(height: KZ.sp16),
          campaignsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: KZ.primary),
            ),
            error: (err, st) => Text(
              'admin_notifications.load_error'.tr(),
              style: const TextStyle(color: KZ.error),
            ),
            data: (List<NotificationCampaign> campaigns) {
              if (campaigns.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(KZ.sp24),
                    child: Text(
                      'admin_notifications.no_history'.tr(),
                      style: const TextStyle(color: KZ.secondary),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text('admin_notifications.col_campaign'.tr()),
                    ),
                    DataColumn(
                      label: Text('admin_notifications.col_type'.tr()),
                    ),
                    DataColumn(
                      label: Text('admin_notifications.col_audience'.tr()),
                    ),
                    DataColumn(
                      label: Text('admin_notifications.col_status'.tr()),
                    ),
                    DataColumn(
                      label: Text('admin_notifications.col_sent'.tr()),
                    ),
                    DataColumn(
                      label: Text('admin_notifications.col_recipients'.tr()),
                    ),
                    DataColumn(
                      label: Text('admin_notifications.col_delivered'.tr()),
                    ),
                    DataColumn(
                      label: Text('admin_notifications.col_click_rate'.tr()),
                    ),
                  ],
                  rows: [
                    for (final NotificationCampaign c in campaigns)
                      DataRow(
                        cells: [
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.campaignName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  c.title,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: KZ.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(c.type.toPayloadString().toUpperCase()),
                          ),
                          DataCell(Text(_audienceLabel(c.targetAudience))),
                          DataCell(
                            KZStatusBadge(
                              label: c.status.label,
                              icon: c.status == CampaignStatus.sent
                                  ? Icons.check_circle_rounded
                                  : c.status == CampaignStatus.scheduled
                                  ? Icons.schedule_rounded
                                  : c.status == CampaignStatus.failed
                                  ? Icons.error_rounded
                                  : Icons.circle_outlined,
                              color: c.status == CampaignStatus.sent
                                  ? KZ.tertiary
                                  : c.status == CampaignStatus.scheduled
                                  ? Colors.blue
                                  : c.status == CampaignStatus.failed
                                  ? KZ.error
                                  : KZ.onSurfaceVariant,
                            ),
                          ),
                          DataCell(
                            Text(
                              c.isScheduled
                                  ? 'admin_notifications.scheduled_label'.tr(
                                      namedArgs: {
                                        'date':
                                            c.scheduledAt?.toString().split(
                                              '.',
                                            )[0] ??
                                            '-',
                                      },
                                    )
                                  : (c.sentAt?.toString().split('.')[0] ?? '-'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(Text('${c.totalRecipients}')),
                          DataCell(Text('${c.deliveredCount}')),
                          DataCell(
                            Text(
                              '${c.clickRate}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: KZ.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A section heading with a small leading accent bar and optional
/// supporting text — the same motif used across the rest of the redesigned
/// admin panel, so this reads as one deliberate step in a sequence rather
/// than a random label.
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: KZ.primary,
                borderRadius: BorderRadius.circular(KZ.radiusFull),
              ),
            ),
            const SizedBox(width: KZ.sp8),
            Expanded(
              child: Text(
                title,
                style: KZ.sectionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: KZ.sp16),
            child: Text(subtitle!, style: KZ.bodySmall),
          ),
        ],
      ],
    );
  }
}

/// Audience picker as a selectable list rather than a collapsed dropdown —
/// exactly one option is ever selected (radio semantics matching the
/// original `_selectedAudience` string field), so exactly one row ever gets
/// the red selected treatment; every other row stays a neutral surface.
/// Same option values, same permissiveness (every option remains tappable,
/// including the "(coming soon)" ones) as the dropdown it replaces.
class _AudienceSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final String Function(String) labelOf;
  final ValueChanged<String> onChanged;

  const _AudienceSelector({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in options) ...[
          _AudienceOption(
            label: labelOf(option),
            selected: option == selected,
            onTap: () => onChanged(option),
          ),
          if (option != options.last) const SizedBox(height: KZ.sp8),
        ],
      ],
    );
  }
}

class _AudienceOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AudienceOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.sp12,
            vertical: KZ.sp10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? KZ.primaryFixed.withValues(alpha: 0.35)
                : KZ.surface,
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            border: Border.all(
              color: selected
                  ? KZ.primary
                  : KZ.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? KZ.primary : KZ.outline,
                size: 20,
              ),
              const SizedBox(width: KZ.sp10),
              Expanded(
                child: Text(
                  label,
                  style: KZ.body.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
