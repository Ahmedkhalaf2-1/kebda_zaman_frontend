import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/utils/polyline_decoder.dart';

void main() {
  group('decodePolyline', () {
    test('decodes the standard Google Maps example polyline', () {
      final points = decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');

      expect(points.length, 3);
      expect(points[0].$1, closeTo(38.5, 1e-4));
      expect(points[0].$2, closeTo(-120.2, 1e-4));
      expect(points[1].$1, closeTo(40.7, 1e-4));
      expect(points[1].$2, closeTo(-120.95, 1e-4));
      expect(points[2].$1, closeTo(43.252, 1e-4));
      expect(points[2].$2, closeTo(-126.453, 1e-4));
    });

    test('returns an empty list for null input', () {
      expect(decodePolyline(null), isEmpty);
    });

    test('returns an empty list for empty input', () {
      expect(decodePolyline(''), isEmpty);
    });

    test('never throws on malformed/truncated input', () {
      expect(() => decodePolyline('!!!not-a-polyline###'), returnsNormally);
      expect(() => decodePolyline('_p~iF~ps|U_ulLnnqC_mqN'), returnsNormally);
    });
  });
}
