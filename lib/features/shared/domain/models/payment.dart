import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

enum PaymentMethod { cash, card, wallet }

enum PaymentStatus { pending, success, failed, cancelled }

enum PaymentProvider { mock, stripe, paymob }

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String orderId,
    required PaymentMethod method,
    required double amount,
    required PaymentStatus status,
    @Default(PaymentProvider.mock) PaymentProvider provider,
    String? transactionRef,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
