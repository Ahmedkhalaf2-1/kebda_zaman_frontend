import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

Map<String, dynamic> _baseSettingsJson() => {
  'restaurantNameAr': 'كبدة زمان',
  'restaurantNameEn': 'Kebda Zaman',
  'phone': '+966-000',
  'addressAr': 'العنوان',
  'addressEn': 'Address',
  'taxRatePercent': 15,
  'deliveryFee': 10,
  'minOrderAmount': 0,
  'currency': 'SAR',
  'workingHours': [],
  'timezone': 'Asia/Riyadh',
  'isMaintenanceMode': false,
  'acceptingOrders': true,
};

void main() {
  group('RestaurantSettings.fromJson — restaurantLatitude/restaurantLongitude', () {
    test('parses numeric coordinate values', () {
      final json = _baseSettingsJson()
        ..addAll({
          'restaurantLatitude': 21.5705641,
          'restaurantLongitude': 39.1681808,
        });

      final settings = RestaurantSettings.fromJson(json);

      expect(settings.restaurantLatitude, 21.5705641);
      expect(settings.restaurantLongitude, 39.1681808);
    });

    test('parses numeric-string coordinate values', () {
      final json = _baseSettingsJson()
        ..addAll({
          'restaurantLatitude': '21.5705641',
          'restaurantLongitude': '39.1681808',
        });

      final settings = RestaurantSettings.fromJson(json);

      expect(settings.restaurantLatitude, 21.5705641);
      expect(settings.restaurantLongitude, 39.1681808);
    });

    test(
      'missing coordinates parse as null, never 0 and never a fabricated default',
      () {
        final json = _baseSettingsJson();

        final settings = RestaurantSettings.fromJson(json);

        expect(settings.restaurantLatitude, isNull);
        expect(settings.restaurantLongitude, isNull);
      },
    );

    test('malformed (non-numeric string) coordinates parse as null', () {
      final json = _baseSettingsJson()
        ..addAll({
          'restaurantLatitude': 'not-a-number',
          'restaurantLongitude': 'also-not-a-number',
        });

      final settings = RestaurantSettings.fromJson(json);

      expect(settings.restaurantLatitude, isNull);
      expect(settings.restaurantLongitude, isNull);
    });

    test(
      'a malformed value never silently substitutes the production coordinates',
      () {
        // Regression: fromJson used to fall back to the known production
        // origin (21.5705641, 39.1681808) on a missing/malformed response —
        // that hid a real backend misconfiguration behind a value that looks
        // legitimate. It must now surface as null instead.
        final json = _baseSettingsJson()
          ..addAll({
            'restaurantLatitude': 'garbage',
            'restaurantLongitude': null,
          });

        final settings = RestaurantSettings.fromJson(json);

        expect(settings.restaurantLatitude, isNot(21.5705641));
        expect(settings.restaurantLongitude, isNot(39.1681808));
        expect(settings.restaurantLatitude, isNull);
        expect(settings.restaurantLongitude, isNull);
      },
    );

    test(
      'one valid and one missing coordinate still parses the valid one, other stays null',
      () {
        final json = _baseSettingsJson()
          ..addAll({
            'restaurantLatitude': 21.5705641,
            'restaurantLongitude': null,
          });

        final settings = RestaurantSettings.fromJson(json);

        expect(settings.restaurantLatitude, 21.5705641);
        expect(settings.restaurantLongitude, isNull);
      },
    );
  });

  group('RestaurantSettings.toJson', () {
    test(
      'includes numeric restaurantLatitude/restaurantLongitude when present',
      () {
        const settings = RestaurantSettings(
          restaurantNameAr: 'كبدة زمان',
          restaurantNameEn: 'Kebda Zaman',
          phone: '+966-000',
          addressAr: 'العنوان',
          addressEn: 'Address',
          restaurantLatitude: 21.5705641,
          restaurantLongitude: 39.1681808,
          taxRatePercent: 15,
          deliveryFee: 10,
          minOrderAmount: 0,
          currency: 'SAR',
          workingHours: [],
          timezone: 'Asia/Riyadh',
          isMaintenanceMode: false,
          acceptingOrders: true,
        );

        final json = settings.toJson();

        expect(json['restaurantLatitude'], 21.5705641);
        expect(json['restaurantLongitude'], 39.1681808);
      },
    );

    test('serializes null as null rather than inventing a value', () {
      const settings = RestaurantSettings(
        restaurantNameAr: 'كبدة زمان',
        restaurantNameEn: 'Kebda Zaman',
        phone: '+966-000',
        addressAr: 'العنوان',
        addressEn: 'Address',
        taxRatePercent: 15,
        deliveryFee: 10,
        minOrderAmount: 0,
        currency: 'SAR',
        workingHours: [],
        timezone: 'Asia/Riyadh',
        isMaintenanceMode: false,
        acceptingOrders: true,
      );

      final json = settings.toJson();

      expect(json['restaurantLatitude'], isNull);
      expect(json['restaurantLongitude'], isNull);
    });
  });

  group('RestaurantSettings.copyWith — coordinate preservation', () {
    test('coordinates are preserved when copyWith does not touch them', () {
      const settings = RestaurantSettings(
        restaurantNameAr: 'كبدة زمان',
        restaurantNameEn: 'Kebda Zaman',
        phone: '+966-000',
        addressAr: 'العنوان',
        addressEn: 'Address',
        restaurantLatitude: 21.5705641,
        restaurantLongitude: 39.1681808,
        taxRatePercent: 15,
        deliveryFee: 10,
        minOrderAmount: 0,
        currency: 'SAR',
        workingHours: [],
        timezone: 'Asia/Riyadh',
        isMaintenanceMode: false,
        acceptingOrders: true,
      );

      final updated = settings.copyWith(
        restaurantNameEn: 'Kebda Zaman Updated',
      );

      expect(updated.restaurantLatitude, 21.5705641);
      expect(updated.restaurantLongitude, 39.1681808);
    });

    test('an explicit new coordinate pair overrides the previous one', () {
      const settings = RestaurantSettings(
        restaurantNameAr: 'كبدة زمان',
        restaurantNameEn: 'Kebda Zaman',
        phone: '+966-000',
        addressAr: 'العنوان',
        addressEn: 'Address',
        restaurantLatitude: 21.5705641,
        restaurantLongitude: 39.1681808,
        taxRatePercent: 15,
        deliveryFee: 10,
        minOrderAmount: 0,
        currency: 'SAR',
        workingHours: [],
        timezone: 'Asia/Riyadh',
        isMaintenanceMode: false,
        acceptingOrders: true,
      );

      final updated = settings.copyWith(
        restaurantLatitude: 24.7136,
        restaurantLongitude: 46.6753,
      );

      expect(updated.restaurantLatitude, 24.7136);
      expect(updated.restaurantLongitude, 46.6753);
    });
  });
}
