import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/address_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/map_address_picker_screen.dart';

/// Add/Edit form for a single saved delivery address.
/// Same `AddressDto` shape for both create and full-replace update
/// (02_API_REFERENCE.md / 03_DTO_REFERENCE.md).
class AddressFormScreen extends ConsumerStatefulWidget {
  final Address? existingAddress;

  const AddressFormScreen({super.key, this.existingAddress});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _buildingCtrl;
  late final TextEditingController _floorCtrl;
  late final TextEditingController _apartmentCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _notesCtrl;

  bool _isDefault = false;
  bool _isSaving = false;
  String _area = '';
  double? _lat;
  double? _lng;

  bool get _isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAddress;
    _labelCtrl = TextEditingController(text: a?.label ?? '');
    _streetCtrl = TextEditingController(text: a?.street ?? '');
    _buildingCtrl = TextEditingController(text: a?.building ?? '');
    _floorCtrl = TextEditingController(text: a?.floor ?? '');
    _apartmentCtrl = TextEditingController(text: a?.apartment ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? 'Cairo');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _isDefault = a?.isDefault ?? false;
    _area = a?.area ?? '';
    _lat = a?.lat;
    _lng = a?.lng;
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.of(context).push<MapAddressPickResult>(
      MaterialPageRoute(
        builder: (_) =>
            MapAddressPickerScreen(initialLat: _lat, initialLng: _lng),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      _lat = result.lat;
      _lng = result.lng;
      if (result.street.isNotEmpty) _streetCtrl.text = result.street;
      if (result.city.isNotEmpty) _cityCtrl.text = result.city;
      if (result.area.isNotEmpty) _area = result.area;
    });
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _floorCtrl.dispose();
    _apartmentCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final address = Address(
      id: widget.existingAddress?.id ?? '',
      userId: widget.existingAddress?.userId ?? '',
      label: _labelCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      building: _buildingCtrl.text.trim(),
      floor: _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
      apartment: _apartmentCtrl.text.trim().isEmpty
          ? null
          : _apartmentCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      area: _area,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      lat: _lat,
      lng: _lng,
      isDefault: _isDefault,
    );

    final notifier = ref.read(addressNotifierProvider.notifier);
    final success = _isEditing
        ? await notifier.updateAddress(address.id, address)
        : await notifier.createAddress(address);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('addresses.save_failed'.tr()),
          backgroundColor: KZ.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(
        context: context,
        title: _isEditing ? 'addresses.edit'.tr() : 'addresses.add'.tr(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            KZ.screenPadding,
            KZ.sp16,
            KZ.screenPadding,
            KZ.sp32,
          ),
          children: [
            TextFormField(
              controller: _labelCtrl,
              decoration: KZ.inputDecoration(
                label: 'addresses.label_hint'.tr(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'item_details.required_badge'.tr()
                  : null,
            ),
            const SizedBox(height: KZ.sp14),
            KZButton(
              label: _lat != null
                  ? 'map_picker.location_set'.tr()
                  : 'map_picker.pick_on_map'.tr(),
              icon: Icons.map_outlined,
              variant: KZButtonVariant.secondary,
              fullWidth: true,
              onPressed: _pickOnMap,
            ),
            const SizedBox(height: KZ.sp14),
            TextFormField(
              controller: _streetCtrl,
              decoration: KZ.inputDecoration(label: 'addresses.street'.tr()),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'item_details.required_badge'.tr()
                  : null,
            ),
            const SizedBox(height: KZ.sp14),
            TextFormField(
              controller: _buildingCtrl,
              decoration: KZ.inputDecoration(label: 'addresses.building'.tr()),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'item_details.required_badge'.tr()
                  : null,
            ),
            const SizedBox(height: KZ.sp14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _floorCtrl,
                    decoration: KZ.inputDecoration(
                      label: 'addresses.floor_optional'.tr(),
                    ),
                  ),
                ),
                const SizedBox(width: KZ.sp12),
                Expanded(
                  child: TextFormField(
                    controller: _apartmentCtrl,
                    decoration: KZ.inputDecoration(
                      label: 'addresses.apartment_optional'.tr(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KZ.sp14),
            TextFormField(
              controller: _cityCtrl,
              decoration: KZ.inputDecoration(label: 'addresses.city'.tr()),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'item_details.required_badge'.tr()
                  : null,
            ),
            const SizedBox(height: KZ.sp14),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: KZ.inputDecoration(
                label: 'addresses.notes_optional'.tr(),
                hint: 'addresses.notes_hint'.tr(),
              ),
            ),
            const SizedBox(height: KZ.sp16),
            KZ.toggleRow(
              label: 'addresses.set_as_default_toggle'.tr(),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            const SizedBox(height: KZ.sp32),
            KZButton(
              label: _isEditing
                  ? 'addresses.save_changes'.tr()
                  : 'addresses.save_address'.tr(),
              icon: Icons.save_rounded,
              loading: _isSaving,
              fullWidth: true,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
