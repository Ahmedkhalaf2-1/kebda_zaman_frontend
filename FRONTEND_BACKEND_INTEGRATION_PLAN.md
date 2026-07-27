# Frontend-Backend Integration Plan

## Important Integration Rules
- Base URL must NOT be hardcoded directly in business logic.
- Prepare `API_BASE_URL` configuration via `--dart-define=API_BASE_URL=...`.
- Development value: `http://192.168.1.51:3000/api/v1`
- Access token must be sent as: `Authorization: Bearer <accessToken>`
- Plan secure refresh-token storage (e.g., using `flutter_secure_storage`).
- Plan automatic 401 -> refresh -> retry-once behavior in the API client.
- Use backend `error.code` for logic, not `error.message`.
- Do not trust client-side pricing; always display server-returned prices.
- Preserve current UI while replacing data sources.
- Fake repositories must remain until the corresponding API integration is fully validated. Do not delete any fake early.

## Explicit Backend Limitations Affecting the UI
- **CARD/WALLET currently unavailable:** Backend returns `501 PAYMENT_PROVIDER_NOT_CONFIGURED` for intent. UI must hide these options or mark them "coming soon".
- **No customer cancel-order endpoint:** Customers cannot self-cancel orders (only Admins can).
- **No SSE order tracking:** Order Tracking screen must poll `GET /orders/:id/status` instead of using WebSockets/SSE.
- **No customer notification inbox API:** Notification history is local-only on the client; no `GET /me/notifications` exists.
- **No admin dashboard/stats API:** `/admin/dashboard/stats` and `/revenue` do not exist. Admin UI dashboard must be mocked or removed.
- **Cart has no aggregate subtotal/total field:** Cart screen must sum `items[].totalPrice` locally for preview/display.
- **Enum casing is inconsistent:** `Order.status` uses lowerCamel, `PaymentMethod` (request) is uppercase, `DevicePlatform` is uppercase.
- **No "Ready" Order Status:** The Admin UI has a "Ready" order status, but the backend only supports `pending`, `confirmed`, `preparing`, `outForDelivery`, `delivered`, and `cancelled`.

## Migration Phases

### Phase 1: Core API client and environment configuration
- **Files to create:** `lib/core/api/api_client.dart`, `lib/core/api/api_interceptors.dart`, `lib/core/api/api_exceptions.dart`
- **Files to modify:** `lib/main.dart`, `lib/core/di/providers.dart`
- **Fake repository being replaced:** None
- **API endpoints used:** None
- **Tests/manual verification required:** Verify `API_BASE_URL` is read correctly from environment. Verify interceptor attaches `Authorization` header. Verify `error.code` parsing logic.
- **Definition of Done:** Core HTTP client is ready for injection, handling timeouts, headers, and standard error shape mappings.

### Phase 2: Authentication
- **Current fake implementation:** `FakeAuthRepository`
- **Screens/features depending on it:** `LoginScreen`, `SignupScreen`, `ProfileScreen`, `AuthNotifier`
- **Corresponding real backend endpoints:** 
  - `POST /auth/login`
  - `POST /auth/register`
  - `POST /auth/guest`
  - `POST /auth/refresh`
  - `POST /auth/logout`
- **Required new ApiRepository:** `ApiAuthRepository`
- **Required model mapping changes:** Map backend `UserResponseDto` (`name` key instead of `fullName`) to Flutter `User`.
- **Authentication/token requirements:** Store refresh token securely, access token in memory. Implement 401 refresh interceptor.
- **Error-handling requirements:** Handle `INVALID_CREDENTIALS`, `EMAIL_ALREADY_EXISTS`, `ACCOUNT_LOCKED`.
- **Incompatibility/Mismatches:** Admin login leaks account existence.
- **Files to create:** `lib/features/shared/data/api_auth_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`, `lib/features/customer/presentation/notifiers/auth_notifier.dart`
- **Tests/manual verification required:** Login, register, guest login, verify token refresh on expiry, logout clears tokens.
- **Definition of Done:** `AuthNotifier` uses real backend auth successfully.

### Phase 3: Catalog / Menu
- **Current fake implementation:** `FakeMenuRepository`
- **Screens/features depending on it:** `HomeScreen`, `MenuScreen`, `ItemDetailsScreen`, `SearchScreen`
- **Corresponding real backend endpoints:**
  - `GET /categories`
  - `GET /menu`
  - `GET /menu/items/:id`
  - `GET /menu/search?q=`
  - `GET /home/featured`
