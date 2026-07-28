import 'package:flutter/widgets.dart';

/// The application's one fixed currency — Saudi Riyal. Never read from
/// `RestaurantSettings.currency` (a legacy/unused field) and never
/// converted from the backend's numeric value; this only formats the
/// number the backend already returned.
String formatCurrency(num amount, {required Locale locale}) {
  final rounded = amount.round();
  if (locale.languageCode == 'ar') {
    return '$rounded ر.س';
  }
  return 'SAR $rounded';
}
