import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/map_address_picker_screen.dart';

void main() {
  group('mapPickerStatusMessageKey', () {
    test('returns null for statuses that need no banner', () {
      expect(mapPickerStatusMessageKey(MapPickerLocationStatus.idle), isNull);
      expect(
        mapPickerStatusMessageKey(MapPickerLocationStatus.locating),
        isNull,
      );
      expect(
        mapPickerStatusMessageKey(MapPickerLocationStatus.located),
        isNull,
      );
    });

    test('maps serviceDisabled to its translation key', () {
      expect(
        mapPickerStatusMessageKey(MapPickerLocationStatus.serviceDisabled),
        'map_picker.location_disabled',
      );
    });

    test('maps permissionDenied to its translation key', () {
      expect(
        mapPickerStatusMessageKey(MapPickerLocationStatus.permissionDenied),
        'map_picker.location_denied',
      );
    });

    test('maps permissionDeniedForever to its translation key', () {
      expect(
        mapPickerStatusMessageKey(
          MapPickerLocationStatus.permissionDeniedForever,
        ),
        'map_picker.location_denied_forever',
      );
    });

    test('maps unavailable to its translation key', () {
      expect(
        mapPickerStatusMessageKey(MapPickerLocationStatus.unavailable),
        'map_picker.location_unavailable',
      );
    });
  });

  group('MapAddressPickResult', () {
    test('defaults reverse-geocode fields to empty strings', () {
      const result = MapAddressPickResult(lat: 30.0444, lng: 31.2357);

      expect(result.lat, 30.0444);
      expect(result.lng, 31.2357);
      expect(result.street, '');
      expect(result.city, '');
      expect(result.area, '');
    });

    test('carries reverse-geocode suggestions when provided', () {
      const result = MapAddressPickResult(
        lat: 29.9602,
        lng: 31.2569,
        street: 'Main St.',
        city: 'Cairo',
        area: 'Maadi',
      );

      expect(result.street, 'Main St.');
      expect(result.city, 'Cairo');
      expect(result.area, 'Maadi');
    });
  });
}
