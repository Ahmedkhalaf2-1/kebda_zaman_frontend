import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// Lets an admin pick one real catalog item to add as an "Often Ordered
/// With" recommendation. Manual assignment only — no ranking/suggestion
/// algorithm, just a searchable list of the existing catalog. Excludes the
/// product being edited and items already selected so the caller never has
/// to de-duplicate.
Future<MenuItem?> showRecommendationPickerDialog(
  BuildContext context, {
  required List<MenuItem> availableItems,
  required List<String> excludeIds,
  List<Category> categories = const [],
}) {
  return showDialog<MenuItem>(
    context: context,
    builder: (context) => _RecommendationPickerDialog(
      availableItems: availableItems,
      excludeIds: excludeIds,
      categories: categories,
    ),
  );
}

class _RecommendationPickerDialog extends StatefulWidget {
  final List<MenuItem> availableItems;
  final List<String> excludeIds;
  final List<Category> categories;

  const _RecommendationPickerDialog({
    required this.availableItems,
    required this.excludeIds,
    required this.categories,
  });

  @override
  State<_RecommendationPickerDialog> createState() =>
      _RecommendationPickerDialogState();
}

class _RecommendationPickerDialogState
    extends State<_RecommendationPickerDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String? _categoryName(String categoryId) {
    for (final c in widget.categories) {
      if (c.id == categoryId) return c.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final excludeSet = widget.excludeIds.toSet();
    final languageCode = context.locale.languageCode;
    final query = _query.trim().toLowerCase();
    final results = widget.availableItems.where((item) {
      if (excludeSet.contains(item.id)) return false;
      if (query.isEmpty) return true;
      return item.localizedName(languageCode).toLowerCase().contains(query);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.maxFinite,
        height: 480,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'admin_catalog.search_recommendations'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: KZ.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'form.product_name_hint'.tr(),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: KZ.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: KZ.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          'admin_catalog.no_recommendations'.tr(),
                          style: const TextStyle(color: KZ.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = results[index];
                          final categoryName = _categoryName(item.categoryId);
                          return ListTile(
                            onTap: () => Navigator.of(context).pop(item),
                            title: Text(
                              item.localizedName(languageCode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  formatCurrency(
                                    item.basePrice,
                                    locale: context.locale,
                                  ),
                                ),
                                if (categoryName != null)
                                  Text(
                                    categoryName,
                                    style: const TextStyle(
                                      color: KZ.onSurfaceVariant,
                                    ),
                                  ),
                                if (item.badge != null)
                                  MenuItemBadgeChip(badge: item.badge!),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
