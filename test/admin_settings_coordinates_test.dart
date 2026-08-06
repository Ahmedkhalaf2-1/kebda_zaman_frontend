// Focused widget tests for AdminSettingsScreen's
// restaurantLatitude/restaurantLongitude handling (distance-based delivery
// pricing migration, now map-picker based). RestaurantSettings.
// restaurantLatitude/Longitude are nullable — a missing/malformed backend
// value must never be silently replaced with 0 or the production
// coordinates.
//
// Coordinates are no longer manually typed — they're read-only display
// fields, set only via AdminLocationPickerScreen's map. Since that screen
// embeds a GoogleMap platform view, it is (like the existing customer
// MapAddressPickerScreen, see map_address_picker_screen_test.dart) not
// pumped in a widget test here; a GoogleMap camera target is always a
// valid coordinate by construction, so the "manual out-of-range/non-numeric
// input" scenarios that used to be reachable by typing no longer apply.
//
//  1. Coordinates load correctly into the read-only display.
//  2. The "Select restaurant location on map" action is present and
//     enabled, ready to open the picker.
//  3. Saving after editing an unrelated field preserves the loaded
//     coordinates exactly (not reset to 0/null).
//  4. Missing (null) backend coordinates show the configuration-error
//     notice, blank display (never "null" or 0), and block save.
//  5. Malformed backend coordinates (one present, one null) behave
//     identically to missing ones.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
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
  // a normal phone-sized surface would leave the coordinate display and
  // Save button unbuilt and unfindable).
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
  testWidgets('coordinates load correctly into the read-only display', (
    tester,
  ) async {
    final repo = _MockSettingsRepository(_settings());
    await _pump(tester, repo);

    expect(find.text('21.5705641'), findsOneWidget);
    expect(find.text('39.1681808'), findsOneWidget);
  });

  testWidgets(
    '"Select restaurant location on map" action is present and enabled',
    (tester) async {
      final repo = _MockSettingsRepository(_settings());
      await _pump(tester, repo);

      final button = find.widgetWithText(
        KZButton,
        'Select restaurant location on map',
      );
      expect(button, findsOneWidget);
      expect(tester.widget<KZButton>(button).onPressed, isNotNull);
    },
  );

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
    'missing (null) backend coordinates show the configuration error, blank display, and block save',
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
}
