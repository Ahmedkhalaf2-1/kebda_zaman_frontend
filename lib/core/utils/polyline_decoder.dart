/// A single decoded point, kept as a plain (latitude, longitude) pair
/// rather than a `google_maps_flutter` `LatLng` so this file stays a pure,
/// widget-free utility that's trivial to unit test.
typedef DecodedLatLng = (double latitude, double longitude);

/// Decodes a Google-encoded polyline string (the standard algorithm used by
/// Directions/Routes API `encodedPolyline` responses) into an ordered list
/// of points. The backend already computes the route — this only turns its
/// wire format into drawable points, it never talks to any Maps API itself.
///
/// Returns an empty list for `null`/empty/malformed input rather than
/// throwing — a corrupt or temporarily-missing route must never crash the
/// tracking screen, only leave it without a line to draw.
List<DecodedLatLng> decodePolyline(String? encoded) {
  if (encoded == null || encoded.isEmpty) return const [];

  final points = <DecodedLatLng>[];
  int index = 0;
  int lat = 0;
  int lng = 0;
  final len = encoded.length;

  try {
    while (index < len) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        if (index >= len) return points;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        if (index >= len) return points;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add((lat / 1e5, lng / 1e5));
    }
  } catch (_) {
    // Malformed input mid-stream — return whatever was successfully
    // decoded so far rather than nothing at all.
    return points;
  }

  return points;
}
