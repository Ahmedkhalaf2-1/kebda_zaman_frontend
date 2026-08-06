// Focused widget tests for AdminSettingsScreen's
// restaurantLatitude/restaurantLongitude handling (distance-based delivery
// pricing migration). RestaurantSettings.restaurantLatitude/Longitude are
// nullable — a missing/malformed backend value must never be silently
// replaced with 0 or the production coordinates.
//  1. Coordinates load correctly from GET /admin/settings into the fields.
//  2. Saving with an out-of-range latitude blocks the save — no
//     updateSettings call, no accidental 0/null overwrite.
//  3. Saving with an out-of-range longitude blocks the save.
//  4. Saving with a non-numeric coordinate blocks the save.
//  5. Editing an unrelated field and saving preserves the loaded
//     coordinates exactly (not reset to 0/null).
//  6. Editing the coordinates to a new valid pair and saving sends exactly
//     that pair.
//  7. Missing (null) backend coordinates show the configuration-error
//     notice, fields render blank (never "null" or 0), and save is blocked.
//  8. Malformed backend coordinates behave identically to missing ones.
//  9. Fixing the fields to a valid pair after a missing-coordinates load
//     clears the configuration error and allows saving.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_settings_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/settings_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

RestaurantSettings _settings({
  double? restaurantLatitude = 21.5705641,
  double? restaurantLongitude = 39.1681808,
}) => RestaurantSettings(
  restaurantNameAr: 'كبدة زمان',
  restaurantNameEn: 'Kebda Zaman',
  phone: '+966-000',
  addressAr: 'العنوان',
  addressEn: 'Address',
  restaurantLatitude: restaurantLatitude,
  restaurantLongitude: restaurantLongitude,
  taxRatePercent: 15,
  deliveryFee: 10,
  minOrderAmount: 0,
  currency: 'SAR',
  workingHours: const [],
  timezone: 'Asia/Riyadh',
  isMaintenanceMode: false,
  acceptingOrders: true,
);

class _MockSettingsRepository implements SettingsRepository {
  _MockSettingsRepository(this._settings);

  RestaurantSettings _settings;
  int updateCallCount = 0;
  RestaurantSettings? lastUpdate;

  @override
  Future<Result<RestaurantSettings>> getSettings() async => Success(_settings);

  @override
  Future<Result<RestaurantSettings>> getAdminSettings() async =>
      Success(_settings);

  @override
  Future<Result<void>> updateSettings(RestaurantSettings settings) async {
    updateCallCount++;
    lastUpdate = settings;
    _settings = settings;
    return const Success(null);
  }
}

