import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

class MenuData {
  final List<Category> categories;
  final List<MenuItem> items;
  final String? selectedCategoryId;

  MenuData({
    required this.categories,
    required this.items,
    this.selectedCategoryId,
  });

  MenuData copyWith({
    List<Category>? categories,
    List<MenuItem>? items,
    String? selectedCategoryId,
  }) {
    return MenuData(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

class MenuNotifier extends AutoDisposeAsyncNotifier<MenuData> {
  @override
  Future<MenuData> build() async {
    return _fetchData(null);
  }

  Future<MenuData> _fetchData(String? categoryId) async {
    final repo = ref.read(menuRepositoryProvider);
    final catResult = await repo.getCategories();
    final itemResult = await repo.getMenuItems(categoryId: categoryId);

    final categories = catResult.fold((f) => throw f, (data) => data);
    final items = itemResult.fold((f) => throw f, (data) => data);

    return MenuData(
      categories: categories,
      items: items,
      selectedCategoryId: categoryId,
    );
  }

  Future<void> selectCategory(String? categoryId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchData(categoryId));
  }
}

final menuNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MenuNotifier, MenuData>(
      () => MenuNotifier(),
    );
