import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

final adminOrderDetailsProvider = FutureProvider.family<Order, String>((
  ref,
  id,
) async {
  final repo = ref.watch(orderRepositoryProvider);
  final result = await repo.getOrderById(id);
  return result.fold((f) => throw f, (data) => data);
});
