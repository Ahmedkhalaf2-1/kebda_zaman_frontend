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

/// Builds the `https://wa.me/` deep-link URI for a WhatsApp chat with
/// [phoneDigitsOnly] (no `+`, no spaces — just country code + number, e.g.
/// `966539766416`), pre-filled with [message]. Split out from
/// [launchWhatsAppChat] as a pure function so the URI shape (host, path,
/// query encoding) is unit-testable without touching the `url_launcher`
/// platform channel. `Uri.https` handles the message's URL-encoding itself,
/// so [message] is passed as plain text.
Uri buildWhatsAppChatUri({
  required String phoneDigitsOnly,
  required String message,
}) {
  return Uri.https('wa.me', '/$phoneDigitsOnly', {'text': message});
}

/// Opens a WhatsApp chat via [buildWhatsAppChatUri] — opens the WhatsApp app
/// directly when installed, falls back to WhatsApp Web/App Store in the
/// browser otherwise (the same link format works either way, unlike a raw
/// `whatsapp://` scheme which has no browser fallback at all).
Future<bool> launchWhatsAppChat({
  required String phoneDigitsOnly,
  required String message,
}) async {
  final uri = buildWhatsAppChatUri(
    phoneDigitsOnly: phoneDigitsOnly,
    message: message,
  );
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
