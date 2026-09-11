import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';

void main() {
  group('formatEtaClockTime', () {
    test('a valid UTC ISO timestamp converts to a local clock time', () {
      final utc = DateTime.utc(2026, 1, 1, 12, 20).toIso8601String();
      final local = DateTime.parse(utc).toLocal();
      final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final period = local.hour >= 12 ? 'PM' : 'AM';

      expect(formatEtaClockTime(utc), '$hour12:$minute $period');
    });

    test('never returns a raw ISO string', () {
      final utc = DateTime.utc(2026, 9, 11, 17, 35).toIso8601String();
      final formatted = formatEtaClockTime(utc);

      expect(formatted, isNot(contains('T')));
      expect(formatted, isNot(contains('Z')));
    });

    test('null input returns null', () {
      expect(formatEtaClockTime(null), isNull);
    });

    test('empty input returns null', () {
      expect(formatEtaClockTime(''), isNull);
      expect(formatEtaClockTime('   '), isNull);
    });

    test('malformed input returns null instead of throwing', () {
      expect(formatEtaClockTime('not-a-date'), isNull);
    });
  });
}
