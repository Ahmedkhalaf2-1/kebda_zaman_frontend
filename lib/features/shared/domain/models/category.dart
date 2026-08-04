import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? imageUrl,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    String? parentCategoryId,
    String? nameAr,
    String? nameEn,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

/// Locale-aware accessor for [Category] names, mirroring
/// `MenuItemLocalization`: falls back to the other language when the
/// preferred one is null, empty, or whitespace-only, then to the base
/// [Category.name] so a section header/tab never renders blank.
extension CategoryLocalization on Category {
  String localizedName(String languageCode) {
    String? pick(String? preferred, String? other) {
      if (preferred != null && preferred.trim().isNotEmpty) return preferred;
      if (other != null && other.trim().isNotEmpty) return other;
      return null;
    }

    return (languageCode == 'ar'
            ? pick(nameAr, nameEn)
            : pick(nameEn, nameAr)) ??
        name;
  }
}
