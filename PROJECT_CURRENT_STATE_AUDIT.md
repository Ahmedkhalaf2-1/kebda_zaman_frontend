# PROJECT_CURRENT_STATE_AUDIT.md
## Kebda Zaman — Comprehensive Technical Audit & Single Source of Truth

**Audit Timestamp:** 2026-08-29
**Project:** Kebda Zaman (كبدة زمان) Multi-Platform Ecosystem
**Target File Path:** `C:\Users\user\OneDrive - Higher Technological Institute\Desktop\kebda zaman\kebda_zaman\PROJECT_CURRENT_STATE_AUDIT.md`

---

## 1. PROJECT OVERVIEW

The **Kebda Zaman** project is a production food-ordering and restaurant-management platform: a **Flutter Customer App** and an **in-app Flutter Admin Panel** (customer + admin UIs in one codebase), both fully wired to a live REST backend.

### Ecosystem Status Matrix

| Component / Layer | Current Status | Details |
| :--- | :--- | :--- |
| **Flutter Customer App** | **Production-connected** | 19+ customer screens, styled with `KZ` design tokens, multilingual (`easy_localization`, AR/EN), responsive. All data served from the real API. |
| **Admin Panel (Flutter)** | **Production-connected** | Dashboard, Menus, Menu Offers, Orders, Kitchen queue, Offers/Promos, Push Notifications + Order Notifications, Settings, Staff, Customer Management, Reports — all backed by API repositories. |
| **Backend REST API** | **LIVE** | Base URL `https://api.kebdazaman.cloud/api/v1` (override via `--dart-define=API_BASE_URL`). Production API reachable; customer, admin, staff, kitchen, reporting, and payment endpoints in active use. |
| **Authentication & Sessions** | **Fully implemented** | Backend JWT (access + refresh) with `flutter_secure_storage` persistence, single app-wide `TokenRefreshCoordinator`, cold-start session bootstrap, and **biometric login gate** (`local_auth`). Google Sign-In, Apple Sign-In, and guest sessions. |
| **Order Status / Tracking** | **Implemented** | Delivery and Pickup have distinct fulfillment-typed status sequences. Live order-status polling with bounded exponential backoff in the tracking screen; admin/kitchen status transitions validated client-side against the backend's allowed-transitions table. |
| **Payments** | **Implemented (live gateway)** | Moyasar card payments (`moyasar` SDK) via backend-issued payment intents; saved cards + 3DS challenge; CASH instructions; Apple Pay button in card checkout. |
| **Push Notifications & FCM** | **Fully configured** | Firebase Cloud Messaging, foreground banners via `flutter_local_notifications`, background/terminated handlers, deep-link routing, admin NEW_ORDER push that refreshes the admin inbox. |
| **Android Home-Screen Widget** | **Implemented** | `home_widget`-based order-tracking widget with tap-through routing to the tracked order. |
| **Maps & Delivery** | **Implemented** | Google Maps address picker, geocoding/reverse-geocoding, distance-based **delivery quote** at checkout (`POST /delivery/quote`). |
| **Mock / Fake repositories** | **Present as dead files only** | `Fake*Repository` implementations still exist under `lib/features/shared/data/` but are **no longer wired into DI** — every `providers.dart` mapping points to an `Api*Repository`. Do not mistake their presence for `src/main` usage. A single unreachable branch in `menu_admin_notifier.dart` (`is FakeMenuRepository`) is the only production reference left and never executes. |

### What changed since the previous (2026-07-23) audit

The July audit described the app as **frontend-only with local fake repositories and "BACKEND NOT IMPLEMENTED."** That is no longer accurate. Since then, the backend migration (Phases 2–8) completed and every repository in `lib/core/di/providers.dart` is an `Api*Repository` hitting the live backend. This rewrite corrects the record: reads, writes, auth sessions, payments, notifications, and role-based access are all **real and network-backed**. The `docs/`/root-level integration guides (`API_INTEGRATION_GUIDE.md`, `KZ_API_CONTRACT_FOR_FLUTTER.md`, `FLUTTER_BACKEND_COMPARISON_AUDIT.md`, `FRONTEND_BACKEND_INTEGRATION_PLAN.md`, `IOS_MAC_HANDOFF.md`, `ANDROID_PLAY_STORE_HANDOFF.md`) are the source of truth for contract details; this file is the current-state snapshot.

