import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/features/shared/data/fake_address_repository.dart';

void main() {
  group('Address Model & Repository Tests', () {
    test('fromBackendJson maps all backend fields correctly', () {
      final json = {
        'id': 'addr-123',
        'userId': 'usr-456',
        'title': 'Office',
        'recipientName': 'Ahmed',
        'phone': '01012345678',
        'street': 'Main St.',
        'building': 'Tower 1',
        'floor': '4',
        'apartment': '402',
        'landmark': 'Near metro station',
        'city': 'Cairo',
        'area': 'Maadi',
        'latitude': 29.9602,
        'longitude': 31.2569,
        'notes': 'Ring doorbell',
        'isDefault': true,
      };

      final address = Address.fromBackendJson(json);

      expect(address.id, equals('addr-123'));
      expect(address.userId, equals('usr-456'));
      expect(address.label, equals('Office'));
      expect(address.street, equals('Main St.'));
      expect(address.building, equals('Tower 1'));
      expect(address.floor, equals('4'));
      expect(address.apartment, equals('402'));
      expect(address.landmark, equals('Ring doorbell'));
      expect(address.city, equals('Cairo'));
      expect(address.area, equals('Maadi'));
      expect(address.lat, equals(29.9602));
      expect(address.lng, equals(31.2569));
      expect(address.notes, equals('Ring doorbell'));
      expect(address.isDefault, isTrue);
    });

    test('toBackendJson serializes fields correctly', () {
      const address = Address(
        id: 'addr-1',
        userId: 'usr-1',
        label: 'Home',
        street: 'Street 9',
        building: 'Building 10',
        floor: '2',
        apartment: '2B',
        city: 'Cairo',
        area: 'Maadi',
        notes: 'Call on arrival',
        lat: 30.0444,
        lng: 31.2357,
        isDefault: true,
      );

      final apiJson = address.toBackendJson();

      expect(apiJson['title'], equals('Home'));
      expect(apiJson['street'], equals('Street 9'));
      expect(apiJson['building'], equals('Building 10'));
      expect(apiJson['floor'], equals('2'));
      expect(apiJson['apartment'], equals('2B'));
      expect(apiJson['city'], equals('Cairo'));
      expect(apiJson['notes'], equals('Call on arrival'));
      expect(apiJson['latitude'], equals(30.0444));
      expect(apiJson['longitude'], equals(31.2357));
      expect(apiJson['isDefault'], isTrue);
    });

    test('FakeAddressRepository performs CRUD and maintains default state', () async {
      final repo = FakeAddressRepository();

      final listResult = await repo.getAddresses();
      expect(listResult.isSuccess, isTrue);
      expect(listResult.value.length, equals(2));

      // Set default
      final setDefaultRes = await repo.setDefaultAddress('addr-2');
      expect(setDefaultRes.isSuccess, isTrue);
      expect(setDefaultRes.value.isDefault, isTrue);

      final updatedList = await repo.getAddresses();
      final addr1 = updatedList.value.firstWhere((a) => a.id == 'addr-1');
      final addr2 = updatedList.value.firstWhere((a) => a.id == 'addr-2');

      expect(addr1.isDefault, isFalse);
      expect(addr2.isDefault, isTrue);
    });
  });
}