Future<void> _pump(WidgetTester tester, _MockSettingsRepository repo) async {
  // Tall surface so every field in the Profile tab's ListView is actually
  // built (slivers only build children within the viewport/cache extent —
  // a normal phone-sized surface would leave the coordinate fields and Save
  // button unbuilt and unfindable).
  const size = Size(400, 2400);
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        useOnlyLangCode: true,
        saveLocale: false,
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: const AdminSettingsScreen(),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('coordinates load correctly into the fields', (tester) async {
    final repo = _MockSettingsRepository(_settings());
    await _pump(tester, repo);

    expect(find.text('21.5705641'), findsOneWidget);
    expect(find.text('39.1681808'), findsOneWidget);
  });

  testWidgets(
    'an out-of-range latitude blocks save — no update call, notice shown',
    (tester) async {
      final repo = _MockSettingsRepository(_settings());
      await _pump(tester, repo);

      final latField = find.widgetWithText(TextFormField, '21.5705641');
      await tester.enterText(latField, '200');
      await tester.pump();

      await tester.tap(find.text('Save Settings'));
      await tester.pump();

      expect(repo.updateCallCount, 0);
      expect(
        find.text(
          'Please enter a valid latitude (-90 to 90) and longitude (-180 to 180).',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('an out-of-range longitude blocks save', (tester) async {
    final repo = _MockSettingsRepository(_settings());
    await _pump(tester, repo);

    final lngField = find.widgetWithText(TextFormField, '39.1681808');
    await tester.enterText(lngField, '200');
    await tester.pump();

    await tester.tap(find.text('Save Settings'));
    await tester.pump();

    expect(repo.updateCallCount, 0);
  });

  testWidgets('a non-numeric coordinate blocks save', (tester) async {
    final repo = _MockSettingsRepository(_settings());
    await _pump(tester, repo);

    final latField = find.widgetWithText(TextFormField, '21.5705641');
    await tester.enterText(latField, 'not-a-number');
    await tester.pump();

    await tester.tap(find.text('Save Settings'));
    await tester.pump();

    expect(repo.updateCallCount, 0);
  });

  testWidgets(
    'saving after editing an unrelated field preserves the loaded coordinates',
    (tester) async {
      final repo = _MockSettingsRepository(_settings());
      await _pump(tester, repo);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kebda Zaman'),
        'Kebda Zaman Updated',
      );
      await tester.pump();

      await tester.tap(find.text('Save Settings'));
      await tester.pump();
      await tester.pump();

      expect(repo.updateCallCount, 1);
      expect(repo.lastUpdate!.restaurantLatitude, 21.5705641);
      expect(repo.lastUpdate!.restaurantLongitude, 39.1681808);
      // Never accidentally zeroed/nulled.
      expect(repo.lastUpdate!.restaurantLatitude, isNot(0.0));
      expect(repo.lastUpdate!.restaurantLongitude, isNot(0.0));
    },
  );

  testWidgets(
    'editing to a new valid coordinate pair sends exactly that pair',
    (tester) async {
      final repo = _MockSettingsRepository(_settings());
      await _pump(tester, repo);

      await tester.enterText(
        find.widgetWithText(TextFormField, '21.5705641'),
        '24.7136',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '39.1681808'),
        '46.6753',
      );
      await tester.pump();

      await tester.tap(find.text('Save Settings'));
      await tester.pump();
      await tester.pump();

      expect(repo.updateCallCount, 1);
      expect(repo.lastUpdate!.restaurantLatitude, 24.7136);
      expect(repo.lastUpdate!.restaurantLongitude, 46.6753);
    },
  );

  testWidgets(
    'missing (null) backend coordinates show the configuration error, blank fields, and block save',
    (tester) async {
      final repo = _MockSettingsRepository(
        _settings(restaurantLatitude: null, restaurantLongitude: null),
      );
      await _pump(tester, repo);

      // Never the literal "null" and never a fabricated production default.
      expect(find.text('null'), findsNothing);
      expect(find.text('21.5705641'), findsNothing);
      expect(find.text('39.1681808'), findsNothing);
      expect(
        find.text(
          'Restaurant location is not configured correctly. Enter a valid latitude and longitude before saving.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Save Settings'));
      await tester.pump();

      expect(repo.updateCallCount, 0);
    },
  );

  testWidgets(
    'a malformed backend coordinate (one present, one null) also shows the configuration error and blocks save',
    (tester) async {
      final repo = _MockSettingsRepository(
        _settings(restaurantLatitude: 21.5705641, restaurantLongitude: null),
      );
      await _pump(tester, repo);

      expect(
        find.text(
          'Restaurant location is not configured correctly. Enter a valid latitude and longitude before saving.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Save Settings'));
      await tester.pump();

      expect(repo.updateCallCount, 0);
    },
  );

  testWidgets(
    'entering a valid pair after a missing-coordinates load clears the error and allows saving',
    (tester) async {
      final repo = _MockSettingsRepository(
        _settings(restaurantLatitude: null, restaurantLongitude: null),
      );
      await _pump(tester, repo);

      final fields = find.byType(TextFormField);
      // The two coordinate fields are the last two TextFormFields in the
      // Profile tab (latitude then longitude) — both blank at this point.
      final latField = fields.at(fields.evaluate().length - 2);
      final lngField = fields.at(fields.evaluate().length - 1);

      await tester.enterText(latField, '21.5705641');
      await tester.enterText(lngField, '39.1681808');
      await tester.pump();

      expect(
        find.text(
          'Restaurant location is not configured correctly. Enter a valid latitude and longitude before saving.',
        ),
        findsNothing,
      );

      await tester.tap(find.text('Save Settings'));
      await tester.pump();
      await tester.pump();

      expect(repo.updateCallCount, 1);
      expect(repo.lastUpdate!.restaurantLatitude, 21.5705641);
      expect(repo.lastUpdate!.restaurantLongitude, 39.1681808);
    },
  );
}
