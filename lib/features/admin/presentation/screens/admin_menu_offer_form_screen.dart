import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_settings_sections.dart'
    show AdminSettingsSectionHeading;
import 'package:kebda_zaman/features/admin/presentation/widgets/menu_offer_image_picker.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/menu_offer_item_picker_dialog.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/menu_admin_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/menu_offers_admin_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

const double _kFormMaxWidth = 640;

class AdminMenuOfferFormScreen extends ConsumerStatefulWidget {
  final MenuOffer? existingOffer;

  const AdminMenuOfferFormScreen({super.key, this.existingOffer});

  @override
  ConsumerState<AdminMenuOfferFormScreen> createState() =>
      _AdminMenuOfferFormScreenState();
}

class _AdminMenuOfferFormScreenState
    extends ConsumerState<AdminMenuOfferFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _sortOrderCtrl;

  String? _imageUrl;
  bool _imageUploading = false;

  String? _selectedItemId;
  String? _selectedItemName;
  String? _selectedItemImageUrl;
  double? _selectedItemPrice;
  bool? _selectedItemAvailable;
  String? _selectedItemCategoryName;

  bool _isActive = true;
  DateTime? _startAt;
  DateTime? _endAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingOffer;

    _titleCtrl = TextEditingController(text: existing?.title ?? '');
    _descCtrl = TextEditingController(text: existing?.description ?? '');
    _sortOrderCtrl = TextEditingController(
      text: (existing?.sortOrder ?? 0).toString(),
    );

    _imageUrl = existing?.imageUrl;
    _isActive = existing?.isActive ?? true;
    _startAt = existing?.startAt;
    _endAt = existing?.endAt;

    final linked = existing?.menuItem;
    _selectedItemId = existing?.menuItemId;
    _selectedItemName = linked?.name;
    _selectedItemImageUrl = linked?.imageUrl;
    _selectedItemPrice = linked?.basePrice;
    _selectedItemAvailable = linked?.isAvailable;
    if (linked?.categoryId != null) {
      final categories = ref.read(menuAdminProvider).value?.categories;
      if (categories != null) {
        for (final c in categories) {
          if (c.id == linked!.categoryId) {
            _selectedItemCategoryName = c.name;
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickItem() async {
    final picked = await showMenuOfferItemPickerDialog(context);
    if (picked == null || !mounted) return;

    String? categoryName;
    final categories = ref.read(menuAdminProvider).value?.categories ?? [];
    for (final c in categories) {
      if (c.id == picked.categoryId) {
        categoryName = c.name;
        break;
      }
    }

    setState(() {
      _selectedItemId = picked.id;
      _selectedItemName = picked.localizedName(context.locale.languageCode);
      _selectedItemImageUrl = picked.imageUrl;
      _selectedItemPrice = picked.basePrice;
      _selectedItemAvailable = picked.isAvailable;
      _selectedItemCategoryName = categoryName;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startAt : _endAt) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startAt = picked;
      } else {
        _endAt = picked;
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: KZ.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _save() async {
    if (_isSaving || _imageUploading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrl == null || _imageUrl!.isEmpty) {
      _showError('menu_offers.image_required'.tr());
      return;
    }
    if (_selectedItemId == null) {
      _showError('menu_offers.item_required'.tr());
      return;
    }
    if (_startAt != null && _endAt != null && _endAt!.isBefore(_startAt!)) {
      _showError('menu_offers.invalid_date_range'.tr());
      return;
    }

    setState(() => _isSaving = true);

    final sortOrder = int.tryParse(_sortOrderCtrl.text.trim()) ?? 0;
    final now = DateTime.now();

    final offer = MenuOffer(
      id: widget.existingOffer?.id ?? '',
      menuItemId: _selectedItemId!,
      imageUrl: _imageUrl!,
      title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      isActive: _isActive,
      startAt: _startAt,
      endAt: _endAt,
      sortOrder: sortOrder,
      createdAt: widget.existingOffer?.createdAt ?? now,
      updatedAt: now,
    );

    final repo = ref.read(adminMenuOfferRepositoryProvider);
    final res = widget.existingOffer == null
        ? await repo.createMenuOffer(offer)
        : await repo.updateMenuOffer(offer);

    if (!mounted) return;
    setState(() => _isSaving = false);

    res.fold(
      (failure) => _showError(failure.message),
      (_) {
        ref.invalidate(menuOffersAdminProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('menu_offers.save_success'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existingOffer == null;

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: KZ.formAppBar(
        context: context,
        title: isNew
            ? 'menu_offers.add_offer'.tr()
            : 'menu_offers.edit_offer'.tr(),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kFormMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(KZ.screenPadding),
              children: [
                AdminSettingsSectionHeading('menu_offers.image_section'.tr()),
                const SizedBox(height: KZ.sp12),
                MenuOfferImagePicker(
                  initialImageUrl: _imageUrl,
                  onUploaded: (url) => setState(() => _imageUrl = url),
                  onUploadingChanged: (uploading) =>
                      setState(() => _imageUploading = uploading),
                ),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading(
                  'menu_offers.linked_item_section'.tr(),
                ),
                const SizedBox(height: KZ.sp12),
                _buildItemSection(),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading(
                  'menu_offers.content_section'.tr(),
                ),
                const SizedBox(height: KZ.sp12),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: KZ.inputDecoration(
                    label: 'menu_offers.offer_title'.tr(),
                    hint: 'menu_offers.offer_title_hint'.tr(),
                    prefixIcon: const Icon(
                      Icons.title_rounded,
                      color: KZ.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: KZ.sp12),
                TextFormField(
                  controller: _descCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: KZ.inputDecoration(
                    label: 'menu_offers.offer_description'.tr(),
                    hint: 'menu_offers.offer_description_hint'.tr(),
                  ),
                ),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading(
                  'menu_offers.visibility_section'.tr(),
                ),
                const SizedBox(height: KZ.sp12),
                KZ.toggleRow(
                  label: 'menu_offers.active_toggle'.tr(),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading(
                  'menu_offers.schedule_section'.tr(),
                ),
                const SizedBox(height: 4),
                Text(
                  'menu_offers.schedule_hint'.tr(),
                  style: KZ.caption,
                ),
                const SizedBox(height: KZ.sp12),
                Row(
                  children: [
                    Expanded(
                      child: _OptionalDateField(
                        label: 'menu_offers.start_date'.tr(),
                        date: _startAt,
                        onTap: () => _pickDate(isStart: true),
                        onClear: _startAt == null
                            ? null
                            : () => setState(() => _startAt = null),
                      ),
                    ),
                    const SizedBox(width: KZ.sp12),
                    Expanded(
                      child: _OptionalDateField(
                        label: 'menu_offers.end_date'.tr(),
                        date: _endAt,
                        onTap: () => _pickDate(isStart: false),
                        onClear: _endAt == null
                            ? null
                            : () => setState(() => _endAt = null),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: KZ.sp28),
                AdminSettingsSectionHeading(
                  'menu_offers.display_section'.tr(),
                ),
                const SizedBox(height: KZ.sp12),
                TextFormField(
                  controller: _sortOrderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: KZ.inputDecoration(
                    label: 'menu_offers.sort_order'.tr(),
                    hint: 'menu_offers.sort_order_hint'.tr(),
                    prefixIcon: const Icon(
                      Icons.sort_rounded,
                      color: KZ.onSurfaceVariant,
                    ),
                  ),
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';
                    if (trimmed.isEmpty) return null;
                    return int.tryParse(trimmed) == null
                        ? 'menu_offers.sort_order_invalid'.tr()
                        : null;
                  },
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
              ? 'menu_offers.create_offer'.tr()
              : 'addresses.save_changes'.tr(),
          icon: isNew ? Icons.add_circle_outline_rounded : Icons.check_rounded,
          fullWidth: true,
          pill: true,
          // Disabled (not just visually) while a newly-picked image is still
          // uploading, per the required upload UX — Save must not be
          // reachable with a stale/empty imageUrl in flight.
          loading: _isSaving,
          onPressed: (_isSaving || _imageUploading) ? () {} : _save,
        ),
      ),
    );
  }

  Widget _buildItemSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KZ.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: _selectedItemId == null
          ? Row(
              children: [
                const Icon(
                  Icons.restaurant_menu_outlined,
                  color: KZ.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: KZ.sp10),
                Expanded(
                  child: Text(
                    'menu_offers.no_item_selected'.tr(),
                    style: const TextStyle(
                      color: KZ.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _pickItem,
                  child: Text('menu_offers.select_item'.tr()),
                ),
              ],
            )
          : Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(KZ.radiusSm),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child:
                        (_selectedItemImageUrl != null &&
                            _selectedItemImageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: _selectedItemImageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: KZ.surface,
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: KZ.onSurfaceVariant,
                                size: 18,
                              ),
                            ),
                          )
                        : Container(
                            color: KZ.surface,
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: KZ.onSurfaceVariant,
                              size: 18,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: KZ.sp10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedItemName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KZ.itemTitle,
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: KZ.sp8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (_selectedItemPrice != null)
                            Text(
                              formatCurrency(
                                _selectedItemPrice!,
                                locale: context.locale,
                              ),
                              style: KZ.bodySmall,
                            ),
                          if (_selectedItemCategoryName != null)
                            Text(
                              _selectedItemCategoryName!,
                              style: KZ.bodySmall.copyWith(
                                color: KZ.onSurfaceVariant,
                              ),
                            ),
                          if (_selectedItemAvailable == false)
                            Text(
                              'menu_offers.item_unavailable'.tr(),
                              style: const TextStyle(
                                color: KZ.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _pickItem,
                  child: Text('menu_offers.change_item'.tr()),
                ),
              ],
            ),
    );
  }
}

/// A tap-to-pick date field that can also be *cleared*, since start/end are
/// genuinely optional here (unlike Promo Codes' always-set validity dates).
class _OptionalDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _OptionalDateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
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
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onClear,
                ),
        ),
        child: Text(
          date != null ? formatShortDate(date!) : 'menu_offers.not_set'.tr(),
          style: date != null
              ? KZ.body
              : KZ.body.copyWith(color: KZ.onSurfaceVariant),
        ),
      ),
    );
  }
}