---

## 2. PROJECT STRUCTURE (current)

```text
kebda_zaman/
├── android/                          # Android build config (release-signed, Play-ready)
│   ├── app/google-services.json      # Real Firebase Android config
│   ├── app/build.gradle.kts          # applicationId com.kebdtzaman.app, AGP 8.7.3
│   └── key.properties (gitignored)   # Real upload keystore for release builds
├── assets/
│   ├── fonts/                        # Alexandria (AR), Plus Jakarta Sans (EN), Readex Pro (registered)
│   ├── translations/{ar,en}.json     # 100% translation dictionaries
│   ├── mock/, photos/, lottie/, images/
├── lib/
│   ├── main.dart                     # Entry: ZonedGuard, EasyLocalization, Notifications init
│   ├── app.dart                      # MaterialApp.router, KZ ThemeData, locale->font resolution
│   ├── bootstrap.dart / firebase_options.dart
│   ├── core/
│   │   ├── api/                      # Dio ApiClient + AuthInterceptor + RetryInterceptor +
│   │   │                             # TokenRefreshCoordinator + SafeLogInterceptor + ApiConfig + exceptions
│   │   ├── di/providers.dart         # DI registry (all Api* implementations)
│   │   ├── errors/                   # Failure types + Result<T> sealed classes
│   │   ├── theme/kz_design_system.dart, kz_motion.dart
│   │   ├── router/router.dart        # GoRouter: customer shell + admin shell + role redirects
│   │   ├── session/session_coordinator.dart  # root auth lifecycle listener
│   │   ├── notifications/            # FCM service, model, navigation, permission service
│   │   ├── home_widget/              # home-widget service + sync provider
│   │   ├── responsive/, services/ (biometric), utils/ (currency, dates, maps)
│   │   └── widgets/                  # KZ button, card, chip, product card, state views, etc.
│   ├── features/
│   │   ├── shared/                   # Cross-feature models + repositories
│   │   │   ├── domain/models/        # user, address, category, menu_item, cart, order,
│   │   │   │                         # payment, loyalty, promo_code, menu_offer, delivery_quote,
│   │   │   │                         # notification, restaurant_settings, reverse_geocode_result
│   │   │   ├── domain/repositories/  # Abstract contracts
│   │   │   └── data/                 # Api*Repository implementations + (unwired) Fake*Repository
│   │   ├── customer/                 # Customer UI: notifiers + screens + shell + auth services
│   │   └── admin/                    # Admin UI: notifiers + screens + shells
├── test/                             # Widget/notifier/mapper tests
└── *.md                              # Contract, handoff, integration docs (see §11)
```

---

## 3. DI / REPOSITORY LAYER — What Is Actually Wired

`lib/core/di/providers.dart` is the single DI registry. **Every provider resolves to a real API implementation** against `ApiClient` (Dio + interceptors). There are no fake implementations in the production wiring.

