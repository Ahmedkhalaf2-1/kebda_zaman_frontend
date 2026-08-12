import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

class SearchState {
  final String query;
  final List<MenuItem> results;
  final List<String> recentSearches;
  final List<String> popularSearches;
  final bool isLoading;

  SearchState({
    required this.query,
    required this.results,
    required this.recentSearches,
    required this.popularSearches,
    required this.isLoading,
  });

  SearchState copyWith({
    String? query,
    List<MenuItem>? results,
    List<String>? recentSearches,
    List<String>? popularSearches,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      popularSearches: popularSearches ?? this.popularSearches,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends AutoDisposeNotifier<SearchState> {
  @override
  SearchState build() {
    return SearchState(
      query: '',
      results: [],
      recentSearches: ['Kebda', 'Hawawshi', 'Sogo2'], // Mock recent
      popularSearches: ['Alexandrian Kebda', 'Mix Grill', 'Fries', 'Om Ali'],
      isLoading: false,
    );
  }

  void updateQuery(String query) async {
    state = state.copyWith(query: query, isLoading: true);

    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    final repo = ref.read(menuRepositoryProvider);
    final result = await repo.searchItems(query);

    result.fold(
      (f) {
        state = state.copyWith(results: [], isLoading: false);
      },
      (data) {
        state = state.copyWith(results: data, isLoading: false);
      },
    );
  }

  /// Popular-search category chips filter the already-loaded menu items by
  /// category client-side, rather than going through [updateQuery] — that
  /// does a backend text search against item *names*, which a category
  /// name (e.g. "Beverages") never matches, always yielding zero results.
  void selectCategory(
    String categoryName,
    String categoryId,
    List<MenuItem> allItems,
  ) {
    final results = allItems
        .where((item) => item.categoryId == categoryId)
        .toList();
    state = state.copyWith(
      query: categoryName,
      results: results,
      isLoading: false,
    );
  }

  void addRecentSearch(String search) {
    if (search.trim().isEmpty) return;
    final recents = List<String>.from(state.recentSearches);
    recents.remove(search);
    recents.insert(0, search);
    if (recents.length > 5) recents.removeLast();
    state = state.copyWith(recentSearches: recents);
  }

  void removeRecentSearch(String search) {
    final recents = List<String>.from(state.recentSearches);
    recents.remove(search);
    state = state.copyWith(recentSearches: recents);
  }

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }
}

final searchProvider = AutoDisposeNotifierProvider<SearchNotifier, SearchState>(
  () => SearchNotifier(),
);
