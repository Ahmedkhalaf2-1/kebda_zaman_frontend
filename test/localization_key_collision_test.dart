import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Regression coverage for the VO3 localization collision fix.
///
/// `easy_localization`'s key generator flattens nested JSON paths to
/// underscored Dart identifiers (`admin.notifications` -> `admin_notifications`).
/// The `admin` object used to carry short nav-style leaf keys named
/// `offers`/`settings`/`notifications`, which flattened to the exact same
/// identifiers as the top-level `admin_offers`/`admin_settings`/
/// `admin_notifications` screen namespaces — causing `duplicate_definition`
/// analyzer errors in `lib/generated/locale_keys.g.dart` and, worse, silent
/// data loss on regeneration (the generator's `--skip-unnecessary-keys`
/// logic dropped dozens of unrelated constants when it hit the collision).
///
/// The fix renamed the three dead leaf keys (they had no Dart call sites) to
/// `offers_label`/`settings_label`/`notifications_label`. This test guards
/// against the collision being reintroduced by asserting both the renamed
/// leaf values and the untouched section namespaces resolve correctly and
/// independently from the actual runtime translation source.
void main() {
  const loader = CodegenLoader();

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    group('locale ${locale.languageCode}', () {
      late Map<String, dynamic> data;

      setUpAll(() async {
        data = (await loader.load('assets/translations', locale))!;
      });

      test('admin.offers_label / admin.settings_label / '
          'admin.notifications_label resolve as leaf strings', () {
        final admin = data['admin'] as Map<String, dynamic>;
        expect(admin['offers_label'], isA<String>());
        expect(admin['settings_label'], isA<String>());
        expect(admin['notifications_label'], isA<String>());
      });

      test('top-level admin_offers/admin_settings/admin_notifications remain '
          'full section objects, unaffected by the leaf rename', () {
        expect(data['admin_offers'], isA<Map<String, dynamic>>());
        expect(data['admin_settings'], isA<Map<String, dynamic>>());
        expect(data['admin_notifications'], isA<Map<String, dynamic>>());
      });

      test('no leftover "offers"/"settings"/"notifications" leaf keys '
          'remain under admin (would recreate the collision)', () {
        final admin = data['admin'] as Map<String, dynamic>;
        expect(admin.containsKey('offers'), isFalse);
        expect(admin.containsKey('settings'), isFalse);
        expect(admin.containsKey('notifications'), isFalse);
      });
    });
  }

  test('VO3 menu badge/calories translation values are correct', () async {
    final en = (await loader.load('assets/translations', const Locale('en')))!;
    final ar = (await loader.load('assets/translations', const Locale('ar')))!;
    final menuEn = en['menu'] as Map<String, dynamic>;
    final menuAr = ar['menu'] as Map<String, dynamic>;

    expect(menuEn['badge_bestseller'], 'Bestseller');
    expect(menuEn['badge_top_rated'], 'Top Rated');
    expect(menuEn['calories'], '{count} kcal');

    expect(menuAr['badge_bestseller'], 'الأكثر مبيعًا');
    expect(menuAr['badge_top_rated'], 'الأعلى تقييمًا');
    expect(menuAr['calories'], '{count} سعرة حرارية');
  });
}
