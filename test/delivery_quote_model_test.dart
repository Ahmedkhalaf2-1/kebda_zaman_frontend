import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_quote.dart';

void main() {
  group('DeliveryQuote.fromJson', () {
    test('parses a deliverable quote with numeric values', () {
      final json = {
        'deliverable': true,
        'distanceMeters': 13420,
        'distanceKm': 13.42,
        'durationSeconds': 1260,
        'durationMinutes': 21,
        'deliveryFee': 10.0,
        'minimumOrder': 0.0,
        'currency': 'SAR',
        'tier': {'id': 'tier-1', 'minDistanceKm': 0.0, 'maxDistanceKm': 15.0},
      };

      final quote = DeliveryQuote.fromJson(json);

      expect(quote.deliverable, isTrue);
      expect(quote.distanceMeters, equals(13420));
      expect(quote.distanceKm, equals(13.42));
      expect(quote.durationSeconds, equals(1260));
      expect(quote.durationMinutes, equals(21));
      expect(quote.deliveryFee, equals(10.0));
      expect(quote.minimumOrder, equals(0.0));
      expect(quote.currency, equals('SAR'));
      expect(quote.tier, isNotNull);
      expect(quote.tier!.id, equals('tier-1'));
      expect(quote.tier!.minDistanceKm, equals(0.0));
      expect(quote.tier!.maxDistanceKm, equals(15.0));
      expect(quote.reason, isNull);
    });

    test('parses numeric-string values (the actual backend wire shape)', () {
      final json = {
        'deliverable': true,
        'distanceMeters': 13420,
        'distanceKm': '13.42',
        'durationSeconds': 1260,
        'durationMinutes': 21,
        'deliveryFee': '10.00',
        'minimumOrder': '0.00',
        'currency': 'SAR',
        'tier': {
          'id': 'tier-1',
          'minDistanceKm': '0.00',
          'maxDistanceKm': '15.00',
        },
      };

      final quote = DeliveryQuote.fromJson(json);

      expect(quote.distanceKm, equals(13.42));
      expect(quote.deliveryFee, equals(10.0));
      expect(quote.minimumOrder, equals(0.0));
      expect(quote.tier!.minDistanceKm, equals(0.0));
      expect(quote.tier!.maxDistanceKm, equals(15.0));
    });

    test('parses an out-of-range (non-deliverable) response', () {
      final json = {
        'deliverable': false,
        'distanceMeters': 30500,
        'distanceKm': '30.50',
        'durationSeconds': 2400,
        'durationMinutes': 40,
        'currency': 'SAR',
        'reason': 'OUTSIDE_DELIVERY_RANGE',
      };

      final quote = DeliveryQuote.fromJson(json);

      expect(quote.deliverable, isFalse);
      expect(quote.reason, equals('OUTSIDE_DELIVERY_RANGE'));
      expect(quote.tier, isNull);
      expect(quote.deliveryFee, isNull);
      expect(quote.minimumOrder, isNull);
    });

    test('tolerates a null tier', () {
      final json = {
        'deliverable': false,
        'distanceMeters': 40000,
        'currency': 'SAR',
        'reason': 'OUTSIDE_DELIVERY_RANGE',
        'tier': null,
      };

      final quote = DeliveryQuote.fromJson(json);

      expect(quote.tier, isNull);
    });

    test(
      'malformed/garbage optional fields do not crash and parse as null',
      () {
        final json = {
          'deliverable': true,
          'distanceMeters': 'not-a-number',
          'distanceKm': 'also-not-a-number',
          'durationSeconds': null,
          'deliveryFee': {'unexpected': 'shape'},
          'tier': {
            'id': 'tier-1',
            'minDistanceKm': 'nan',
            'maxDistanceKm': null,
          },
        };

        final quote = DeliveryQuote.fromJson(json);

        expect(quote.deliverable, isTrue);
        expect(quote.distanceMeters, isNull);
        expect(quote.distanceKm, isNull);
        expect(quote.durationSeconds, isNull);
        expect(quote.deliveryFee, isNull);
        expect(quote.tier!.minDistanceKm, equals(0.0));
        expect(quote.tier!.maxDistanceKm, equals(0.0));
      },
    );

    test('missing deliverable defaults to false rather than throwing', () {
      final quote = DeliveryQuote.fromJson(const {});

      expect(quote.deliverable, isFalse);
      expect(quote.tier, isNull);
      expect(quote.reason, isNull);
    });
  });
}
