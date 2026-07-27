import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/order_management_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/admin_analytics_repository.dart';

class DashboardNotifier extends AutoDisposeAsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    // Reactively watch order management state to recalculate stats on order creation/status update
    ref.watch(orderManagementProvider);
    final repo = ref.read(adminAnalyticsRepositoryProvider);
    return await repo.getDashboardStats();
  }
}

final dashboardProvider =
    AutoDisposeAsyncNotifierProvider<DashboardNotifier, DashboardStats>(() {
      return DashboardNotifier();
    });
