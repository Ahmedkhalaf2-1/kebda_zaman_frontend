import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/services/review_prompt_dismissal_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ReviewPromptDismissalStore', () {
    test('an order with no recorded dismissal is not dismissed', () async {
      expect(await ReviewPromptDismissalStore.isDismissed('order-1'), isFalse);
    });

    test('dismissing an order persists it as dismissed', () async {
      await ReviewPromptDismissalStore.dismiss('order-1');

      expect(await ReviewPromptDismissalStore.isDismissed('order-1'), isTrue);
    });

    test('dismissing one order never marks a different order as dismissed', () async {
      await ReviewPromptDismissalStore.dismiss('order-1');

      expect(await ReviewPromptDismissalStore.isDismissed('order-2'), isFalse);
    });

    test('dismissing the same order twice is safe (no duplicate entries)', () async {
      await ReviewPromptDismissalStore.dismiss('order-1');
      await ReviewPromptDismissalStore.dismiss('order-1');

      final prefs = await SharedPreferences.getInstance();
      final stored =
          prefs.getStringList('kz_review_prompt_dismissed_order_ids') ??
          const [];
      expect(stored.where((id) => id == 'order-1').length, 1);
    });
  });
}
