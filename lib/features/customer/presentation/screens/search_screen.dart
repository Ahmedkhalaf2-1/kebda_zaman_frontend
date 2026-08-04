import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/menu_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../notifiers/search_notifier.dart';

import 'package:kebda_zaman/core/responsive/responsive_container.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: KZ.primary,
            size: 26,
          ),
        ),
        title: TextField(
          autofocus: true,
          decoration: KZ.searchInputDecoration(hint: 'search.hint'.tr()),
          onChanged: (val) {
            searchNotifier.updateQuery(val);
          },
          onSubmitted: (val) {
            searchNotifier.addRecentSearch(val);
          },
        ),
      ),
      body: ResponsiveContainer(
        child: searchState.query.isEmpty
            ? _buildIdleState(context, searchState, searchNotifier, ref)
            : _buildResultsState(context, searchState),
      ),
    );
  }

  Widget _buildIdleState(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
    WidgetRef ref,
  ) {
    final menuState = ref.watch(menuNotifierProvider);
    final lang = context.locale.languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KZ.screenPadding,
        vertical: KZ.sp16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('search.recent'.tr(), style: KZ.labelLarge),
                TextButton(
                  onPressed: () => notifier.clearRecentSearches(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear All',
                    style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KZ.sp8),
            Wrap(
              spacing: KZ.sp8,
              runSpacing: KZ.sp8,
              children: state.recentSearches.map((s) {
                return InkWell(
                  onTap: () => notifier.updateQuery(s),
                  borderRadius: BorderRadius.circular(KZ.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(KZ.radiusFull),
                      border: Border.all(
                        color: KZ.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s,
                          style: KZ.label.copyWith(
                            color: KZ.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => notifier.removeRecentSearch(s),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: KZ.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: KZ.sp24),
          ],

          if (menuState.value != null && menuState.value!.categories.isNotEmpty) ...[
            Text('search.popular'.tr(), style: KZ.labelLarge),
            const SizedBox(height: KZ.sp16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: menuState.value!.categories.take(8).map((cat) {
                return InkWell(
                  onTap: () => notifier.updateQuery(cat.localizedName(lang)),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: KZ.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: cat.imageUrl ?? '',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorWidget:
                              (c, u, e) =>
                                  const Icon(Icons.fastfood, color: KZ.outlineVariant),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            cat.localizedName(lang),
                            style: KZ.caption.copyWith(
                              color: KZ.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsState(BuildContext context, SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: KZ.primary));
    }

    if (state.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KZ.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(KZ.sp20),
                decoration: const BoxDecoration(
                  color: KZ.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: KZ.secondary,
                ),
              ),
              const SizedBox(height: KZ.sp16),
              Text(
                'search.no_results'.tr(namedArgs: {'query': state.query}),
                style: KZ.sectionTitle.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KZ.sp8),
              TextButton(
                onPressed: () => context.push('/menu'),
                child: Text(
                  'search.browse_categories'.tr(),
                  style: KZ.labelLarge.copyWith(color: KZ.primaryContainer),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: KZ.screenPadding,
        vertical: KZ.sp16,
      ),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final item = state.results[index];
        final hasDiscount = item.discountPrice != null;

        return Container(
          margin: const EdgeInsets.only(bottom: KZ.sp12),
          decoration: KZ.cardDecoration(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/home/item/${item.id}'),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: KZFoodImage(imageUrl: item.imageUrl),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(KZ.sp12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.localizedName(context.locale.languageCode),
                          style: KZ.itemTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: KZ.sp4),
                        Text(
                          item.localizedDescription(
                            context.locale.languageCode,
                          ),
                          style: KZ.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.badge != null || item.calories != null) ...[
                          const SizedBox(height: KZ.sp4),
                          Wrap(
                            spacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (item.badge != null)
                                MenuItemBadgeChip(badge: item.badge!),
                              if (item.calories != null)
                                MenuItemCaloriesText(calories: item.calories!),
                            ],
                          ),
                        ],
                        const SizedBox(height: KZ.sp6),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              formatCurrency(
                                hasDiscount
                                    ? item.discountPrice!
                                    : item.basePrice,
                                locale: context.locale,
                              ),
                              style: KZ.price,
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: KZ.sp8),
                              Text(
                                formatCurrency(
                                  item.basePrice,
                                  locale: context.locale,
                                ),
                                style: KZ.bodySmall.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                            if (item.compareAtPrice != null &&
                                item.compareAtPrice! > item.basePrice) ...[
                              const SizedBox(width: KZ.sp8),
                              MenuItemComparePriceText(
                                compareAtPrice: item.compareAtPrice!,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