| Provider | Implementation | Notes |
| :--- | :--- | :--- |
| `apiClientProvider` | `ApiClient` | Dio + AuthInterceptor + RetryInterceptor + SafeLogInterceptor |
| `tokenRefreshCoordinatorProvider` | `TokenRefreshCoordinator` | **Reuses the single instance inside ApiClient** — cold-start bootstrap and 401-interceptor refreshes share one coordinator so rotating refresh tokens can never race. |
| `authRepositoryProvider` | `ApiAuthRepository` | email/password, Google, Apple, admin, guest, register, logout, `GET /users/me`, profile PATCH, account deletion |
| `menuRepositoryProvider` | `ApiMenuRepository` | categories, menu items, featured, search, admin CRUD, image upload |
| `cartRepositoryProvider` | `ApiCartRepository` | get cart, add item, update, remove, promo apply/remove, clear |
| `orderRepositoryProvider` | `ApiOrderRepository` | checkout (idempotent), order detail, status-poll, admin order list/detail, kitchen |
| `paymentRepositoryProvider` | `ApiPaymentRepository` | payment intent, confirm, saved cards, charge (3DS) |
| `deviceRepositoryProvider` | `ApiDeviceRepository` | FCM device token register/refresh/delete (configures `DeviceService`) |
| `addressRepositoryProvider` | `ApiAddressRepository` | `/me/addresses` CRUD + set-default |
| `reverseGeocodeRepositoryProvider` | `ApiReverseGeocodeRepository` | lat/lng → address text |
| `favoritesRepositoryProvider` | `ApiFavoritesRepository` | `/me/favorites` list + toggle |
| `loyaltyRepositoryProvider` | `ApiLoyaltyRepository` | balance + transactions |
| `promoRepositoryProvider` | `ApiPromoRepository` | admin promo CRUD |
| `deliveryQuoteRepositoryProvider` | `ApiDeliveryQuoteRepository` | `POST /delivery/quote` (lat/lng → fee + ETA) |
| `settingsRepositoryProvider` | `ApiSettingsRepository` | public settings + admin settings |
| `adminNotificationRepositoryProvider` | `ApiAdminNotificationRepository` | campaign send/schedule/list/delete |
| `adminOrderNotificationRepositoryProvider` | `ApiAdminOrderNotificationRepository` | admin inbox, unread count, mark read, delete |
| `staffRepositoryProvider` | `ApiStaffRepository` | staff list/create/update |
| `kitchenRepositoryProvider` | `ApiKitchenRepository` | kitchen queue + ticket |
| `customerRepositoryProvider` | `ApiCustomerRepository` | customer list/detail/status update |
| `reportsRepositoryProvider` | `ApiReportsRepository` | overview, sales, orders breakdown, top items |
| `adminMenuOfferRepositoryProvider` | `ApiMenuOfferRepository` | menu-offer CRUD |
| `restaurantSettingsProvider` | `FutureProvider` | public `GET /settings` for checkout/UI |

**Remaining fake references:** the `Fake*Repository` classes still exist on disk (kept as reference/scaffolding) and `menu_admin_notifier.dart:60` contains an `is FakeMenuRepository` branch that can never execute against the wired DI. They are not imported by `providers.dart`.

### API endpoint inventory (verified from source)

**Customer / shared**
- `POST /auth/login`, `/auth/google`, `/auth/apple`, `/auth/register`, `/auth/guest`, `/auth/logout`, `DELETE /auth/account`
- `GET /users/me`, `PATCH /users/me`
- `GET /categories`, `/categories/:id`, `GET /menu/items/:id`, `GET /home/featured`, `GET /menu-offers`, `GET /menu/search?q=`
- `GET /cart`, `POST /cart/items`, `DELETE /cart/items/:id`, `POST /cart/promo`, `DELETE /cart/promo`, `DELETE /cart`
- `POST /checkout` (with `Idempotency-Key` header), `GET /orders/:id`, `GET /orders/:id/status`
- `POST /delivery/quote` — distance-based delivery fee + ETA (latitude/longitude)
- `GET /me/addresses`, `PATCH /me/addresses/:id/default`, `PATCH /me/addresses/:id`, `DELETE /me/addresses/:id`
- `GET /me/favorites`, `DELETE /me/favorites/:menuItemId`
- `GET /me/loyalty`, `GET /me/loyalty/transactions`
- `POST /payments/intent`, `GET /payments/:id`, `GET /payments/cards`, `POST /payments/:orderId/cards/:cardId/charge` (with 3DS `transactionUrl`), plus `POST /payments/:orderId/confirm`
- `POST /devices/token`, `PUT /devices/token`, `DELETE /devices/token`
- `GET /settings` (public restaurant settings)

**Admin / staff**
- `GET /admin/categories`, `POST /admin/categories`, `PUT/PATCH /admin/categories/:id`, `DELETE /admin/categories/:id`
- `GET /admin/menu`, `GET /admin/menu/items`, `POST /admin/menu/items`, `PUT /admin/menu/items/:id`, `DELETE /admin/menu/items/:id`, `POST /admin/uploads/image`
- `GET /admin/menu-offers`, `POST /admin/menu-offers`, `PUT/PATCH /admin/menu-offers/:id`, `DELETE /admin/menu-offers/:id`
- `GET /admin/orders`, `GET /admin/orders/:id` (+ status update)
- `GET /kitchen/orders`, `GET /kitchen/orders/:id`
- `GET /admin/promos`, `POST /admin/promos`, `PUT /admin/promos/:id`, `DELETE /admin/promos/:id`
- `POST /admin/notifications/send`, `POST /admin/notifications/schedule`, `GET /admin/notifications/campaigns`, `DELETE /admin/notifications/campaigns/:id`
- `GET /admin/notifications` (inbox), `GET /admin/notifications/unread-count`, `PATCH /admin/notifications/:id/read`, `PATCH /admin/notifications/read-all`, `DELETE /admin/notifications`
- `GET /admin/settings`, `PUT /admin/settings`
- `GET /admin/staff`, `POST /admin/staff`, `PATCH /admin/staff/:id`
- `GET /admin/customers`, `GET /admin/customers/:id`, `PATCH /admin/customers/:id`
- `GET /admin/reports/overview`, `/admin/reports/sales?groupBy=`, `/admin/reports/orders`, `/admin/reports/top-items?limit=`

