import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/features/shared/data/api_auth_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_auth_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_menu_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_menu_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/menu_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_cart_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_payment_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/payment_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_cart_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_order_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_loyalty_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/cart_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/loyalty_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/promo_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_promo_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_promo_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/settings_repository.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/menu_offer_repository.dart';
import 'package:kebda_zaman/features/admin/data/api_menu_offer_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_settings_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/admin_notification_repository.dart';
import 'package:kebda_zaman/features/admin/data/fake_admin_notification_repository.dart';
import 'package:kebda_zaman/features/admin/data/api_admin_notification_repository.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/admin_order_notification_repository.dart';
import 'package:kebda_zaman/features/admin/data/api_admin_order_notification_repository.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/staff_repository.dart';
import 'package:kebda_zaman/features/admin/data/api_staff_repository.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/kitchen_repository.dart';
import 'package:kebda_zaman/features/admin/data/api_kitchen_repository.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/customer_repository.dart';
import 'package:kebda_zaman/features/admin/data/api_customer_repository.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/reports_repository.dart';
import 'package:kebda_zaman/features/admin/data/api_reports_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/delivery_quote_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_delivery_quote_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/api/token_refresh_coordinator.dart';
import 'package:kebda_zaman/features/shared/data/api_device_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/device_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_address_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/address_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_reverse_geocode_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/reverse_geocode_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_favorites_repository.dart';
import 'package:kebda_zaman/features/shared/data/api_loyalty_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/favorites_repository.dart';
import 'package:kebda_zaman/core/notifications/device_service.dart';

/// DI provider overrides per md1 §31.
/// Phase 1: all Fake. Phase 3: swap to Api implementations.

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(secureStorage: secureStorage, tokenStorage: tokenStorage);
});

/// Reuses the single coordinator instance already owned by ApiClient — never
/// construct a second one, or concurrent refreshes from the interceptor and
/// the session-bootstrap flow could race the same rotating refresh token.
final tokenRefreshCoordinatorProvider = Provider<TokenRefreshCoordinator>((
  ref,
) {
  return ref.watch(apiClientProvider).tokenRefreshCoordinator;
});

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return ApiMenuRepository(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return ApiPaymentRepository(ref.watch(apiClientProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return ApiCartRepository(ref.watch(apiClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return ApiOrderRepository(ref.watch(apiClientProvider));
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final repo = ApiDeviceRepository(ref.watch(apiClientProvider));
  // Configure the DeviceService singleton with the real repository
  DeviceService.instance.configure(repo);
  return repo;
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return ApiAddressRepository(ref.watch(apiClientProvider));
});

final reverseGeocodeRepositoryProvider = Provider<ReverseGeocodeRepository>((
  ref,
) {
  return ApiReverseGeocodeRepository(ref.watch(apiClientProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return ApiFavoritesRepository(ref.watch(apiClientProvider));
});

final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  return ApiLoyaltyRepository(ref.watch(apiClientProvider));
});

final promoRepositoryProvider = Provider<PromoRepository>((ref) {
  return ApiPromoRepository(ref.watch(apiClientProvider));
});

final adminNotificationRepositoryProvider =
    Provider<AdminNotificationRepository>((ref) {
      return ApiAdminNotificationRepository(ref.watch(apiClientProvider));
    });

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return ApiStaffRepository(ref.watch(apiClientProvider));
});

final kitchenRepositoryProvider = Provider<KitchenRepository>((ref) {
  return ApiKitchenRepository(ref.watch(apiClientProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return ApiCustomerRepository(ref.watch(apiClientProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ApiReportsRepository(ref.watch(apiClientProvider));
});

final deliveryQuoteRepositoryProvider = Provider<DeliveryQuoteRepository>((
  ref,
) {
  return ApiDeliveryQuoteRepository(ref.watch(apiClientProvider));
});

final adminOrderNotificationRepositoryProvider =
    Provider<AdminOrderNotificationRepository>((ref) {
      return ApiAdminOrderNotificationRepository(ref.watch(apiClientProvider));
    });

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return ApiSettingsRepository(ref.watch(apiClientProvider));
});

final adminMenuOfferRepositoryProvider = Provider<MenuOfferRepository>((ref) {
  return ApiMenuOfferRepository(ref.watch(apiClientProvider));
});

final restaurantSettingsProvider = FutureProvider<RestaurantSettings>((
  ref,
) async {
  final repo = ref.read(settingsRepositoryProvider);
  final res = await repo.getSettings();
  return res.fold((l) => throw l, (r) => r);
});
