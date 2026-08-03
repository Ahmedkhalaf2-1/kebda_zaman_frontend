import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_image_picker.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_modifier_dialogs.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_recommendation_picker_dialog.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/menu_admin_notifier.dart';
import 'package:kebda_zaman/core/errors/errors.dart';

class AdminFoodFormScreen extends ConsumerStatefulWidget {
  final MenuItem? existingItem;

  const AdminFoodFormScreen({super.key, this.existingItem});

  @override
  ConsumerState<AdminFoodFormScreen> createState() =>
      _AdminFoodFormScreenState();
}

class _AdminFoodFormScreenState extends ConsumerState<AdminFoodFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _prepTimeCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _caloriesCtrl;
  late TextEditingController _compareAtPriceCtrl;

  String? _selectedCategory;
  bool _isAvailable = true;
  bool _isFeatured = false;
  bool _isBestSeller = false;
  MenuItemBadge? _selectedBadge;

  List<Category> _categories = [];
  bool _isLoading = true;

  List<ModifierGroup> _modifierGroups = [];
  // Ordered, backend order preserved on load; capped at 3 by the admin UI.
  List<MenuItem> _selectedRecommendations = [];
  XFile? _pickedImageFile; // actual picked image file (web-compatible)

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingItem?.name ?? '');
    _descCtrl = TextEditingController(
      text: widget.existingItem?.description ?? '',
    );
    _priceCtrl = TextEditingController(
      text: widget.existingItem?.basePrice.toString() ?? '',
    );
    _discountCtrl = TextEditingController(
      text: widget.existingItem?.discountPrice?.toString() ?? '',
    );
    _prepTimeCtrl = TextEditingController(
      text: widget.existingItem?.prepTimeMinutes.toString() ?? '15',
    );
    _imageCtrl = TextEditingController(
      text: widget.existingItem?.imageUrl ?? '',
    );
    _caloriesCtrl = TextEditingController(
      text: widget.existingItem?.calories?.toString() ?? '',
    );
    _compareAtPriceCtrl = TextEditingController(
      text: widget.existingItem?.compareAtPrice?.toString() ?? '',
    );

    _isAvailable = widget.existingItem?.isAvailable ?? true;
    _isFeatured = widget.existingItem?.isFeatured ?? false;
    _isBestSeller = widget.existingItem?.isBestSeller ?? false;
    _selectedBadge = widget.existingItem?.badge;

    _modifierGroups = List.from(widget.existingItem?.modifierGroups ?? []);
    _selectedRecommendations = List.from(
      widget.existingItem?.oftenOrderedWith ?? [],
    );

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final repo = ref.read(menuRepositoryProvider);
    final res = await repo.getAdminCategories();
    res.fold((l) {}, (cats) {
      setState(() {
        _categories = cats;
        _isLoading = false;

        if (widget.existingItem != null) {
          _selectedCategory = widget.existingItem!.categoryId;
        } else if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first.id;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _prepTimeCtrl.dispose();
    _imageCtrl.dispose();
    _caloriesCtrl.dispose();
    _compareAtPriceCtrl.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    setState(() {
      _isSaving = true;
    });

    final repo = ref.read(menuRepositoryProvider);

    if (_pickedImageFile != null) {
      final bytes = await _pickedImageFile!.readAsBytes();
      final result = await repo.uploadImage(bytes, _pickedImageFile!.name);

      if (result is Err) {
        setState(() {
          _isSaving = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((result as Err).error.message ?? 'Upload failed'),
              backgroundColor: KZ.error,
            ),
          );
        }
        return;
      }

      _imageCtrl.text = (result as Success<String>).value;
    }

    final basePrice = double.tryParse(_priceCtrl.text) ?? 0.0;
    final discountPrice = _discountCtrl.text.isNotEmpty
        ? double.tryParse(_discountCtrl.text)
        : null;
    final prepTime = int.tryParse(_prepTimeCtrl.text) ?? 15;
    final calories = _caloriesCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_caloriesCtrl.text.trim());
    final compareAtPrice = _compareAtPriceCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_compareAtPriceCtrl.text.trim());

    final item = MenuItem(
      id: widget.existingItem?.id ?? const Uuid().v4(),
      name: _nameCtrl.text,
      description: _descCtrl.text,
      basePrice: basePrice,
      discountPrice: discountPrice,
      imageUrl: _imageCtrl.text,
      categoryId: _selectedCategory!,
      isAvailable: _isAvailable,
      isFeatured: _isFeatured,
      isBestSeller: _isBestSeller,
      prepTimeMinutes: prepTime,
      modifierGroups: _modifierGroups,
      sortOrder: widget.existingItem?.sortOrder ?? 0,
      calories: calories,
      compareAtPrice: compareAtPrice,
      badge: _selectedBadge,
      oftenOrderedWith: _selectedRecommendations,
    );

    if (widget.existingItem == null) {
      await repo.createMenuItem(item);
    } else {
      await repo.updateMenuItem(item);
    }

    ref.invalidate(menuRepositoryProvider);
    ref.invalidate(menuAdminProvider);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('admin.item_saved'.tr())));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: KZ.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KZ.screenPadding,
                    vertical: KZ.sp16,
                  ),
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: KZ.sp20),
                    _buildBasicInfoCard(),
                    const SizedBox(height: KZ.sp20),
                    _buildVo3MetadataCard(context),
                    const SizedBox(height: KZ.sp20),
                    _buildCustomizationCard(context),
                    const SizedBox(height: KZ.sp20),
                    _buildRecommendationsCard(context),
                    const SizedBox(height: KZ.sp20),
                    _buildVisibilityCard(),
                    const SizedBox(height: KZ.sp32),
                  ],
                ),
              ),
            ),
            _buildStickyFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KZ.sp16,
        vertical: KZ.sp12,
      ),
      color: KZ.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: KZ.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: KZ.sp4),
                Flexible(
                  child: Text(
                    widget.existingItem == null
                        ? 'admin.add_item'.tr()
                        : 'admin.edit_item'.tr(),
                    style: KZ.headingStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: KZ.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return KZImagePickerWidget(
      currentImageUrl: _imageCtrl.text.trim().isNotEmpty
          ? _imageCtrl.text.trim()
          : null,
      onImageSelected: (xFile) {
        setState(() {
          _pickedImageFile = xFile;
          _imageCtrl.clear();
        });
      },
      onUrlChanged: (url) {
        setState(() {
          _imageCtrl.text = url;
          if (url.isNotEmpty) _pickedImageFile = null;
        });
      },
    );
  }

  Widget _buildPresetChip(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: KZ.outlineVariant.withValues(alpha: 0.5)),
        onPressed: () {
          setState(() {
            _imageCtrl.text = url;
            _pickedImageFile = null;
          });
        },
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: KZ.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: KZ.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'form.basic_info'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: KZ.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Product Name
          Text(
            'form.product_name'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KZ.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('product_name_field'),
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: 'form.product_name_hint'.tr(),
              filled: true,
              fillColor: KZ.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: KZ.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            validator: (v) => v == null || v.isEmpty
                ? 'form.product_name_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            'form.description'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KZ.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('product_description_field'),
            controller: _descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'form.description_hint'.tr(),
              filled: true,
              fillColor: KZ.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: KZ.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            validator: (v) => v == null || v.isEmpty
                ? 'form.description_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),

          // Grid: Category & Price
          Row(
            children: [
              // Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'form.category'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KZ.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: KZ.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: KZ.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      validator: (v) =>
                          v == null ? 'form.category_required'.tr() : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Base Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'form.base_price'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KZ.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('base_price_field'),
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            '£',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: KZ.primary,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: KZ.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: KZ.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'form.price_required'.tr()
                          : null,
                      // Compare-at price's validity depends on this value —
                      // re-run validation so a stale "invalid" error clears
                      // (or a new one appears) as soon as basePrice changes.
                      onChanged: (_) => _formKey.currentState?.validate(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVo3MetadataCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: KZ.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_outlined,
                color: KZ.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'admin_catalog.metadata_section'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: KZ.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calories
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'admin_catalog.calories'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KZ.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('calories_field'),
                      controller: _caloriesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'admin_catalog.calories_hint'.tr(),
                        suffixText: 'admin_catalog.calories_unit'.tr(),
                        filled: true,
                        fillColor: KZ.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: KZ.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final parsed = int.tryParse(v.trim());
                        if (parsed == null || parsed < 0) {
                          return 'admin_catalog.calories_invalid'.tr();
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Compare-at price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'admin_catalog.compare_at_price'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KZ.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('compare_at_price_field'),
                      controller: _compareAtPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'admin_catalog.compare_at_price_hint'.tr(),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            '£',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: KZ.primary,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: KZ.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: KZ.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null || parsed < 0) {
                          return 'admin_catalog.compare_at_price_invalid'.tr();
                        }
                        final basePrice =
                            double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
                        if (parsed <= basePrice) {
                          return 'admin_catalog.compare_at_price_invalid'.tr();
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Badge
          Text(
            'admin_catalog.badge'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KZ.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<MenuItemBadge?>(
            key: const Key('badge_dropdown'),
            value: _selectedBadge,
            decoration: InputDecoration(
              filled: true,
              fillColor: KZ.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: KZ.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text('admin_catalog.no_badge'.tr()),
              ),
              DropdownMenuItem(
                value: MenuItemBadge.bestseller,
                child: Text('admin_catalog.badge_bestseller'.tr()),
              ),
              DropdownMenuItem(
                value: MenuItemBadge.topRated,
                child: Text('admin_catalog.badge_top_rated'.tr()),
              ),
            ],
            onChanged: (v) => setState(() => _selectedBadge = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: KZ.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, color: KZ.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'form.customization'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: KZ.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'form.customization_sub'.tr(),
            style: const TextStyle(fontSize: 12, color: KZ.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // List of Modifier Groups
          if (_modifierGroups.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KZ.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: KZ.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.style_outlined,
                    color: Colors.grey,
                    size: 32,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'form.no_modifiers'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: KZ.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'form.no_modifiers_sub'.tr(),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ..._modifierGroups.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KZ.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: KZ.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: KZ.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'form.group_num'.tr(
                                  namedArgs: {'num': '${index + 1}'},
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: KZ.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              group.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: KZ.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: group.isRequired
                                    ? KZ.primaryFixed
                                    : const Color(0xFFE2DFE0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                group.isRequired
                                    ? 'form.required_badge'.tr()
                                    : 'form.optional_badge'.tr(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: group.isRequired
                                      ? KZ.primary
                                      : KZ.secondary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: KZ.primary,
                              ),
                              onPressed: () async {
                                final edited = await showModifierGroupDialog(
                                  context,
                                  existingGroup: group,
                                );
                                if (edited != null) {
                                  setState(
                                    () => _modifierGroups[index] = edited,
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () => setState(
                                () => _modifierGroups.removeAt(index),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Options Chips List
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: group.options.map((opt) {
                        final priceStr = opt.priceModifier > 0
                            ? ' (+${formatCurrency(opt.priceModifier, locale: context.locale)})'
                            : ' (${'form.free'.tr()})';
                        return Chip(
                          avatar: Icon(
                            opt.priceModifier > 0
                                ? Icons.add_circle
                                : Icons.check_circle,
                            size: 16,
                            color: KZ.primary,
                          ),
                          label: Text('${opt.name}$priceStr'),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: KZ.onSurface,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: KZ.outlineVariant.withValues(alpha: 0.6),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final group = await showModifierGroupDialog(context);
              if (group != null) {
                setState(() => _modifierGroups.add(group));
              }
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              foregroundColor: KZ.primary,
              side: const BorderSide(color: KZ.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            label: Text(
              'form.add_modifier'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addRecommendation() async {
    if (_selectedRecommendations.length >= 3) return;

    // Await the future rather than reading current state directly: the
    // provider may still be loading if this form was opened before anything
    // else in the tree watched it (e.g. deep-linked straight to Add Item).
    final adminData = await ref.read(menuAdminProvider.future);
    if (!mounted) return;
    final availableItems = adminData.items;
    final categories = adminData.categories;

    final excludeIds = <String>{
      if (widget.existingItem != null) widget.existingItem!.id,
      ..._selectedRecommendations.map((r) => r.id),
    }.toList();

    final picked = await showRecommendationPickerDialog(
      context,
      availableItems: availableItems,
      excludeIds: excludeIds,
      categories: categories,
    );

    if (picked != null) {
      setState(() => _selectedRecommendations.add(picked));
    }
  }

  void _removeRecommendation(int index) {
    setState(() => _selectedRecommendations.removeAt(index));
  }

  void _moveRecommendation(int index, int delta) {
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= _selectedRecommendations.length) return;
    setState(() {
      final item = _selectedRecommendations.removeAt(index);
      _selectedRecommendations.insert(newIndex, item);
    });
  }

  Widget _buildRecommendationsCard(BuildContext context) {
    final languageCode = context.locale.languageCode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: KZ.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.recommend_outlined, color: KZ.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'admin_catalog.recommendations'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: KZ.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_selectedRecommendations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KZ.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: KZ.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'admin_catalog.no_recommendations'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: KZ.onSurfaceVariant,
                ),
              ),
            )
          else
            ..._selectedRecommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final rec = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: KZ.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: KZ.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        rec.localizedName(languageCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KZ.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                      tooltip: 'admin_catalog.move_up'.tr(),
                      onPressed: index == 0
                          ? null
                          : () => _moveRecommendation(index, -1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                      tooltip: 'admin_catalog.move_down'.tr(),
                      onPressed: index == _selectedRecommendations.length - 1
                          ? null
                          : () => _moveRecommendation(index, 1),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                      tooltip: 'admin_catalog.remove_recommendation'.tr(),
                      onPressed: () => _removeRecommendation(index),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 4),
          if (_selectedRecommendations.length >= 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'admin_catalog.max_recommendations'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: KZ.onSurfaceVariant,
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: _selectedRecommendations.length >= 3
                ? null
                : _addRecommendation,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              foregroundColor: KZ.primary,
              side: const BorderSide(color: KZ.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            label: Text(
              'admin_catalog.search_recommendations'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: KZ.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined, color: KZ.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'form.store_visibility'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: KZ.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Available Switch Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KZ.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: KZ.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'form.available'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: KZ.onSurface,
                        ),
                      ),
                      Text(
                        'form.available_sub'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: KZ.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  activeColor: KZ.primary,
                  onChanged: (v) => setState(() => _isAvailable = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Best Seller Switch Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KZ.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: KZ.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'form.best_seller'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: KZ.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.stars_rounded,
                            color: KZ.tertiary,
                            size: 18,
                          ),
                        ],
                      ),
                      Text(
                        'form.best_seller_sub'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: KZ.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isBestSeller,
                  activeColor: KZ.primary,
                  onChanged: (v) => setState(() => _isBestSeller = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KZ.screenPadding,
        vertical: KZ.sp12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: KZ.bottomBarShadow,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => context.pop(),
              child: Text(
                'form.discard'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: KZ.sp12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_rounded, color: Colors.white),
              label: Text(
                _isSaving ? 'Uploading...' : 'form.save_product'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
