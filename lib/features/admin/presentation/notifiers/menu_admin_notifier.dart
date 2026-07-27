import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/data/fake_menu_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

class MenuAdminData {
  final List<Category> categories;
  final List<MenuItem> items;

  MenuAdminData({required this.categories, required this.items});
}

class MenuAdminNotifier extends AutoDisposeAsyncNotifier<MenuAdminData> {
  @override
  Future<MenuAdminData> build() async {
    final repo = ref.read(menuRepositoryProvider);
    final catRes = await repo.getAdminCategories();
    final itemRes = await repo.getAdminMenuItems();

    return MenuAdminData(
      categories: catRes.fold((l) => throw l, (r) => r),
      items: itemRes.fold((l) => throw l, (r) => r),
    );
  }

  Future<void> deleteItem(String id) async {
    final repo = ref.read(menuRepositoryProvider);
    await repo.deleteMenuItem(id);
    ref.invalidateSelf();
    ref.invalidate(menuRepositoryProvider);
  }

  Future<void> toggleItemAvailability(MenuItem item) async {
    final repo = ref.read(menuRepositoryProvider);
    final updated = item.copyWith(isAvailable: !item.isAvailable);
    await repo.updateMenuItem(updated);
    ref.invalidateSelf();
    ref.invalidate(menuRepositoryProvider);
  }

  Future<void> deleteCategory(String id) async {
    final repo = ref.read(menuRepositoryProvider);
    // In a real app, we'd check if it has items here or on the backend
    await repo.deleteCategory(id);
    ref.invalidateSelf();
    ref.invalidate(menuRepositoryProvider);
  }

  Future<void> toggleCategoryAvailability(Category category) async {
    final repo = ref.read(menuRepositoryProvider);
    final updated = category.copyWith(isActive: !category.isActive);
    await repo.updateCategory(updated);
    ref.invalidateSelf();
    ref.invalidate(menuRepositoryProvider);
  }

  Future<void> clearAllMenuData() async {
    final repo = ref.read(menuRepositoryProvider);
    if (repo is FakeMenuRepository) {
      await repo.clearAllData();
      ref.invalidateSelf();
      ref.invalidate(menuRepositoryProvider);
    }
  }
}

final menuAdminProvider =
    AutoDisposeAsyncNotifierProvider<MenuAdminNotifier, MenuAdminData>(
      () => MenuAdminNotifier(),
    );
