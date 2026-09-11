import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/features/admin/presentation/widgets/preparation_time_section.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      startLocale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      saveLocale: false,
      assetLoader: const CodegenLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(body: child),
          );
        },
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('isPreparationTimeEditableStatus', () {
    test('confirmed and preparing are editable', () {
      expect(isPreparationTimeEditableStatus(OrderStatus.confirmed), isTrue);
      expect(isPreparationTimeEditableStatus(OrderStatus.preparing), isTrue);
    });

    test('pending, outForDelivery, readyForPickup are NOT editable', () {
      expect(isPreparationTimeEditableStatus(OrderStatus.pending), isFalse);
      expect(
        isPreparationTimeEditableStatus(OrderStatus.outForDelivery),
        isFalse,
      );
      expect(
        isPreparationTimeEditableStatus(OrderStatus.readyForPickup),
        isFalse,
      );
    });

    test('terminal statuses are NOT editable', () {
      expect(isPreparationTimeEditableStatus(OrderStatus.delivered), isFalse);
      expect(isPreparationTimeEditableStatus(OrderStatus.pickedUp), isFalse);
      expect(isPreparationTimeEditableStatus(OrderStatus.cancelled), isFalse);
    });
  });

  group('PreparationTimeSection', () {
    testWidgets('editable: true shows preset chips + Custom', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: null,
            estimatedDeliveryTime: null,
            deliveryMethod: FulfillmentType.pickup,
            editable: true,
            submitting: false,
            onSetMinutes: (_) {},
          ),
        ),
      );
      await tester.pump();

      for (final preset in kPreparationTimePresets) {
        expect(find.text('$preset min'), findsOneWidget);
      }
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('editable: false shows no preset/custom controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: 20,
            estimatedDeliveryTime: null,
            deliveryMethod: FulfillmentType.pickup,
            editable: false,
            submitting: false,
            onSetMinutes: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Custom'), findsNothing);
      // The current value is still shown even though it's not editable.
      expect(find.text('20 min'), findsOneWidget);
    });

    testWidgets('tapping a preset calls onSetMinutes with the right value', (
      tester,
    ) async {
      int? tapped;
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: null,
            estimatedDeliveryTime: null,
            deliveryMethod: FulfillmentType.pickup,
            editable: true,
            submitting: false,
            onSetMinutes: (m) => tapped = m,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('15 min'));
      await tester.pump();

      expect(tapped, 15);
    });

    testWidgets('submitting: true shows a progress indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: null,
            estimatedDeliveryTime: null,
            deliveryMethod: FulfillmentType.pickup,
            editable: true,
            submitting: true,
            onSetMinutes: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('submitting: true disables preset taps', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: null,
            estimatedDeliveryTime: null,
            deliveryMethod: FulfillmentType.pickup,
            editable: true,
            submitting: true,
            onSetMinutes: (_) => callCount++,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('15 min'), warnIfMissed: false);
      await tester.pump();

      expect(callCount, 0);
    });

    testWidgets('a custom (non-preset) value shows "N min" not "Custom"', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: 27,
            estimatedDeliveryTime: null,
            deliveryMethod: FulfillmentType.pickup,
            editable: true,
            submitting: false,
            onSetMinutes: (_) {},
          ),
        ),
      );
      await tester.pump();

      // The current-value line, and the chip that now shows "27 min"
      // instead of the literal "Custom" label.
      expect(find.text('27 min'), findsNWidgets(2));
      expect(find.text('Custom'), findsNothing);
    });

    testWidgets('ETA renders as a human-readable time, pickup wording', (
      tester,
    ) async {
      final utc = DateTime.utc(2026, 1, 1, 12, 20).toIso8601String();
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: 20,
            estimatedDeliveryTime: utc,
            deliveryMethod: FulfillmentType.pickup,
            editable: true,
            submitting: false,
            onSetMinutes: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Estimated ready time:'), findsOneWidget);
      expect(find.textContaining('T12:20'), findsNothing);
    });

    testWidgets('ETA renders with delivery wording for DELIVERY orders', (
      tester,
    ) async {
      final utc = DateTime.utc(2026, 1, 1, 12, 20).toIso8601String();
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: 20,
            estimatedDeliveryTime: utc,
            deliveryMethod: FulfillmentType.delivery,
            editable: true,
            submitting: false,
            onSetMinutes: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Estimated arrival:'), findsOneWidget);
    });

    testWidgets('a malformed ETA does not crash and renders no ETA line', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PreparationTimeSection(
            preparationTimeMinutes: 20,
            estimatedDeliveryTime: 'not-a-date',
            deliveryMethod: FulfillmentType.pickup,
            editable: true,
            submitting: false,
            onSetMinutes: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Estimated ready time:'), findsNothing);
    });
  });
}