> **Note:** the exact HTTP verb per endpoint/mapping lives in the repositories; the table above groups them by path. Where both `PUT` and `PATCH` show for a path, read the specific repository file to confirm the exact verb used.

---

## 4. AUTHENTICATION & SESSION FLOW (current)

- **Backend-issued JWT.** Login/register/Google/Apple/guest all call `ApiAuthRepository._handleAuthResult`, which stores the **refresh token durably in `flutter_secure_storage` first**, then exposes the access token in the in-memory `TokenStorage`. Atomic ordering prevents a process-death window where the app has an access token but no persisted refresh token.
- **AuthInterceptor** attaches the access token to every request; on 401 it routes through the **single `TokenRefreshCoordinator`** (rotates refresh token, re-queues the original request). On a definitive reject it clears local session state.
- **Cold-start bootstrap (`SessionBootstrapNotifier`):** runs exactly once per process *before* any authenticated request. Reads the saved-session flag → refresh token → checks the **biometric gate** (`BiometricPreferenceStore` + `local_auth`) for the cached user → refreshes via the shared coordinator → `AuthNotifier.confirmRestoredSession()` (re-validates the profile via `GET /users/me`) or `clearLocalSession()`.
  - `recoverableError` (transient network) keeps the user on the splash with a Retry — never force-logged-out on a momentary blip; only a genuine auth rejection logs out.
- **Role-based routing** (`router.dart` redirect): unauth → `/login`; `ADMIN` full admin access; `CASHIER` confined to `/admin/orders`; `KITCHEN` confined to `/admin/kitchen`; any other authenticated role → `/home`.
- **Session lifecycle (`session_coordinator.dart`):** one root `Provider` watches `authNotifierProvider` and reacts to login/logout/user-switch by reloading or clearing the customer-scoped providers (Favorites, Addresses, Cart, Orders, Loyalty, Checkout). ADMIN/CASHIER/KITCHEN sessions never trigger `/me/*` loads.
- **Logout:** order is device-token DELETE (while access token valid) → backend `/auth/logout` → best-effort Google sign-out → clear local prefs → disable biometric preference.
- **Google/Apple sign-in:** client obtains a Firebase ID token (`GoogleAuthService`/`AppleAuthService`), backend derives identity from the verified token and issues the session (`INVALID_GOOGLE_TOKEN` / `INVALID_APPLE_TOKEN` mapped to friendly localized errors).
- **Account deletion:** `DELETE /auth/account`; 403 `GUEST_NOT_ELIGIBLE` / 409 `ACTIVE_ORDER_EXISTS` are surfaced distinctly (never force logout for those), and local biometric artifacts are cleared per deleted user id.

---

## 5. CUSTOMER APP — COMPLETE FEATURE INVENTORY

