import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

final itemDetailsProvider = FutureProvider.family<MenuItem, String>((
  ref,
  id,
) async {
  final repo = ref.watch(menuRepositoryProvider);
  final result = await repo.getMenuItemById(id);
  return result.fold((f) => throw Exception(f.message), (data) => data);
});
