import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/menu_admin_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';

const double _kTabletBreakpoint = 700;
const double _kDesktopBreakpoint = 1200;
const double _kMaxContentWidth = 1280;

String _itemCountLabel(int count) {
  if (count == 0) return 'admin_catalog.item_count_zero'.tr();
  if (count == 1) return 'admin_catalog.item_count_one'.tr();
  return 'admin_catalog.item_count_many'.tr(namedArgs: {'count': '$count'});
}

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  ConsumerState<MenuManagementScreen> createState() =>
      _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> {
  String _selectedCategoryId = 'all'; // 'all' or category.id
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(menuAdminProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: stateAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: KZ.primary),
                    ),
                    error: (e, st) => KZErrorState(
                      message: 'admin.error_loading'.tr(
                        namedArgs: {'error': '$e'},
                      ),
                      retryLabel: 'retry'.tr(),
                      onRetry: () => ref.invalidate(menuAdminProvider),
                    ),
                    data: (data) {
                      final categories = data.categories;
                      final allItems = data.items;

                      // Filter items by category & search query
                      final filteredItems = allItems.where((item) {
                        final matchesCategory =
                            _selectedCategoryId == 'all' ||
                            item.categoryId == _selectedCategoryId;
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            item.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            item.description.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                        return matchesCategory && matchesSearch;
                      }).toList();

                      return RefreshIndicator(
                        color: KZ.primary,
                        onRefresh: () async =>
                            ref.invalidate(menuAdminProvider),
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            _buildCategoryTabs(categories),
                            const SizedBox(height: KZ.sp10),
                            if (_isSearching) _buildSearchBar(),
                            _buildCategoryBar(filteredItems.length),
                            if (filteredItems.isEmpty)
                              _buildEmptyItemsState()
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: KZ.sp16,
                                ),
                                child: _ItemGrid(
                                  items: filteredItems,
                                  categories: categories,
                                ),
                              ),
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
      ),
    );
  }

  /// One page title, one visually dominant primary action (Add Item, filled)
  /// — search and the overflow (Clear All) menu stay compact and muted so
  /// they never compete with it. No brand logo/name block: the admin shell's
  /// sidebar/drawer already carries that.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'admin.menu'.tr(),
              style: KZ.pageTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: KZ.onSurfaceVariant,
              size: 22,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: KZ.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KZ.radiusMd),
            ),
            onSelected: (val) async {
              if (val == 'clear') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('admin.clear_menu_title'.tr()),
                    content: Text('admin.clear_menu_body'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('common.cancel'.tr()),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: KZ.error,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('admin.clear_all'.tr()),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(menuAdminProvider.notifier).clearAllMenuData();
                }
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_sweep_rounded,
                      color: KZ.error,
                      size: 20,
                    ),
                    const SizedBox(width: KZ.sp8),
                    Text(
                      'admin.clear_all'.tr(),
                      style: const TextStyle(color: KZ.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: KZ.sp4),
          _AddItemButton(onPressed: () => context.push('/admin/menu/add')),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: TextField(
        autofocus: true,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: KZ.searchInputDecoration(hint: 'admin.search_food'.tr()),
      ),
    );
  }

  Widget _buildCategoryTabs(List<Category> categories) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: KZ.sp8),
            child: KZChip(
              label: 'admin.all_items'.tr(),
              selected: _selectedCategoryId == 'all',
              onTap: () => setState(() => _selectedCategoryId = 'all'),
            ),
          ),
          for (final c in categories)
            Padding(
              padding: const EdgeInsets.only(right: KZ.sp8),
              child: KZChip(
                label: c.name,
                selected: _selectedCategoryId == c.id,
                onTap: () => setState(() => _selectedCategoryId = c.id),
              ),
            ),
        ],
      ),
    );
  }

  /// Item count for the current filter, not a repeated category-name heading
  /// — the selected chip above already makes that obvious. "Add Category"
  /// lives here: accessible, but a small outlined control, never competing
  /// with the header's primary Add Item action.
  Widget _buildCategoryBar(int itemCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(_itemCountLabel(itemCount), style: KZ.bodySmall),
          ),
          TextButton.icon(
            onPressed: () => context.push('/admin/menu/add-category'),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('admin.add_category'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: KZ.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.sp10,
                vertical: KZ.sp4,
              ),
              textStyle: KZ.label,
              minimumSize: const Size(0, 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return KZEmptyState(
      icon: Icons.restaurant_menu_rounded,
      title: 'admin.no_food_items'.tr(),
      message: 'admin.no_food_items_sub'.tr(),
      actionLabel: 'admin.add_food_item'.tr(),
      onAction: () => context.push('/admin/menu/add'),
    );
  }
}

