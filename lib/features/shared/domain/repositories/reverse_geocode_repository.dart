import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/reverse_geocode_result.dart';

abstract class ReverseGeocodeRepository {
  Future<Result<ReverseGeocodeResult>> reverseGeocode(
    double latitude,
    double longitude,
  );
}
