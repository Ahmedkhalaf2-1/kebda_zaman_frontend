import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/data/api_tracking_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order_tracking.dart';

void main() {
  group('trackingStateFromWire', () {
    test('maps every known wire value', () {
      expect(trackingStateFromWire('NOT_STARTED'), TrackingState.notStarted);
      expect(
        trackingStateFromWire('WAITING_FOR_LOCATION'),
        TrackingState.waitingForLocation,
      );
      expect(trackingStateFromWire('ACTIVE'), TrackingState.active);
      expect(trackingStateFromWire('STALE'), TrackingState.stale);
      expect(trackingStateFromWire('ENDED'), TrackingState.ended);
    });

    test(
      'an unrecognized or null value safely falls back to unknown, never active',
      () {
        expect(
          trackingStateFromWire('SOME_FUTURE_STATE'),
          TrackingState.unknown,
        );
        expect(trackingStateFromWire(null), TrackingState.unknown);
        expect(trackingStateFromWire(''), TrackingState.unknown);
      },
    );
  });

  group('ApiTrackingRepository._mapTracking (via test seam)', () {
    test('parses a full ACTIVE tracking response with a location', () {
      final tracking = ApiTrackingRepository.mapTrackingForTesting('order-1', {
        'orderId': 'order-1',
        'state': 'ACTIVE',
        'driverName': 'Ahmed',
        'driverPhone': '+201234567890',
        'location': {
          'latitude': 30.05,
          'longitude': 31.24,
          'accuracyMeters': 12.5,
          'headingDegrees': 90.0,
          'speedMps': 5.5,
          'capturedAt': '2026-01-01T12:00:00.000Z',
          'receivedAt': '2026-01-01T12:00:02.000Z',
        },
        'locationAgeSeconds': 2,
      });

      expect(tracking.orderId, 'order-1');
      expect(tracking.state, TrackingState.active);
      expect(tracking.driverName, 'Ahmed');
      expect(tracking.location, isNotNull);
      expect(tracking.location!.latitude, 30.05);
      expect(tracking.location!.longitude, 31.24);
      expect(tracking.location!.accuracyMeters, 12.5);
      expect(tracking.locationAgeSeconds, 2);
    });

    test(
      'a null location (e.g. NOT_STARTED/WAITING_FOR_LOCATION) never becomes (0,0)',
      () {
        final tracking =
            ApiTrackingRepository.mapTrackingForTesting('order-1', {
              'orderId': 'order-1',
              'state': 'WAITING_FOR_LOCATION',
              'driverName': null,
              'driverPhone': null,
              'location': null,
              'locationAgeSeconds': null,
            });

        expect(tracking.state, TrackingState.waitingForLocation);
        expect(tracking.location, isNull);
      },
    );

    test(
      'optional sensor fields on location are nullable and independently absent-safe',
      () {
        final tracking = ApiTrackingRepository.mapTrackingForTesting(
          'order-1',
          {
            'orderId': 'order-1',
            'state': 'ACTIVE',
            'location': {
              'latitude': 30.0,
              'longitude': 31.0,
              'capturedAt': '2026-01-01T12:00:00.000Z',
              'receivedAt': '2026-01-01T12:00:00.000Z',
            },
          },
        );

        expect(tracking.location!.accuracyMeters, isNull);
        expect(tracking.location!.headingDegrees, isNull);
        expect(tracking.location!.speedMps, isNull);
      },
    );

    test('a future/unrecognized state value is parsed safely as unknown', () {
      final tracking = ApiTrackingRepository.mapTrackingForTesting('order-1', {
        'orderId': 'order-1',
        'state': 'SOME_FUTURE_STATE',
        'location': null,
      });
      expect(tracking.state, TrackingState.unknown);
    });
  });
}
