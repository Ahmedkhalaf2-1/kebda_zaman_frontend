import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// Shows a dialog to create or edit a Modifier Group (e.g., "Extra Toppings", "Sandwich Size")
Future<ModifierGroup?> showModifierGroupDialog(
  BuildContext context, {
  ModifierGroup? existingGroup,
}) async {
  return showDialog<ModifierGroup>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ModifierGroupDialog(existingGroup: existingGroup),
  );
}

class _ModifierGroupDialog extends StatefulWidget {
  final ModifierGroup? existingGroup;

  const _ModifierGroupDialog({this.existingGroup});

  @override
  State<_ModifierGroupDialog> createState() => _ModifierGroupDialogState();
}

class _ModifierGroupDialogState extends State<_ModifierGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;

  bool _isRequired = false;
  String _selectionType = 'MULTIPLE'; // 'SINGLE' or 'MULTIPLE'
  List<ModifierOption> _options = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingGroup?.name ?? '');
    _descCtrl = TextEditingController(
      text: widget.existingGroup?.description ?? '',
    );

    _isRequired = widget.existingGroup?.isRequired ?? false;
    _selectionType = widget.existingGroup?.selectionType ?? 'MULTIPLE';
    _options = List.from(widget.existingGroup?.options ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(String presetType) {
    setState(() {
      if (presetType == 'extras') {
        _nameCtrl.text = 'Extra Toppings';
        _isRequired = false;
        _selectionType = 'MULTIPLE';
        _options = [
          ModifierOption(
            id: const Uuid().v4(),
            name: 'Extra Onions',
            priceModifier: 5.0,
          ),
          ModifierOption(
            id: const Uuid().v4(),
            name: 'Extra Tahini',
            priceModifier: 5.0,
          ),
          ModifierOption(
            id: const Uuid().v4(),
            name: 'Hot Pepper',
            priceModifier: 3.0,
          ),
          ModifierOption(
            id: const Uuid().v4(),
            name: 'Extra Cheese',
            priceModifier: 15.0,
          ),
        ];
      } else if (presetType == 'size') {
        _nameCtrl.text = 'Sandwich Size';
        _isRequired = true;
        _selectionType = 'SINGLE';
        _options = [
          ModifierOption(
            id: const Uuid().v4(),
            name: 'Regular',
            priceModifier: 0.0,
            isDefault: true,
          ),
          ModifierOption(
            id: const Uuid().v4(),
            name: 'Large / Double',
            priceModifier: 25.0,
          ),
        ];
      } else if (presetType == 'spicy') {
        _nameCtrl.text = 'Spiciness Level';
        _isRequired = true;
        _selectionType = 'SINGLE';
        _options = [
          ModifierOption(
            id: const Uuid().v4(),
            name: 'Normal',
            priceModifier: 0.0,
            isDefault: true,
          ),
          ModifierOption(
            id: const Uuid().v4(),
            name: 'Spicy',
            priceModifier: 0.0,
          ),
        ];
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one option to this group (e.g. Extra Onions, Cheese)',
          ),
        ),
      );
      return;
    }

    final newGroup = ModifierGroup(
      id: widget.existingGroup?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isRequired: _isRequired,
      selectionType: _selectionType,
      minSelections: _isRequired ? 1 : 0,
      maxSelections: _selectionType == 'SINGLE' ? 1 : _options.length,
      options: _options,
      sortOrder: widget.existingGroup?.sortOrder ?? 0,
    );
    Navigator.of(context).pop(newGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: KZ.surface,
      child: Container(
        width: 540,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: KZ.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: KZ.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.existingGroup == null
                            ? 'Add Modifier Group'
                            : 'Edit Modifier Group',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: KZ.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: KZ.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Scrollable Form Content
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Quick Presets Banner
                    const Text(
                      'Quick Presets:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: KZ.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetChip('Extra Toppings', 'extras'),
                          _buildPresetChip('Sandwich Size', 'size'),
                          _buildPresetChip('Spiciness Level', 'spicy'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Group Name Input
                    const Text(
                      'Modifier Group Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: KZ.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., Extra Toppings, Sandwich Size, Beverages...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: KZ.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter group name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Selection Rules Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: KZ.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selection Rules:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: KZ.primary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Single vs Multiple Selector
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Multiple Selection'),
                                  selected: _selectionType == 'MULTIPLE',
                                  selectedColor: KZ.primaryFixed,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _selectionType == 'MULTIPLE'
                                        ? KZ.primary
                                        : KZ.secondary,
                                  ),
                                  onSelected: (selected) {
                                    if (selected)
                                      setState(
                                        () => _selectionType = 'MULTIPLE',
                                      );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Single Choice'),
                                  selected: _selectionType == 'SINGLE',
                                  selectedColor: KZ.primaryFixed,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _selectionType == 'SINGLE'
                                        ? KZ.primary
                                        : KZ.secondary,
                                  ),
                                  onSelected: (selected) {
                                    if (selected)
                                      setState(() => _selectionType = 'SINGLE');
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Is Required Switch
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Is selection required?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              _isRequired
                                  ? 'Required (Customer must pick an option)'
                                  : 'Optional (Can be skipped)',
                              style: TextStyle(
                                fontSize: 11,
                                color: _isRequired
                                    ? KZ.error
                                    : Colors.green.shade700,
                              ),
                            ),
                            value: _isRequired,
                            activeColor: KZ.primary,
                            onChanged: (v) => setState(() => _isRequired = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Options List Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Modifier Options',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: KZ.onSurface,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: KZ.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_options.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: KZ.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final opt = await showModifierOptionDialog(context);
                            if (opt != null) {
                              setState(() => _options.add(opt));
                            }
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            'Add Option',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KZ.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_options.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: KZ.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.add_circle_outline,
                              color: KZ.onSurfaceVariant,
                              size: 36,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No options in this group yet',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: KZ.secondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Click "Add Option" above or choose a quick preset.',
                              style: TextStyle(
                                fontSize: 11,
                                color: KZ.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final opt = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: KZ.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: KZ.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: KZ.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: KZ.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      opt.priceModifier > 0
                                          ? '+${formatCurrency(opt.priceModifier, locale: Localizations.localeOf(context))}'
                                          : 'Free (${formatCurrency(0, locale: Localizations.localeOf(context))})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: opt.priceModifier > 0
                                            ? KZ.primary
                                            : KZ.tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: KZ.primary,
                                ),
                                onPressed: () async {
                                  final edited = await showModifierOptionDialog(
                                    context,
                                    existingOption: opt,
                                  );
                                  if (edited != null) {
                                    setState(() => _options[index] = edited);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: KZ.error,
                                ),
                                onPressed: () =>
                                    setState(() => _options.removeAt(index)),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(
                      Icons.save_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Save Group',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KZ.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String presetType) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: KZ.outlineVariant.withOpacity(0.5)),
        onPressed: () => _applyPreset(presetType),
      ),
    );
  }
}

/// Shows a dialog to create or edit an individual Modifier Option (e.g. "Extra Onions", "Extra Cheese")
Future<ModifierOption?> showModifierOptionDialog(
  BuildContext context, {
  ModifierOption? existingOption,
}) async {
  return showDialog<ModifierOption>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ModifierOptionDialog(existingOption: existingOption),
  );
}

class _ModifierOptionDialog extends StatefulWidget {
  final ModifierOption? existingOption;

  const _ModifierOptionDialog({this.existingOption});

  @override
  State<_ModifierOptionDialog> createState() => _ModifierOptionDialogState();
}

class _ModifierOptionDialogState extends State<_ModifierOptionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;

  bool _isDefault = false;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingOption?.name ?? '');
    _priceCtrl = TextEditingController(
      text: widget.existingOption != null
          ? widget.existingOption!.priceModifier.toStringAsFixed(0)
          : '0',
    );

    _isDefault = widget.existingOption?.isDefault ?? false;
    _isAvailable = widget.existingOption?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceCtrl.text) ?? 0.0;

    final newOpt = ModifierOption(
      id: widget.existingOption?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      priceModifier: price,
      isDefault: _isDefault,
      isAvailable: _isAvailable,
      nestedModifierGroups: widget.existingOption?.nestedModifierGroups ?? [],
    );
    Navigator.of(context).pop(newOpt);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: KZ.surface,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingOption == null
                        ? 'Add Option Details'
                        : 'Edit Option',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: KZ.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: KZ.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Name Input
              const Text(
                'Option Name',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: KZ.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g., Extra Onions, Extra Cheese...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: KZ.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter option name' : null,
              ),
              const SizedBox(height: 14),

              // Extra Price Input
              const Text(
                'Extra Price (SAR)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: KZ.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0 (Free) or enter amount',
                  suffixText: 'SAR',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: KZ.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Switches
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Default selected',
                  style: TextStyle(fontSize: 13),
                ),
                value: _isDefault,
                activeColor: KZ.primary,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Available for ordering',
                  style: TextStyle(fontSize: 13),
                ),
                value: _isAvailable,
                activeColor: KZ.tertiary,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KZ.primary,
                    ),
                    child: const Text(
                      'Save Option',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