/// The one dominant primary action for this screen — compact filled button,
/// not a floating action button, so it reads as part of the header's action
/// hierarchy rather than a separate mobile-web affordance.
class _AddItemButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddItemButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          'admin.add_item'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: KZ.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: KZ.sp14),
          textStyle: KZ.buttonLabel.copyWith(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
          ),
        ),
      ),
    );
  }
}

/// Responsive item layout: a single column on mobile, more columns as width
/// allows — same width-driven `Wrap` approach already used by the Dashboard
/// KPI grid, so every card just gets a fixed column width and wraps its own
/// (variable) height naturally.
class _ItemGrid extends StatelessWidget {
  final List<MenuItem> items;
  final List<Category> categories;
  const _ItemGrid({required this.items, required this.categories});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= _kDesktopBreakpoint
            ? 3
            : width >= _kTabletBreakpoint
            ? 2
            : 1;
        if (columns == 1) {
          return Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: KZ.sp8),
                  child: _ItemCard(item: item, categories: categories),
                ),
            ],
          );
        }
        const spacing = KZ.sp10;
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _ItemCard(item: item, categories: categories),
              ),
          ],
        );
      },
    );
  }
}

class _ItemCard extends ConsumerWidget {
  final MenuItem item;
  final List<Category> categories;
  const _ItemCard({required this.item, required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryName = categories
        .firstWhere(
          (c) => c.id == item.categoryId,
          orElse: () => Category(id: '', name: item.categoryId, sortOrder: 0),
        )
        .name;
    final isAvailable = item.isAvailable;
    final hasMeta =
        item.badge != null ||
        (item.compareAtPrice != null && item.compareAtPrice! > item.basePrice) ||
        item.calories != null;

    return Container(
      padding: const EdgeInsets.all(KZ.sp10),
      decoration: BoxDecoration(
        color: KZ.surface,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.55,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(KZ.radiusSm),
              child: SizedBox(
                width: 56,
                height: 56,
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            const SizedBox(width: KZ.sp10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KZ.itemTitle,
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: KZ.sp8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KZ.caption,
                      ),
                      Text(
                        formatCurrency(item.basePrice, locale: context.locale),
                        style: KZ.price.copyWith(color: KZ.primary),
                      ),
                    ],
                  ),
                  if (hasMeta) ...[
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: KZ.sp8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.badge != null)
                          MenuItemBadgeChip(badge: item.badge!),
                        if (item.compareAtPrice != null &&
                            item.compareAtPrice! > item.basePrice)
                          MenuItemComparePriceText(
                            compareAtPrice: item.compareAtPrice!,
                          ),
                        if (item.calories != null)
                          MenuItemCaloriesText(calories: item.calories!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: KZ.sp4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: item.isAvailable,
                    activeColor: KZ.tertiary,
                    onChanged: (val) {
                      ref
                          .read(menuAdminProvider.notifier)
                          .toggleItemAvailability(item);
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: KZ.onSurfaceVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KZ.radiusMd),
                    ),
                    onSelected: (val) {
                      if (val == 'edit') {
                        context.push('/admin/menu/edit', extra: item);
                      } else if (val == 'delete') {
                        _confirmDeleteItem(context, ref, item);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              color: KZ.onSurfaceVariant,
                              size: 18,
                            ),
                            const SizedBox(width: KZ.sp8),
                            Text('common.edit'.tr()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: KZ.error,
                              size: 18,
                            ),
                            const SizedBox(width: KZ.sp8),
                            Text(
                              'common.delete'.tr(),
                              style: const TextStyle(color: KZ.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: KZ.surfaceContainerLow,
      child: const Icon(Icons.restaurant, color: KZ.secondary, size: 24),
    );
  }

  void _confirmDeleteItem(BuildContext context, WidgetRef ref, MenuItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'admin.delete_item_title'.tr(namedArgs: {'name': item.name}),
        ),
        content: Text('admin.delete_item_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KZ.error),
            onPressed: () {
              ref.read(menuAdminProvider.notifier).deleteItem(item.id);
              Navigator.pop(ctx);
            },
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }
}
