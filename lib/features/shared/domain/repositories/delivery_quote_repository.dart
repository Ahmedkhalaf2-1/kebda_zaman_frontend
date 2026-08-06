import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_quote.dart';

abstract class DeliveryQuoteRepository {
  /// `POST /delivery/quote` — CUSTOMER-authenticated. Sends only the
  /// destination coordinates; origin, travel mode, and every money figure
  /// are always resolved server-side.
  Future<Result<DeliveryQuote>> getQuote({
    required double latitude,
    required double longitude,
  });
}