- **Required new ApiRepository:** `ApiMenuRepository`
- **Required model mapping changes:** Map `MenuItemResponseDto` (and variants/addons) to Flutter models. Ensure `isAvailable` handling.
- **Authentication/token requirements:** None (Public).
- **Error-handling requirements:** Handle `MENU_ITEM_NOT_FOUND`, `SEARCH_QUERY_EMPTY`.
- **Incompatibility/Mismatches:** Backend uses offset-based pagination (`page`, `limit`), no `X-Total-Count`. UI needs to adapt.
- **Files to create:** `lib/features/shared/data/api_menu_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`
- **Tests/manual verification required:** Catalog rendering, category filtering, search functionality.
- **Definition of Done:** Customer catalog screens render real data from the backend.

### Phase 4: Cart
- **Current fake implementation:** `FakeCartRepository`
- **Screens/features depending on it:** `CartScreen`, `CheckoutScreen`, `ItemDetailsScreen`
- **Corresponding real backend endpoints:**
  - `GET /cart`
  - `POST /cart/items`
  - `PUT /cart/items/:id`
  - `DELETE /cart/items/:id`
  - `POST /cart/apply-promo`
  - `DELETE /cart/promo`
  - `DELETE /cart`
- **Required new ApiRepository:** `ApiCartRepository`
- **Required model mapping changes:** Map `CartResponseDto` to `Cart`. Must sum `items[].totalPrice` locally.
- **Authentication/token requirements:** Access token required (Guest allowed).
- **Error-handling requirements:** `ITEM_UNAVAILABLE`, `INVALID_VARIANT`, `INVALID_ADDON_SELECTION`, `PROMO_NOT_FOUND`, `PROMO_INVALID`.
- **Incompatibility/Mismatches:** Missing aggregate subtotal/total field from backend cart response. Promos evaluated strictly server-side.
- **Files to create:** `lib/features/shared/data/api_cart_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`, `lib/features/customer/presentation/notifiers/cart_notifier.dart`
- **Tests/manual verification required:** Add items, update quantity, remove, apply promo, verify UI matches server totals.
- **Definition of Done:** Cart state is entirely server-driven.

### Phase 5: Checkout / Orders
- **Current fake implementation:** `FakeOrderRepository`, `FakePaymentService`
- **Screens/features depending on it:** `CheckoutScreen`, `OrderSuccessScreen`, `OrderTrackingScreen`, `OrdersScreen`
- **Corresponding real backend endpoints:**
  - `POST /orders`
  - `GET /orders`
  - `GET /orders/:id`
  - `GET /orders/:id/status`
  - `POST /payments/intent`
- **Required new ApiRepository:** `ApiOrderRepository`, `ApiPaymentRepository`
- **Required model mapping changes:** `OrderResponseDto` mapping. Set `deliveryAddress: {"type":"PICKUP"}` when method is pickup.
- **Authentication/token requirements:** `CUSTOMER` role access token.
- **Error-handling requirements:** `DELIVERY_ADDRESS_REQUIRED`, `EMPTY_CART`, `BELOW_MIN_ORDER`, `ITEM_UNAVAILABLE`.
- **Incompatibility/Mismatches:** No customer cancel-order. No SSE tracking (requires polling). CARD/WALLET unavailable. Enum casing mismatch for payment methods.
- **Files to create:** `lib/features/shared/data/api_order_repository.dart`, `lib/features/shared/data/api_payment_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`, `lib/features/customer/presentation/notifiers/orders_notifier.dart`
- **Tests/manual verification required:** Perform cash checkout, verify order history list, poll for tracking updates.
- **Definition of Done:** Orders can be successfully placed and tracked via API.

### Phase 6: FCM device token sync
- **Current fake implementation:** Local Log in `NotificationService.syncTokenWithBackend`
- **Screens/features depending on it:** Core app notification routing.
- **Corresponding real backend endpoints:**
  - `POST /devices/register`
  - `PUT /devices/token`
  - `DELETE /devices/token`
- **Required new ApiService:** `ApiDeviceRepository`
- **Required model mapping changes:** Platform mapped to `DevicePlatform` uppercase (`ANDROID`, `IOS`).
- **Authentication/token requirements:** Access token required.
- **Error-handling requirements:** Ignore `404` on token deletion.
- **Incompatibility/Mismatches:** No notification inbox endpoint.
- **Files to create:** `lib/features/shared/data/api_device_repository.dart`
- **Files to modify:** `lib/core/notifications/notification_service.dart`
- **Tests/manual verification required:** Token is registered on login/refresh and deleted on logout.
- **Definition of Done:** FCM tokens sync perfectly with backend sessions.

