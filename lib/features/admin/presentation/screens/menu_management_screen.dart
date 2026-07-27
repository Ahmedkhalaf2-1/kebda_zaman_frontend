import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/menu_admin_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

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
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top AppBar
            _buildAppBar(context),

            // Main Content Area
            Expanded(
              child: stateAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: KZ.primary),
                ),
                error: (e, st) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'admin.error_loading'.tr(namedArgs: {'error': '$e'}),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KZ.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => ref.invalidate(menuAdminProvider),
                        icon: const Icon(Icons.refresh),
                        label: Text('retry'.tr()),
                      ),
                    ],
                  ),
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
                    onRefresh: () async => ref.invalidate(menuAdminProvider),
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        // Category Horizontal Tabs
                        _buildCategoryTabs(categories),
                        const SizedBox(height: 16),

                        // Search Bar (if search active)
                        if (_isSearching) _buildSearchBar(),

                        // Category Management Bar
                        _buildCategoryHeader(context, categories),

                        // Product List
                        if (filteredItems.isEmpty)
                          _buildEmptyItemsState()
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: filteredItems
                                  .map(
                                    (item) => _buildProductCard(
                                      context,
                                      item,
                                      categories,
                                    ),
                                  )
                                  .toList(),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/admin/menu/add');
        },
        backgroundColor: KZ.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 26),
        label: Text(
          'admin.add_item'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: KZ.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: KZ.primary,
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'admin.menu'.tr(),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: KZ.primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) _searchQuery = '';
                  });
                },
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search_rounded,
                  color: KZ.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: KZ.surfaceContainerLow,
                  shape: const CircleBorder(),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: KZ.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (val) async {
                  if (val == 'add_category') {
                    context.push('/admin/menu/add-category');
                  } else if (val == 'clear') {
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
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('admin.clear_all'.tr()),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(menuAdminProvider.notifier)
                          .clearAllMenuData();
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'add_category',
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          color: KZ.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text('إضافة قسم'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_sweep_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'مسح بيانات المنيو',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        autofocus: true,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'admin.search_food'.tr(),
          prefixIcon: const Icon(Icons.search, color: KZ.primary),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: KZ.outlineVariant.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: KZ.outlineVariant.withOpacity(0.4)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(List<Category> categories) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildCategoryPill('admin.all_items'.tr(), 'all'),
          ...categories.map((c) => _buildCategoryPill(c.name, c.id)),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String label, String categoryId) {
    final isSelected = _selectedCategoryId == categoryId;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedCategoryId = categoryId);
          }
        },
        selectedColor: KZ.primary,
        backgroundColor: KZ.surfaceContainerHigh,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : KZ.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedCategoryId == 'all'
                ? 'admin.all_menu_items'.tr()
                : (categories
                      .firstWhere(
                        (c) => c.id == _selectedCategoryId,
                        orElse: () =>
                            Category(id: '', name: 'Items', sortOrder: 0),
                      )
                      .name),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KZ.onSurface,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.push('/admin/menu/add-category'),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'admin.add_category'.tr(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: KZ.primary,
              side: const BorderSide(color: KZ.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    MenuItem item,
    List<Category> categories,
  ) {
    final categoryName = categories
        .firstWhere(
          (c) => c.id == item.categoryId,
          orElse: () => Category(id: '', name: item.categoryId, sortOrder: 0),
        )
        .name;

    final isAvailable = item.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isAvailable ? 1.0 : 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isAvailable ? 0.04 : 0.01),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? KZ.onSurface : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: KZ.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.basePrice.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: KZ.primary,
                  ),
                ),
              ],
            ),
          ),

          // Actions Column (Toggle & Edit / Delete)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Availability Switch
              Transform.scale(
                scale: 0.85,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: KZ.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      context.push('/admin/menu/edit', extra: item);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () => _confirmDeleteItem(context, item),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: KZ.surfaceContainerLow,
      child: const Icon(Icons.restaurant, color: KZ.secondary, size: 30),
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 56,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            'admin.no_food_items'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: KZ.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'admin.no_food_items_sub'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: KZ.secondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/admin/menu/add'),
            icon: const Icon(Icons.add, size: 18),
            label: Text('admin.add_food_item'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: KZ.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, MenuItem item) {
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
