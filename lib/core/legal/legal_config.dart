/// Centralized, single-source-of-truth configuration for the in-app Privacy
/// Policy and Terms of Service documents.
///
/// These documents are owner-review drafts describing the application's
/// actual current behavior (as established by its repositories and the
/// confirmed backend contract) — not externally approved legal advice.
class LegalConfig {
  LegalConfig._();

  /// The date both legal documents were last revised. Update this constant
  /// whenever Privacy Policy or Terms of Service content changes — every
  /// screen reads the same value, so there is exactly one place to edit.
  static final DateTime lastUpdated = DateTime(2026, 8, 7);

  /// No confirmed public business support email has been provided by the
  /// business owner yet. This stays `null` — never replaced with an invented
  /// address — until product/ops confirms real contact details, at which
  /// point this constant becomes the one place that needs updating for both
  /// legal documents to pick it up.
  static const String? businessContactEmail = null;

  /// Same as [businessContactEmail]: unresolved until confirmed by the
  /// business owner. No phone number should ever be invented for display.
  static const String? businessContactPhone = null;

  /// Formats [lastUpdated] as a short human-readable date in the given
  /// locale's language. Deliberately hand-rolled (no `intl` dependency
  /// pulled in just for two fixed-format locales) — this project's `intl`
  /// usage is a transitive dependency of `easy_localization`, not a direct
  /// one, and this only ever needs to render one fixed date in two known
  /// languages.
  static String formattedDate(String languageCode) {
    const monthsEn = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final months = languageCode == 'ar' ? monthsAr : monthsEn;
    final month = months[lastUpdated.month - 1];
    return languageCode == 'ar'
        ? '${lastUpdated.day} $month ${lastUpdated.year}'
        : '$month ${lastUpdated.day}, ${lastUpdated.year}';
  }
}