### Phase 7: Addresses
- **Current fake implementation:** `SharedPreferences` or Local State
- **Screens/features depending on it:** `ProfileScreen`, `CheckoutScreen`
- **Corresponding real backend endpoints:**
  - `GET /me/addresses`
  - `POST /me/addresses`
  - `PUT /me/addresses/:id`
  - `DELETE /me/addresses/:id`
  - `PATCH /me/addresses/:id/default`
- **Required new ApiRepository:** `ApiAddressRepository`
- **Required model mapping changes:** Map `AddressResponseDto` to Flutter `Address`.
- **Authentication/token requirements:** Access token required.
- **Error-handling requirements:** Handle `403 FORBIDDEN` and `404 ADDRESS_NOT_FOUND`.
- **Incompatibility/Mismatches:** First created address is always forced to `isDefault:true`.
- **Files to create:** `lib/features/shared/data/api_address_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`
- **Tests/manual verification required:** Create, edit, delete, and set default address.
- **Definition of Done:** Addresses managed directly via backend API.

### Phase 8: Favorites
- **Current fake implementation:** Local State in `FavoritesScreen`
- **Screens/features depending on it:** `FavoritesScreen`
- **Corresponding real backend endpoints:**
  - `GET /me/favorites`
  - `POST /me/favorites`
  - `DELETE /me/favorites/:menuItemId`
- **Required new ApiRepository:** `ApiFavoritesRepository`
- **Required model mapping changes:** Handle `MenuItemResponseDto` array returned by POST.
- **Authentication/token requirements:** `CUSTOMER` role.
- **Error-handling requirements:** `MENU_ITEM_NOT_FOUND`, `FAVORITE_ALREADY_EXISTS`.
- **Incompatibility/Mismatches:** POST returns full favorites list.
- **Files to create:** `lib/features/shared/data/api_favorites_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`
- **Tests/manual verification required:** Add/remove favorites.
- **Definition of Done:** Favorites synced with the backend.

### Phase 9: Loyalty
- **Current fake implementation:** `FakeLoyaltyRepository`
- **Screens/features depending on it:** `LoyaltyScreen`
- **Corresponding real backend endpoints:**
  - `GET /me/loyalty`
  - `GET /me/loyalty/transactions`
  - `POST /me/loyalty/redeem`
- **Required new ApiRepository:** `ApiLoyaltyRepository`
- **Required model mapping changes:** `rewardId` strings hardcoded on backend (`free-delivery`, `discount-10`, `discount-25`).
- **Authentication/token requirements:** `CUSTOMER` role AND `isGuest=false`.
- **Error-handling requirements:** Handle `403 GUEST_NOT_ELIGIBLE`, `REWARD_NOT_FOUND`, `INSUFFICIENT_POINTS`.
- **Incompatibility/Mismatches:** No endpoint to fetch available rewards dynamically.
- **Files to create:** `lib/features/shared/data/api_loyalty_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`, `lib/features/customer/presentation/screens/loyalty_screen.dart`
- **Tests/manual verification required:** Verify balance, transactions, guest block, and redemptions.
- **Definition of Done:** Loyalty interactions reflect true backend state.

### Phase 10: Admin Orders
- **Current fake implementation:** `FakeOrderRepository` (Admin logic)
- **Screens/features depending on it:** `AdminOrderManagementScreen`, `AdminDashboardScreen`
- **Corresponding real backend endpoints:**
  - `GET /admin/orders`
  - `GET /admin/orders/:id`
  - `PATCH /admin/orders/:id/status`
- **Required new ApiRepository:** `ApiAdminOrderRepository`
- **Required model mapping changes:** Restrict statuses to available backend enums (lowerCamel).
- **Authentication/token requirements:** `ADMIN` role token.
- **Error-handling requirements:** `INVALID_STATUS_TRANSITION`.
- **Incompatibility/Mismatches:** Admin UI "Ready" status must be removed to align with the backend. Dashboard UI must be mocked.
- **Files to create:** `lib/features/admin/data/api_admin_order_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`, `lib/features/admin/presentation/screens/order_management_screen.dart`
- **Tests/manual verification required:** Fetch all orders, update status, verify transitions.
- **Definition of Done:** Admin can manage real customer orders.

