import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

/// `POST /payments/intent` response. `providerData` is opaque server config
/// handed straight to the Moyasar SDK (or, for CASH, just display copy) —
/// never constructed or guessed client-side.
@freezed
class PaymentIntent with _$PaymentIntent {
  const factory PaymentIntent({
    required String paymentId,
    required String status,
    required PaymentIntentProviderData providerData,
  }) = _PaymentIntent;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentFromJson(json);
}

@freezed
class PaymentIntentProviderData with _$PaymentIntentProviderData {
  const factory PaymentIntentProviderData({
    // Absent for CASH intents (there is nothing to feed the Moyasar SDK).
    String? publishableApiKey,
    // Smallest-currency-unit amount (e.g. halalas) — already correctly
    // scaled by the backend, never multiplied/divided again client-side.
    required int amount,
    required String currency,
    required String orderId,
    String? description,
    String? callbackUrl,
    @Default(false) bool manual,
    // Present for CASH intents only ("Pay with cash upon delivery").
    String? instructions,
  }) = _PaymentIntentProviderData;

  factory PaymentIntentProviderData.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentProviderDataFromJson(json);
}

/// `POST /payments/:orderId/confirm` and `GET /payments/:id` response — the
/// backend's independently-re-verified Payment record. This is the only
/// thing that ever makes a payment "real"; a Moyasar SDK callback alone is
/// never treated as final.
@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String orderId,
    required String method,
    required String status,
    required double amount,
    required String currency,
    required String provider,
    String? providerRef,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

/// `GET /payments/cards` entry — brand/last-four/expiry only, by design:
/// the backend never has (and never returns) a full card number.
@freezed
class SavedCard with _$SavedCard {
  const factory SavedCard({
    required String id,
    required String brand,
    required String lastFour,
    required int expMonth,
    required int expYear,
    required bool isDefault,
    required DateTime createdAt,
  }) = _SavedCard;

  factory SavedCard.fromJson(Map<String, dynamic> json) =>
      _$SavedCardFromJson(json);
}

/// `POST /payments/:orderId/cards/:cardId/charge` response. `providerData`
/// is only ever present for the rare case a saved card still needs a 3DS
/// challenge — otherwise the charge is already authorized and the caller
/// just moves straight to confirm.
@freezed
class CardChargeResult with _$CardChargeResult {
  const factory CardChargeResult({
    required String paymentId,
    required String status,
    CardChargeProviderData? providerData,
  }) = _CardChargeResult;

  factory CardChargeResult.fromJson(Map<String, dynamic> json) =>
      _$CardChargeResultFromJson(json);
}

@freezed
class CardChargeProviderData with _$CardChargeProviderData {
  const factory CardChargeProviderData({required String transactionUrl}) =
      _CardChargeProviderData;

  factory CardChargeProviderData.fromJson(Map<String, dynamic> json) =>
      _$CardChargeProviderDataFromJson(json);
}