| Feature Screen | File Path | Implementation Status | Data Source | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Splash** | `splash_screen.dart` | Implemented | `SessionBootstrapNotifier` + SharedPreferences | Brand logo scale-in; navigates only when bootstrap settles; retry UI on recoverable errors; routes by language/onboarding/biometric requirements. |
| **Language Select** | `language_select_screen.dart` | Implemented | `easy_localization` | First-run locale choice. |
| **Onboarding** | `onboarding_screen.dart` | Implemented | Local assets | 3-slide intro. |
| **Auth Choice** | `auth_choice_screen.dart` | Implemented | Local state | Hub. (Skipped on first launch when onboarding/auth state is already settled — Apple review compliance fix.) |
| **Login / Signup** | `login_screen.dart`, `signup_screen.dart` | Implemented | `AuthNotifier`, API | Email/password + Google + Apple; biometric re-auth for gated sessions; localized error mapping. |
| **Home** | `home_screen.dart` | Implemented | `homeDataProvider` (API `GET /home/featured`, menu, offers) | Greeting header, dynamic promo hero (real offer/featured item), Featured Meals showcase, Best Sellers, Promotions strip, Recently Ordered (from past orders), Popular Items; responsive grid/list; closed-notice banner driven by `acceptingOrders`; cart badge; search entry; address selector. |
| **Menu Catalog** | `menu_screen.dart` | Implemented | `ApiMenuRepository` | Categories + items, sticky search, discount pricing (`salePrice`), badge chips, calories/compare-at. |
| **Item Details / Customization** | `item_details_screen.dart` | Implemented | `ApiMenuRepository`, cart | Modifier groups (variants, add-ons, nested modifiers), quantity, add-to-cart, "often ordered with". |
| **Search** | `search_screen.dart` | Implemented | `ApiMenuRepository.searchItems` | Live search. |
| **Favorites** | `favorites_screen.dart` | Implemented | `ApiFavoritesRepository` | `/me/favorites`. |
| **Cart** | `cart_screen.dart` | Implemented | `ApiCartRepository` | Server-computed `subtotal`/`discountTotal`/`taxTotal`/`grandTotal`; promo apply/remove; "was/now" pricing. |
| **Checkout** | `checkout_screen.dart` | Implemented | `ApiCartRepository`, `ApiDeliveryQuoteRepository`, `ApiOrderRepository`, `ApiLoyaltyRepository` | Delivery vs Pickup; address picker; **delivery quote** (distance-based, re-fetched on address/method change); promo ↔ loyalty-reward mutual exclusivity (server re-prices authoritatively); `POST /checkout` with idempotency key. |
| **Order Success** | `order_success_screen.dart` | Implemented | Order passed via route extra | Receipt summary. |
| **Card Payment** | `card_payment_screen.dart`, `saved_card_3ds_screen.dart` | Implemented | `ApiPaymentRepository` (Moyasar) | Payment intent → Moyasar SDK → backend confirm; saved-card charge w/ optional 3DS; Apple Pay. |
| **Saved Cards** | `saved_cards_screen.dart` | Implemented | `ApiPaymentRepository` | Brand/last-four/expiry (no full PAN client-side). |
| **Order Tracking** | `order_tracking_screen.dart` | Implemented | `ApiOrderRepository` (10s polling w/ bounded backoff) | Fulfillment-aware timeline (Delivery: pending→…→delivered; Pickup: pending→…→pickedUp); resilient retry up to 5 consecutive transient failures. |
| **Orders** | `orders_screen.dart` | Implemented | `ApiOrderRepository` | Active + history; reorder (skips items with missing `menuItemId`). |
| **Profile / Settings** | `profile_screen.dart`, `settings_screen.dart` | Implemented | `ApiAuthRepository.updateProfile`, local prefs | Name/phone, addresses, favorites, loyalty, payment methods, language toggle, logout, **account deletion**. |
| **Addresses / Address Form** | `addresses_screen.dart`, `address_form_screen.dart` | Implemented | `ApiAddressRepository`, Google Maps picker | CRUD + set-default; map pin + reverse geocode. |
| **Loyalty** | `loyalty_screen.dart` | Implemented | `ApiLoyaltyRepository` | Points balance + transactions + redeem rewards. |
| **Legal** | `privacy_policy_screen.dart`, `terms_of_service_screen.dart` | Implemented | Static / `legal_config.dart` | In-app privacy + ToS (Play/App Store requirement). |

---

## 6. ADMIN PANEL — COMPLETE FEATURE INVENTORY

All admin screens are wrapped in `AdminShell` (responsive sidebar on desktop, drawer + top bar on mobile). Owner role required for most; **CASHIER** sees only Orders; **KITCHEN** sees only the Kitchen queue (router redirects enforce this too).

