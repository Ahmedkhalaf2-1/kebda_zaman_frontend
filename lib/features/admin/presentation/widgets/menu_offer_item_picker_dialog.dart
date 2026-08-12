import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/menu_admin_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// Lets an admin choose which existing catalog item a Menu Offer opens.
/// Reuses the same [menuAdminProvider] data source Menu Items management
/// already loads — no separate MenuItem fetch. Unlike the plain-text
/// `_RecommendationPickerDialog`, this shows an image thumbnail and
/// availability, per the Menu Offers item-selector requirement.
Future<MenuItem?> showMenuOfferItemPickerDialog(BuildContext context) {
  return showDialog<MenuItem>(
    context: context,
    builder: (_) => const _MenuOfferItemPickerDialog(),
  );
}

class _MenuOfferItemPickerDialog extends ConsumerStatefulWidget {
  const _MenuOfferItemPickerDialog();

  @override
  ConsumerState<_MenuOfferItemPickerDialog> createState() =>
      _MenuOfferItemPickerDialogState();
}

class _MenuOfferItemPickerDialogState
    extends ConsumerState<_MenuOfferItemPickerDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String? _categoryName(List<Category> categories, String categoryId) {
    for (final c in categories) {
      if (c.id == categoryId) return c.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(menuAdminProvider);
    final languageCode = context.locale.languageCode;
    final query = _query.trim().toLowerCase();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.maxFinite,
        height: 520,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'menu_offers.select_item_title'.tr(),
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
                decoration: KZ.inputDecoration(
                  label: 'menu_offers.search_items'.tr(),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: KZ.onSurfaceVariant,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: dataAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: KZ.primary),
                  ),
                  error: (e, st) => Center(
                    child: Text(
                      'offers.load_error'.tr(),
                      style: const TextStyle(color: KZ.onSurfaceVariant),
                    ),
                  ),
                  data: (data) {
                    final results = data.items.where((item) {
                      if (query.isEmpty) return true;
                      return item
                          .localizedName(languageCode)
                          .toLowerCase()
                          .contains(query);
                    }).toList();

                    if (results.isEmpty) {
                      return Center(
                        child: Text(
                          'menu_offers.no_items_found'.tr(),
                          style: const TextStyle(color: KZ.onSurfaceVariant),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = results[index];
                        final categoryName = _categoryName(
                          data.categories,
                          item.categoryId,
                        );
                        return ListTile(
                          onTap: () => Navigator.of(context).pop(item),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: item.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        color: KZ.surfaceContainerLow,
                                        child: const Icon(
                                          Icons.restaurant_rounded,
                                          color: KZ.onSurfaceVariant,
                                          size: 18,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: KZ.surfaceContainerLow,
                                      child: const Icon(
                                        Icons.restaurant_rounded,
                                        color: KZ.onSurfaceVariant,
                                        size: 18,
                                      ),
                                    ),
                            ),
                          ),
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
                              if (!item.isAvailable)
                                Text(
                                  'menu_offers.item_unavailable'.tr(),
                                  style: const TextStyle(
                                    color: KZ.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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
