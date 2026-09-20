import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/utils/maps_launcher.dart';

void main() {
  group('buildWhatsAppChatUri', () {
    test('builds the wa.me deep link with digits-only phone and no + or spaces', () {
      final uri = buildWhatsAppChatUri(
        phoneDigitsOnly: '966539766416',
        message: 'Hello',
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/966539766416');
      expect(uri.path.contains('+'), isFalse);
      expect(uri.path.contains(' '), isFalse);
    });

    test('percent-encodes the pre-filled message as the text query parameter', () {
      final uri = buildWhatsAppChatUri(
        phoneDigitsOnly: '966539766416',
        message: 'Hello, I need help!',
      );

      expect(uri.queryParameters['text'], 'Hello, I need help!');
    });

    test('correctly round-trips a non-ASCII (Arabic) pre-filled message', () {
      const arabicMessage =
          'السلام عليكم، أحتاج مساعدة بخصوص طلب من تطبيق كبدة زمان. ممكن تساعدوني لو سمحتم؟';
      final uri = buildWhatsAppChatUri(
        phoneDigitsOnly: '966539766416',
        message: arabicMessage,
      );

      expect(uri.queryParameters['text'], arabicMessage);
      // The raw URI string itself must be percent-encoded (no literal
      // Arabic characters or spaces leaking into the wire format).
      expect(uri.toString().contains(' '), isFalse);
    });
  });
}