| Admin Screen | File Path | Data Source / Repository | Features & Controls |
| :--- | :--- | :--- | :--- |
| **Dashboard** | `dashboard_screen.dart` | `ApiReportsRepository`, orders | Quick-stat cards + live overview data. |
| **Reports & Analytics** | `reports_dashboard_notifier.dart` (drives dashboard) | `ApiReportsRepository` | Overview, sales by period/groupBy, orders breakdown, top-selling items. |
| **Menu Management** | `menu_management_screen.dart` | `ApiMenuRepository` | Searchable/filterable item table, availability toggles, edit/delete/add. |
| **Food Item Form** | `admin_food_form_screen.dart` | `ApiMenuRepository` | AR/EN names+descriptions, basePrice, `salePrice`, compareAt, calories, badge, images, modifiers. |
| **Category Form** | `admin_category_form_screen.dart` | `ApiMenuRepository` | AR/EN name, icon, order. |
| **Menu Offers** | `menu_offers_screen.dart` + `admin_menu_offer_form_screen.dart` | `ApiMenuOfferRepository` | Catalog "menu offer" CRUD (item + image + title + window + sort). |
| **Order Management** | `order_management_screen.dart` + `admin_order_details_screen.dart` | `ApiOrderRepository` | Fulfillment-aware status board; next-status transitions validated client-side against the backend's allowed-transitions table (never offers an illegal cross-method move). |
| **Kitchen Queue / Ticket** | `kitchen_queue_screen.dart`, `kitchen_ticket_screen.dart` | `ApiKitchenRepository` | `GET /kitchen/orders` queue, per-ticket detail with status progress. |
| **Offers & Promos** | `offers_screen.dart` + `admin_promo_form_screen.dart` | `ApiPromoRepository` | Promo code CRUD. |
| **Push Notifications** | `admin_notifications_screen.dart` | `ApiAdminNotificationRepository` | Campaign composer with live phone preview, send/schedule, campaign history. |
| **Notification Center** | `admin_notification_center_screen.dart` (AdminOrderNotificationNotifier) | `ApiAdminOrderNotificationRepository` | Inbox, unread badge, mark-read, delete. Refreshed in place by foreground FCM `NEW_ORDER` pushes. |
| **Restaurant Profile** | `restaurant_profile_screen.dart` | `ApiSettingsRepository` | Restaurant settings form. |
| **Working Hours** | `working_hours_screen.dart` | `ApiSettingsRepository` | Operating hours config (drives home "closed" banner). |
| **Order Settings** | `order_settings_screen.dart` | `ApiSettingsRepository` | Order-related configuration. |
| **Pricing Settings** | `pricing_settings_screen.dart` | `ApiSettingsRepository` | Distance-pricing / fee configuration. |
| **Staff Management** | `staff_management_screen.dart` | `ApiStaffRepository` | Staff list/create/update (email-conflict & not-found mapped to typed failures). |
| **Customer Management** | `customer_management_screen.dart`, `customer_details_screen.dart` | `ApiCustomerRepository` | Customer list/detail + status update. |

**Roles** (`auth.user.role`): `ADMIN` (all), `CASHIER` (orders only, single-destination shell), `KITCHEN` (queue/tickets only). Guests and customers are issued role `CUSTOMER` and are never routed into `/admin/*`.

---

## 7. DATA MODELS (verified — `lib/features/shared/domain/models/`)

All models are `freezed` + `json_serializable` with generated `*.freezed.dart` / `*.g.dart` companions. Key ones:

