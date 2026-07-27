import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_image_picker.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';

class AdminCategoryFormScreen extends ConsumerStatefulWidget {
  final Category? existingCategory;

  const AdminCategoryFormScreen({super.key, this.existingCategory});

  @override
  ConsumerState<AdminCategoryFormScreen> createState() =>
      _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState
    extends ConsumerState<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _sortOrderCtrl;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.existingCategory?.name ?? '',
    );
    _descCtrl = TextEditingController(text: '');
    _imageCtrl = TextEditingController(
      text: widget.existingCategory?.imageUrl ?? '',
    );
    _sortOrderCtrl = TextEditingController(
      text: widget.existingCategory?.sortOrder.toString() ?? '1',
    );
    _isActive = widget.existingCategory?.isActive ?? true;

    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final sortOrder = int.tryParse(_sortOrderCtrl.text) ?? 1;

    final category = Category(
      id: widget.existingCategory?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim(),
      sortOrder: sortOrder,
      isActive: _isActive,
    );

    final repo = ref.read(menuRepositoryProvider);
    if (widget.existingCategory == null) {
      await repo.createCategory(category);
    } else {
      await repo.updateCategory(category);
    }

    ref.invalidate(menuRepositoryProvider);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('admin.category_saved'.tr())));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top AppBar
            _buildAppBar(context),

            // Form Body Scrollable
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KZ.screenPadding,
                    vertical: KZ.sp16,
                  ),
                  children: [
                    _buildVisualSection(),
                    const SizedBox(height: KZ.sp20),
                    _buildFormCard(),
                    const SizedBox(height: KZ.sp32),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Action Button
            _buildBottomActionBar(),
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
          Row(
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
              Text(
                widget.existingCategory == null
                    ? 'admin.add_category'.tr()
                    : 'admin.edit_category'.tr(),
                style: KZ.pageTitle,
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildVisualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('form.category_visual'.tr(), style: KZ.labelLarge),
        const SizedBox(height: KZ.sp8),
        KZImagePickerWidget(
          currentImageUrl: _imageCtrl.text.trim().isNotEmpty
              ? _imageCtrl.text.trim()
              : null,
          onImageSelected: (xFile) {
            setState(() {
              _imageCtrl.clear();
            });
          },
          onUrlChanged: (url) {
            setState(() {
              _imageCtrl.text = url;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return KZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Name
          TextFormField(
            controller: _nameCtrl,
            decoration: KZ.inputDecoration(
              label: 'form.category_name'.tr(),
              hint: 'form.category_name_hint'.tr(),
            ),
            validator: (v) => v == null || v.isEmpty
                ? 'form.category_name_required'.tr()
                : null,
          ),
          const SizedBox(height: KZ.sp14),

          // Internal Notes
          TextFormField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: KZ.inputDecoration(
              label: 'form.internal_notes'.tr(),
              hint: 'form.internal_notes_hint'.tr(),
            ),
          ),
          const SizedBox(height: KZ.sp14),

          // Grid: Display Order & Visibility
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Order
              Expanded(
                child: TextFormField(
                  controller: _sortOrderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: KZ.inputDecoration(
                    label: 'form.display_order'.tr(),
                    suffixIcon: const Icon(
                      Icons.reorder_rounded,
                      color: KZ.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: KZ.sp12),

              // Visibility Toggle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('form.visibility'.tr(), style: KZ.labelLarge),
                    const SizedBox(height: KZ.sp6),
                    KZ.toggleRow(
                      label: 'form.active'.tr(),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
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

  Widget _buildBottomActionBar() {
    return Container(
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
        label: widget.existingCategory == null
            ? 'form.create_category'.tr()
            : 'form.save_category'.tr(),
        icon: widget.existingCategory == null
            ? Icons.add_circle_outline_rounded
            : Icons.check_rounded,
        fullWidth: true,
        pill: true,
        onPressed: _save,
      ),
    );
  }
}