### Phase 11: Admin Categories / Menu
- **Current fake implementation:** `FakeMenuRepository` (Admin logic)
- **Screens/features depending on it:** `AdminMenuManagementScreen`, `AdminFoodFormScreen`, `AdminCategoryFormScreen`
- **Corresponding real backend endpoints:**
  - `GET /admin/categories`, `POST /admin/categories`, `PUT /admin/categories/:id`, `DELETE /admin/categories/:id`
  - `GET /admin/menu`, `POST /admin/menu/items`, `PUT /admin/menu/items/:id`, `PATCH /admin/menu/items/:id/availability`, `DELETE /admin/menu/items/:id`
- **Required new ApiRepository:** `ApiAdminMenuRepository`
- **Required model mapping changes:** Diff-sync semantics for variants/addons array on update.
- **Authentication/token requirements:** `ADMIN` role token.
- **Error-handling requirements:** `CATEGORY_HAS_ITEMS`, `MENU_ENTITY_IN_USE`.
- **Incompatibility/Mismatches:** UI must submit complete variant/addon set to avoid deletion.
- **Files to create:** `lib/features/admin/data/api_admin_menu_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`, `lib/features/admin/presentation/screens/admin_food_form_screen.dart`
- **Tests/manual verification required:** Create/edit/delete category and item, toggle availability, test variant diff-sync.
- **Definition of Done:** Admin manages the actual backend catalog safely.

### Phase 12: Admin Promos
- **Current fake implementation:** `FakePromoRepository` (Admin logic)
- **Screens/features depending on it:** `OffersManagementScreen`, `AdminPromoFormScreen`
- **Corresponding real backend endpoints:**
  - `GET /admin/promos`
  - `POST /admin/promos`
  - `PUT /admin/promos/:id`
  - `DELETE /admin/promos/:id`
- **Required new ApiRepository:** `ApiAdminPromoRepository`
- **Required model mapping changes:** Map to `AdminPromoResponseDto`.
- **Authentication/token requirements:** `ADMIN` role token.
- **Error-handling requirements:** `PROMO_CODE_EXISTS`.
- **Incompatibility/Mismatches:** None major.
- **Files to create:** `lib/features/admin/data/api_admin_promo_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`
- **Tests/manual verification required:** CRUD promo codes.
- **Definition of Done:** Promos are fully managed via the API.

### Phase 13: Admin Settings
- **Current fake implementation:** `FakeSettingsRepository` (Admin logic)
- **Screens/features depending on it:** `AdminSettingsScreen`
- **Corresponding real backend endpoints:**
  - `GET /admin/settings`
  - `PUT /admin/settings`
- **Required new ApiRepository:** `ApiAdminSettingsRepository`
- **Required model mapping changes:** None major.
- **Authentication/token requirements:** `ADMIN` role token.
- **Error-handling requirements:** Form must submit all fields (full replace).
- **Incompatibility/Mismatches:** No partial PATCH available.
- **Files to create:** `lib/features/admin/data/api_admin_settings_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`, `lib/features/admin/presentation/screens/admin_settings_screen.dart`
- **Tests/manual verification required:** Update settings and verify customer app reflects them.
- **Definition of Done:** Global settings update correctly.

### Phase 14: Admin Notification Campaigns
- **Current fake implementation:** `FakeAdminNotificationRepository`
- **Screens/features depending on it:** `AdminNotificationsScreen`
- **Corresponding real backend endpoints:**
  - `GET /admin/notifications/campaigns`
  - `POST /admin/notifications/send`
  - `POST /admin/notifications/schedule`
  - `DELETE /admin/notifications/campaigns/:id`
- **Required new ApiRepository:** `ApiAdminNotificationRepository`
- **Required model mapping changes:** `CampaignTargetAudience` must use uppercase.
- **Authentication/token requirements:** `ADMIN` role token.
- **Error-handling requirements:** Handle synchronous send delay (show loading). Handle `CAMPAIGN_NOT_DELETABLE`.
- **Incompatibility/Mismatches:** Ensure UI handles synchronous wait time gracefully.
- **Files to create:** `lib/features/admin/data/api_admin_notification_repository.dart`
- **Files to modify:** `lib/core/di/providers.dart`, `lib/features/admin/presentation/screens/admin_notifications_screen.dart`
- **Tests/manual verification required:** Send campaign, schedule campaign, delete draft.
- **Definition of Done:** Admin push campaigns dispatch through backend successfully.