- **`User`** — `id`, `phone?`, `name`, `email?`, `addressIds[]`, `favoriteItemIds[]`, `loyaltyAccountId?`, `role?`, **`isGuest`** (backend-authoritative), `createdAt`.
- **`MenuItem`** — `id`, `categoryId`, `name`, `description`, `imageUrl`, `basePrice`, **`discountPrice?`** (wire `salePrice`; strictly below basePrice server-side), `isAvailable`, `isFeatured`, `isBestSeller`, `prepTimeMinutes`, **`modifierGroups`** (`ModifierGroup` → `ModifierOption` w/ `selectionType` SINGLE/MULTIPLE/QUANTITY, min/max, nested groups), `sortOrder`, `calories?`, `compareAtPrice?`, `badge?` (`MenuItemBadge` bestseller/topRated), `oftenOrderedWith[]`, AR/EN localized content. Locale-aware `localizedName`/`localizedDescription`.
- **`Order`** — `id`, `orderNumber`, `userId`, `items[]`, **`fulfillmentType`** (delivery|pickup), `addressId?`, `pickupLocation?`, **`deliveryAddress` snapshot** (tolerant `fromBackendJson`), `status` (`OrderStatus` incl. `readyForPickup`, `pickedUp`, `unknown`), `subtotal`, `deliveryFee`, **distance-pricing snapshot** (`deliveryDistanceMeters/Km`, `deliveryDurationSeconds`, `deliveryTier`, deprecated zone snapshot), `discountTotal`, loyalty points used/earned, `grandTotal`, payment fields (method, status, `paymentAuthorizedAt`), `placedAt`, `statusHistory[]`, `estimatedTime`, `loyaltyRedemption?`. **Fulfillment-aware status sequences** and client-side allowed-next-transition rules mirror the backend.
- **`Cart`/`CartItem`** — server-computed totals (`deliveryFee`, `subtotal`, `discountTotal`, `taxTotal`, `grandTotal`); item carries `selectedOptions`, `nestedSelections`, `extraQuantities`, `removedIngredients`, `specialInstructions`, `unitPrice`, `lineTotal`, plus display-only `menuItemBasePrice`/`menuItemDiscountPrice` for "was/now" strikes. `configurationSignature` used for line reuse/dedup.
- **`PaymentIntent` / `Payment` / `SavedCard` / `CardChargeResult`** — backend-issued intents; `providerData` handed verbatim to Moyasar (never constructed client-side); card charge may return a 3DS `transactionUrl`.
- **`DeliveryQuote`** — distance-based fee result.
- **`Address`**, **`Category`** (AR/EN name + icon + order), **`PromoCode`**, **`LoyaltyAccount`/transactions**, **`RestaurantSettings`**, **`MenuOffer`** (+ item summary), **`Notification`** (customer), **`ReverseGeocodeResult`**.

---

## 8. STATE MANAGEMENT & NAVIGATION

### State (Riverpod)

- `StateNotifier`/`AsyncNotifier`/`FutureProvider` across features; codegen (`riverpod_annotation`, `freezed`, `json_serializable`) via `build_runner`; generated `router.g.dart`.
- User-scoped providers (Favorites, Addresses, Cart, Orders, Loyalty, Checkout) are lifecycle-managed by `sessionLifecycleProvider` (see §4).
- `DeviceService` (FCM token registration) is configured from `deviceRepositoryProvider` and driven by auth transitions (`onSessionEstablished`, `onBeforeLogout`, `onSessionInvalidated`).

### Routing (GoRouter 14.x)

- `initialLocation: /splash`. **Redirect** enforces admin role access (see §4).
- Root `StatefulShellRoute.indexedStack` = `CustomerShell` with 4 branches: Home (→ Menu), Menu, Orders (→ Tracking), Profile (→ Settings, Loyalty, Favorites, Payment Methods, Addresses + add/edit).
- Auth/transaction routes (`/login`, `/signup`, `/search`, `/cart`, `/item/:id` [+ 2 alt paths], `/checkout` + success/card-payment, `/legal/*`) use shared fade-slide transitions.
- `ShellRoute` = `AdminShell` hosting all `/admin/*` pages.
- Custom page transitions: `kzFadeSlidePage`, `kzAdminPage` (`core/router/kz_page_transitions.dart`).

---

## 9. PAYMENTS & CHECKOUT (current behavior)

- Payment is **backend-orchestrated**: `POST /payments/intent` returns opaque `providerData` (publishable key, smallest-unit amount, currency, orderId, optional description/callbackUrl) that the app hands to the Moyasar SDK. A Moyasar callback alone is **never** treated as final — only the backend's re-verified `POST /payments/:orderId/confirm` / `GET /payments/:id` Payment record matters.
- CASH intents carry `instructions` copy; there is "Pay with cash upon delivery", Apple Pay in card checkout, and a **saved-cards** flow (brand/last4/expiry only) with a 3DS challenge hop when required.
- Checkout server-side authoritativeness: the backend recalculates subtotal, promos, loyalty rewards, delivery fee, tax, and total; the UI only previews. `POST /checkout` sends an `Idempotency-Key` to survive retries.

---

## 10. NOTIFICATIONS & HOME WIDGET (current behavior)

