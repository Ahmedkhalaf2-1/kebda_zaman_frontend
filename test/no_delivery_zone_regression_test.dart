// Regression guard for the DeliveryZone → distance-based delivery pricing
// migration: the old zone feature must never quietly reappear.
//
// Covers:
//  1. The 6 retired DeliveryZone source files no longer exist.
//  2. No file under lib/ references any retired DeliveryZone symbol —
//     `OrderDeliveryZoneSnapshot` (the intentionally-kept historical-order
//     field) is explicitly allowed and excluded from the scan.
//  3. ApiOrderRepository.checkout() never sends `deliveryZoneId` in the
//     DELIVERY request payload, and does send numeric latitude/longitude
//     for a valid address.
//  4. CheckoutScreen renders no delivery-zone selection UI (no leftover
//     "Delivery Zone" label, no raw untranslated zone keys).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/checkout_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/checkout_screen.dart';
import 'package:kebda_zaman/features/shared/data/api_order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Always-empty cart — the empty-cart branch renders no zone UI, and this
/// avoids needing an authenticated session or a real cart repository.
class _EmptyCartNotifier extends CartNotifier {
  @override
  Future<Cart?> build() async => null;
}

const _retiredFiles = [
  'lib/features/shared/domain/models/delivery_zone.dart',
  'lib/features/shared/domain/repositories/delivery_zone_repository.dart',
  'lib/features/shared/data/api_delivery_zone_repository.dart',
  'lib/features/customer/presentation/notifiers/delivery_zone_notifier.dart',
  'lib/features/admin/presentation/notifiers/delivery_zone_admin_notifier.dart',
  'lib/features/admin/presentation/screens/delivery_zones_screen.dart',
];

// Symbols that must never appear anywhere under lib/ again.
// `OrderDeliveryZoneSnapshot` (and its extension/factory names) is
// deliberately NOT in this list — it's the kept historical-order field.
const _retiredSymbols = [
  'class DeliveryZone ',
  'DeliveryZoneRepository',
  'ApiDeliveryZoneRepository',
  'deliveryZonesProvider',
  'deliveryZoneRepositoryProvider',
  'DeliveryZonesScreen',
  'DeliveryZoneAdminNotifier',
  'deliveryZoneNotifier',
  'deliveryZoneAdminProvider',
];

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);

  final List<Future<ResponseBody> Function(RequestOptions)> script;
  final List<RequestOptions> recordedRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    recordedRequests.add(options);
    return script.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

Future<ResponseBody> Function(RequestOptions) _jsonSuccess(dynamic data) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('Retired DeliveryZone files', () {
    for (final path in _retiredFiles) {
      test('$path no longer exists', () {
        expect(File(path).existsSync(), isFalse);
      });
    }
  });

  group('No retired DeliveryZone symbol remains under lib/', () {
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final symbol in _retiredSymbols) {
      test('"$symbol" does not appear anywhere under lib/', () {
        final offenders = <String>[];
        for (final file in dartFiles) {
          if (file.readAsStringSync().contains(symbol)) {
            offenders.add(file.path);
          }
        }
        expect(
          offenders,
          isEmpty,
          reason: 'Found retired symbol "$symbol" in: ${offenders.join(', ')}',
        );
      });
    }
  });

  group('ApiOrderRepository.checkout() payload', () {
    setUp(() {
      FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
        {},
      );
    });

    test(
      'DELIVERY checkout never sends deliveryZoneId, sends numeric lat/lng',
      () async {
        final adapter = _ScriptedAdapter([
          _jsonSuccess({
            'id': 'order-1',
            'orderNumber': 'ORD-1',
            'userId': 'user-1',
            'items': [],
            'deliveryMethod': 'DELIVERY',
            'status': 'pending',
            'subtotal': 10.0,
            'deliveryFee': 10.0,
            'discount': 0.0,
            'totalAmount': 20.0,
            'paymentStatus': 'PENDING',
            'paymentMethod': 'CASH',
            'createdAt': '2026-08-06T12:00:00.000Z',
          }),
        ]);
        final apiClient = ApiClient(
          secureStorage: const FlutterSecureStorage(),
          tokenStorage: TokenStorage()..accessToken = 'test-token',
        );
        apiClient.dio.httpClientAdapter = adapter;
        final repo = ApiOrderRepository(apiClient);

        await repo.checkout(
          deliveryMethod: FulfillmentType.delivery,
          paymentMethod: 'CASH',
          deliveryAddress: const {
            'title': 'Home',
            'street': 'Street 1',
            'building': 'B1',
            'city': 'Riyadh',
            'latitude': 21.5705641,
            'longitude': 39.1681808,
          },
          idempotencyKey: 'idem-1',
        );

        expect(adapter.recordedRequests.length, 1);
        final payload = adapter.recordedRequests.first.data as Map;
        expect(payload.containsKey('deliveryZoneId'), isFalse);
        expect(payload['deliveryAddress']['latitude'], 21.5705641);
        expect(payload['deliveryAddress']['longitude'], 39.1681808);
      },
    );
  });

  group('CheckoutScreen renders no delivery-zone selection UI', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'no leftover "Delivery Zone" label or raw zone translation keys',
      (tester) async {
        RestaurantSettings settings() => const RestaurantSettings(
          restaurantNameAr: 'كبدة زمان',
          restaurantNameEn: 'Kebda Zaman',
          phone: '+966-000',
          addressAr: 'العنوان',
          addressEn: 'Address',
          taxRatePercent: 0,
          deliveryFee: 0,
          minOrderAmount: 0,
          currency: 'SAR',
          workingHours: [],
          timezone: 'Asia/Riyadh',
          isMaintenanceMode: false,
          acceptingOrders: true,
        );

        final overflows = <FlutterErrorDetails>[];
        final origOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exceptionAsString().contains('overflowed')) {
            overflows.add(details);
          } else {
            FlutterError.presentError(details);
          }
        };

        try {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                cartProvider.overrideWith(() => _EmptyCartNotifier()),
                restaurantSettingsProvider.overrideWith(
                  (ref) => Future.value(settings()),
                ),
                checkoutProvider.overrideWith(() => CheckoutNotifier()),
              ],
              child: EasyLocalization(
                supportedLocales: const [Locale('en'), Locale('ar')],
                path: 'assets/translations',
                fallbackLocale: const Locale('en'),
                startLocale: const Locale('en'),
                useOnlyLangCode: true,
                saveLocale: false,
                assetLoader: const CodegenLoader(),
                child: Builder(
                  builder: (context) {
                    return MaterialApp(
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      home: const CheckoutScreen(),
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump();

          expect(find.text('Delivery Zone'), findsNothing);
          expect(find.textContaining('checkout.delivery_zone'), findsNothing);
          expect(
            find.text(
              'Please select a delivery zone before placing this order.',
            ),
            findsNothing,
          );
        } finally {
          FlutterError.onError = origOnError;
        }
      },
    );
  });
}
