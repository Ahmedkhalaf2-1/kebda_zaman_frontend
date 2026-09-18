import 'package:url_launcher/url_launcher.dart';

/// Opens Google Maps turn-by-turn directions to the exact stored coordinates
/// of a delivery address — prefers the native Google Maps app when installed,
/// falling back to the browser, via [LaunchMode.externalApplication].
Future<bool> launchGoogleMapsDirections(double lat, double lng) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
  );
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Opens the device's phone dialer pre-filled with [phone] — used by the
/// driver app's "Call customer" action. `tel:` URIs are handled entirely by
/// the OS (no native Maps/Phone app installed check needed, unlike Maps
/// above), so this never needs a fallback URL.
Future<bool> launchPhoneCall(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
