import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/features/shared/data/fake_loyalty_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('Loyalty Repository Tests', () {
    test('FakeLoyaltyRepository returns account and transactions', () async {
      final repo = FakeLoyaltyRepository();

      final accResult = await repo.getMeLoyalty();
      expect(accResult.isSuccess, isTrue);
      expect(accResult.value.pointsBalance, equals(0));

      final histResult = await repo.getMeLoyaltyTransactions();
      expect(histResult.isSuccess, isTrue);
      expect(histResult.value.isEmpty, isTrue);

      final redeemResult = await repo.redeemReward('discount-10');
      expect(redeemResult.isSuccess, isTrue);
    });
  });
}
