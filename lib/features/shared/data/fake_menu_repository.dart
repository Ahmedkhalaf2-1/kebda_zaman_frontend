import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/menu_repository.dart';

/// Fake menu repository per md1 §14.
/// Loads from JSON assets, mutates in-memory copy, simulates latency/errors.
class FakeMenuRepository implements MenuRepository {
  List<Category> _categories = [];
  List<MenuItem> _menuItems = [];
  bool _initialized = false;
  final _random = Random();

  /// Configurable failure rate (0.0 – 1.0). Default 0.05 = 5%.
  final double failureRate;

  FakeMenuRepository({this.failureRate = 0.05});

  Future<void> _simulateDelay() async {
    final ms = 200 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: ms));
  }

  bool _shouldFail() => _random.nextDouble() < failureRate;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    // One-time clear check if user had old mock data cached
    final isCleanV2 = prefs.getBool('menu_clean_v2') ?? false;
    if (!isCleanV2) {
      await prefs.remove('menu_categories');
      await prefs.remove('menu_items');
      await prefs.setBool('menu_clean_v2', true);
    }

    final categoriesData = prefs.getString('menu_categories');
    final itemsData = prefs.getString('menu_items');

    if (categoriesData != null && itemsData != null) {
      try {
        final List<dynamic> catList = json.decode(categoriesData);
        _categories = catList
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();

        final List<dynamic> itemList = json.decode(itemsData);
        _menuItems = itemList
            .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
            .toList();

        _initialized = true;
        return;
      } catch (e) {
        // Fallback to empty list
      }
    }

    _categories = [];
    _menuItems = [];
    await prefs.setString('menu_categories', json.encode([]));
    await prefs.setString('menu_items', json.encode([]));
    _initialized = true;
  }

  /// Clears all menu categories and items from local storage to start completely fresh from Dashboard
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    _categories.clear();
    _menuItems.clear();
    await prefs.setString('menu_categories', json.encode([]));
    await prefs.setString('menu_items', json.encode([]));
    _initialized = true;
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'menu_categories',
      json.encode(_categories.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'menu_items',
      json.encode(_menuItems.map((i) => i.toJson()).toList()),
    );
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    return Success(List.unmodifiable(_categories.where((c) => c.isActive)));
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    try {
      final cat = _categories.firstWhere((c) => c.id == id);
      return Success(cat);
    } catch (_) {
      return Err(NotFoundFailure('Category $id not found'));
    }
  }

  @override
  Future<Result<List<Category>>> getAdminCategories() async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    return Success(List.unmodifiable(_categories));
  }

  @override
  Future<Result<List<MenuItem>>> getAdminMenuItems({
    String? categoryId,
    String? query,
  }) async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    var items = _menuItems.toList();
    if (categoryId != null) {
      items = items.where((i) => i.categoryId == categoryId).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      items = items.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Success(List.unmodifiable(items));
  }

  @override
  Future<Result<List<MenuItem>>> getMenuItems({String? categoryId}) async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    var items = _menuItems.where((i) => i.isAvailable).toList();
    if (categoryId != null) {
      items = items.where((i) => i.categoryId == categoryId).toList();
    }
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Success(List.unmodifiable(items));
  }

  @override
  Future<Result<MenuItem>> getMenuItemById(String id) async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    try {
      final item = _menuItems.firstWhere((i) => i.id == id);
      return Success(item);
    } catch (_) {
      return Err(NotFoundFailure('MenuItem $id not found'));
    }
  }

  @override
  Future<Result<List<MenuItem>>> getFeaturedItems() async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    final items = _menuItems
        .where((i) => i.isFeatured && i.isAvailable)
        .toList();
    return Success(List.unmodifiable(items));
  }

  @override
  Future<Result<List<MenuItem>>> getBestSellers() async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    final items = _menuItems
        .where((i) => i.isBestSeller && i.isAvailable)
        .toList();
    return Success(List.unmodifiable(items));
  }

  @override
  Future<Result<List<MenuOffer>>> getMenuOffers() async {
    // No fake/mock Menu Offers content — the real feature only exists via
    // the backend, so the fake repository simply returns none rather than
    // inventing banner data.
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    return const Success([]);
  }

  @override
  Future<Result<List<MenuItem>>> searchItems(String query) async {
    await _ensureInitialized();
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Simulated failure'));
    final q = query.toLowerCase();
    final items = _menuItems.where((i) {
      return i.isAvailable &&
          (i.name.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q));
    }).toList();
    return Success(List.unmodifiable(items));
  }

  @override
  Future<Result<void>> createMenuItem(MenuItem item) async {
    await _ensureInitialized();
    await _simulateDelay();
    _menuItems.add(item);
    await _saveItems();
    return const Success(null);
  }

  @override
  Future<Result<void>> updateMenuItem(MenuItem item) async {
    await _ensureInitialized();
    await _simulateDelay();
    final idx = _menuItems.indexWhere((i) => i.id == item.id);
    if (idx == -1) return Err(NotFoundFailure('MenuItem ${item.id} not found'));
    _menuItems[idx] = item;
    await _saveItems();
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteMenuItem(String id) async {
    await _ensureInitialized();
    await _simulateDelay();
    _menuItems.removeWhere((i) => i.id == id);
    await _saveItems();
    return const Success(null);
  }

  @override
  Future<Result<void>> createCategory(Category category) async {
    await _ensureInitialized();
    await _simulateDelay();
    _categories.add(category);
    await _saveCategories();
    return const Success(null);
  }

  @override
  Future<Result<void>> updateCategory(Category category) async {
    await _ensureInitialized();
    await _simulateDelay();
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx == -1) {
      return Err(NotFoundFailure('Category ${category.id} not found'));
    }
    _categories[idx] = category;
    await _saveCategories();
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    await _ensureInitialized();
    await _simulateDelay();
    _categories.removeWhere((c) => c.id == id);
    await _saveCategories();
    return const Success(null);
  }

  @override
  Future<Result<String>> uploadImage(List<int> bytes, String filename) async {
    await _simulateDelay();
    if (_shouldFail()) return const Err(NetworkFailure('Fake upload error'));
    return Success('https://fake.image.url/${filename}');
  }
}