- **FCM messaging pipeline** in `NotificationService`: initialize Firebase → local-notifications channel → background `firebaseMessagingBackgroundHandler` (separate isolate; data-only messages synthesize a local notification; `notification:`-block messages are left to the OS to avoid duplicates) → foreground `onMessage` banner → `onMessageOpenedApp` + cold-start `getInitialMessage` deep-links → `NotificationNavigationService` routes by payload.
- **Admin push synergy:** foreground `NEW_ORDER` type invalidates the admin order-notification providers (inbox + unread count) via the attached `ProviderContainer`.
- **Android home-screen widget:** `HomeWidgetService` syncs the latest tracked order; taps route through `handleWidgetUri` (mirrors notification deep-link handling) including cold-start-from-widget. `homeWidgetSyncProvider` keeps the widget in sync with the active order.
- **Permission UX:** `NotificationPermissionService` gates the system prompt; biometric preference store managed in `core/services/`.

---

## 11. RELEVANT DOCUMENTS / CONTRACTS

| Document | Purpose |
| :--- | :--- |
| `API_INTEGRATION_GUIDE.md` | End-to-end Flutter↔API integration reference. |
| `KZ_API_CONTRACT_FOR_FLUTTER.md` | REST contract: routes, DTO shapes, error codes. |
| `FLUTTER_BACKEND_COMPARISON_AUDIT.md` | Contract drift/parity audit. |
| `FRONTEND_BACKEND_INTEGRATION_PLAN.md` | Integration migration plan. |
| `IOS_MAC_HANDOFF.md` | Apple release/handoff notes (privacy labels, App Store). |
| `ANDROID_PLAY_STORE_HANDOFF.md` | Play Console release/handoff notes (package `com.kebdtzaman.app`, AGP 8.7.3, 16 KB page-size, signed AAB). |
| `docs/` | Backend contract + reference docs (03_DTO_REFERENCE, 05_ORDER_LIFECYCLE, 08_NOTIFICATION_REFERENCE, etc.). |

---

## 12. HEALTH CHECK (verified 2026-08-29)

- **`flutter analyze` → 0 errors.** 85 infos/warnings, all stylistic/non-blocking: `prefer_const_constructors`, deprecated `withOpacity`/`activeColor`/`cacheExtent`, a few `use_build_context_synchronously`/`unawaited_return_in_try_block`, one unused import (`item_details_screen.dart`), `avoid_print` in tests/scratch files, `http` referenced from `ping_test.dart`. Nothing blocks a build.
- **Build config:** `pubspec.yaml` version `1.0.0+3`; Android `applicationId com.kebdtzaman.app`, `compileSdk/targetSdk 36`, AGP 8.7.3, release signing configured (`.gitignore`d keystore); `enable-swift-package-manager: false` (CocoaPods-only plugin integration) with an explanatory comment.
- **Generated code note:** `router.g.dart`, `*.freezed.dart`, `*.g.dart` are checked in; regenerate via `dart run build_runner build`.

---

## 13. KNOWN TAIL & FOLLOW-UPS (non-blocking)

1. **Stale helpers:** the `Fake*Repository` classes and the `is FakeMenuRepository` branch in `menu_admin_notifier.dart` are dead in the wired DI — remove only when ready; they remain as reference/scaffolding and are harmless.
2. **Analyzer hygiene:** ~85 info/warnings (see §12) — a clean-sweep pass would address deprecations (`withValues`, `activeThumbColor`, `scrollCacheExtent`) and minor style nits.
3. **Live-data caveats:** distance-pricing (delivery fee/ETA) and payment behavior depend on the live backend contract; the client handles null snapshots tolerantly for older/legacy orders.
4. **This document** supersedes the 2026-07-23 audit, which incorrectly reported an unbuilt backend. Future audits should update only what actually changed, not re-describe the architecture.

---

## 14. FINAL CURRENT STATE SUMMARY

- **What is live:** a production Flutter app (customer + admin in one binary) talking to `https://api.kebdazaman.cloud/api/v1` over authenticated JWT sessions with refresh rotation, Google/Apple/guest auth, biometric re-auth, real Moyasar payments, FCM pushes, an Android order-tracking home widget, Google Maps address selection, distance-based delivery quotes, and role-based admin surfaces (ADMIN/CASHIER/KITCHEN) with reporting.
- **What is mock:** nothing is wired to mock data in production; fake repositories remain as dead files only.
- **What must not be changed casually:** route names and `AppNotificationPayload` parsing (deep-link destinations), the single-shared-`TokenRefreshCoordinator` invariant, token-write ordering in `ApiAuthRepository`, and the client-side allowed-transition validation in the order model.