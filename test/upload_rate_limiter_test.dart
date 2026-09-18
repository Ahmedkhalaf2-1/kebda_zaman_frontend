import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/driver/domain/services/upload_rate_limiter.dart';

void main() {
  group('UploadRateLimiter', () {
    test('starts full and allows consuming up to capacity', () {
      var now = DateTime(2026, 1, 1);
      final limiter = UploadRateLimiter(capacityPerMinute: 3, now: () => now);

      expect(limiter.tryConsume(), isTrue);
      expect(limiter.tryConsume(), isTrue);
      expect(limiter.tryConsume(), isTrue);
      expect(limiter.tryConsume(), isFalse); // budget exhausted
    });

    test('refills proportionally to elapsed time', () {
      var now = DateTime(2026, 1, 1);
      final limiter = UploadRateLimiter(capacityPerMinute: 60, now: () => now);

      for (var i = 0; i < 60; i++) {
        expect(limiter.tryConsume(), isTrue);
      }
      expect(limiter.tryConsume(), isFalse);

      // Half a minute later, roughly half the budget (30 tokens) is back.
      now = now.add(const Duration(seconds: 30));
      var consumed = 0;
      while (limiter.tryConsume()) {
        consumed++;
      }
      expect(consumed, inInclusiveRange(29, 31));
    });

    test('never refills above capacity even after a long idle period', () {
      var now = DateTime(2026, 1, 1);
      final limiter = UploadRateLimiter(capacityPerMinute: 10, now: () => now);
      now = now.add(const Duration(hours: 1));

      var consumed = 0;
      while (limiter.tryConsume()) {
        consumed++;
      }
      expect(consumed, 10);
    });

    test('blockUntil zeroes the budget until the given time', () {
      var now = DateTime(2026, 1, 1);
      final limiter = UploadRateLimiter(capacityPerMinute: 10, now: () => now);

      limiter.blockUntil(now.add(const Duration(seconds: 20)));
      expect(limiter.tryConsume(), isFalse);

      now = now.add(const Duration(seconds: 10));
      expect(limiter.tryConsume(), isFalse); // still within the block window

      // Once the block window passes, refill resumes from zero at the
      // normal rate (10/min here) — allow enough elapsed time past `until`
      // for at least one full token to accrue, not just an instant.
      now = now.add(const Duration(seconds: 20));
      expect(limiter.tryConsume(), isTrue);
    });

    test(
      'a 429 Retry-After block does not let tokens accrue during the wait',
      () {
        var now = DateTime(2026, 1, 1);
        final limiter = UploadRateLimiter(
          capacityPerMinute: 60,
          now: () => now,
        );
        limiter.tryConsume(); // some usage before the block
        limiter.blockUntil(now.add(const Duration(seconds: 5)));

        now = now.add(const Duration(seconds: 4));
        expect(limiter.tokensForTesting, 0.0);
      },
    );
  });
}
