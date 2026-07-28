# Kebda Zaman Flutter ↔ Backend Integration Audit

## Audit Metadata

- **Flutter repository:** `Ahmedkhalaf2-1/kebda_zaman_frontend`
- **Branch:** `main`
- **Flutter commit:** `55f2dd29f12f021b4d97482f7098c7ec430e2416`
- **Backend contract target:** Kebda Zaman NestJS API under `/api/v1`
- **Audit type:** Static source-code audit
- **Runtime status:** `flutter analyze`, unit tests, widget tests, and live API calls were **not executed** in this environment.
- **Modification status:** No Flutter or backend source files were modified.

---

# 1. Executive Summary

The Flutter project already has a serious real-API foundation:

- One shared Dio client.
- Access-token injection.
- Single-flight refresh-token coordination.
- API repositories for Auth, Menu, Cart, Orders, Addresses, Favorites, Loyalty, Settings, Devices, and Promos.
- Server-backed Favorites and Loyalty repository classes.
- Checkout idempotency support.
- CARD/WALLET UI disabled while the backend provider is unavailable.

However, multiple UI flows still bypass those real repositories or hide backend failures. The most important confirmed defects are:

1. **Favorites are split between three state systems.**
   - Home uses the real `customerFavoritesProvider`.
   - Menu uses a local `StateProvider<Set<String>>`.
   - Item Details uses a local `StateProvider.family<bool, String>`.
   - Therefore Menu and Item Details can appear to toggle Favorites without making any backend request.

2. **Loyalty API failures are converted into fake successful values.**
   - Account failure becomes `0` points.
   - Transaction-history failure becomes an empty list.
   - This directly explains why loyalty can appear to disappear after logout/login or during transient API/session problems.

3. **User-scoped providers are not consistently reset or reloaded when authentication changes.**
   - Favorites and Addresses load once in their constructors.
   - They read auth state rather than react to it.
   - Logout clears auth tokens/profile but does not clear Favorites, Addresses, Cart, Orders, or Loyalty state.
   - This can cause stale data, cross-user data display, and missing rehydration after login.

4. **The generic retry interceptor can retry unsafe requests.**
   - It retries all connection failures and HTTP 5xx responses.
   - It does not restrict retries by HTTP method or endpoint.
   - This is especially dangerous for `/auth/refresh`, because refresh tokens rotate and are single-use.

5. **Several models and tests do not match the actual API contract.**
   - Loyalty models fabricate fields not returned by the backend.
   - User model drops `avatarUrl`, `locale`, and explicit `isGuest`.
   - Favorites and Loyalty “API tests” actually test fake repositories.

The project is not blocked by architecture. Most defects can be corrected inside the existing Riverpod + repository structure without changing navigation, backend contracts, or overall architecture.

---

# 2. Priority Classification

## P0 — Must Fix Before Release

| ID | Area | Confirmed defect | Primary files |
|---|---|---|---|
| P0-01 | Favorites | Menu favorite button changes local state only; no API call | `menu_screen.dart` |
| P0-02 | Favorites | Item Details favorite button changes local state only; no API call | `item_details_screen.dart` |
| P0-03 | Loyalty | API failures are converted to zero points and empty history | `loyalty_notifier.dart` |
| P0-04 | Session isolation | Logout/login does not centrally clear and reload user-scoped providers | `auth_notifier.dart`, Favorites, Addresses, Loyalty |
| P0-05 | Session safety | Retry interceptor may retry `/auth/refresh` and non-idempotent POSTs | `api_interceptors.dart` |
| P0-06 | Privacy | Address state can remain from a previous user because it is not auth-reactive | `address_notifier.dart` |
| P0-07 | Admin catalog | Menu update omits nested variants/add-ons; may delete them if backend PUT is full replacement | `api_menu_repository.dart` — backend behavior must be reverified |

## P1 — High Priority

| ID | Area | Defect |
|---|---|---|
| P1-01 | Auth | Token persistence is started but not awaited before login succeeds |
| P1-02 | Favorites | Provider loads only once and does not react to session restoration/user switching |
| P1-03 | Loyalty | Model mapping fabricates `lifetimePointsEarned`, `balanceAfter`, and blank `userId` |
| P1-04 | User model | Backend `isGuest`, `avatarUrl`, and `locale` are not modeled directly |
| P1-05 | Orders | `OrderItem.menuItemId` is populated using the order-item row ID |
| P1-06 | Cart | Editing a cart item removes then re-adds it; failure after removal loses the line |
| P1-07 | Role UX | Admin routes have no client-side role redirect and Dashboard is shown to customers |
| P1-08 | Configuration | API URL silently falls back to a LAN address |
| P1-09 | Testing | Favorites/Loyalty API tests test fake repositories, not the actual API repositories |

## P2 — Cleanup / Consistency

- Remove unused fake imports and stale comments.
- Replace hardcoded EGP labels with server/configured currency.
- Remove hidden error states such as `SizedBox()` on Loyalty failure.
- Reduce unnecessary refetches after mutations that already return complete server state.
- Consolidate duplicated MenuItem JSON mappers.

---

# 3. Confirmed Correct Foundations

These areas should be preserved rather than redesigned.

## 3.1 Shared API client

`lib/core/api/api_client.dart`

- A single Dio instance is created.
- The same `TokenRefreshCoordinator` is shared with the interceptor and session bootstrap.
- Auth and retry interceptors are centralized.

## 3.2 Single-flight refresh coordination

`lib/core/api/token_refresh_coordinator.dart`

- Concurrent refresh attempts join one in-flight Future.
- A rotated refresh token is written before refresh success is returned.
- Definitive 401 refresh rejection clears the local session token.

## 3.3 Cold-start session restoration

`lib/features/customer/presentation/notifiers/session_bootstrap_notifier.dart`

- Saved-session state is checked once.
- Refresh occurs before authenticated session confirmation.
- Successful refresh is followed by `/users/me`.

## 3.4 Real repository bindings

`lib/core/di/providers.dart`

The following providers already resolve to real API implementations:

- Auth
- Menu
- Cart
- Orders
- Devices
- Addresses
- Favorites
- Loyalty
- Promo
- Settings
- Admin notifications

Do not replace Riverpod or redesign this DI layer. Correct the state lifecycle and individual integrations.

## 3.5 Favorites API repository contract

`lib/features/shared/data/api_favorites_repository.dart`

The repository correctly uses:

```http
GET /me/favorites
POST /me/favorites
DELETE /me/favorites/:menuItemId
```

The POST request correctly sends:

```json
{
  "menuItemId": "<UUID>"
}
```

The POST response is correctly parsed as the full updated list.

## 3.6 Checkout idempotency

`lib/features/shared/data/api_order_repository.dart`

Checkout sends an `Idempotency-Key`, which should be retained.

---

# 4. Favorites — End-to-End Audit

## 4.1 Current state systems

There are currently three independent favorite-state sources:

### A. Canonical real API state

```text
customerFavoritesProvider
```

Defined in:

```text
lib/features/customer/presentation/notifiers/favorites_notifier.dart
```

Used correctly by Home and Favorites screen.

### B. Menu-only local state

```text
menuFavoritesProvider
```

Defined in:

```text
lib/features/customer/presentation/screens/menu_screen.dart
```

This provider starts as an empty set and is changed only in memory.

### C. Item Details-only local state

```text
itemFavoriteProvider(itemId)
```

Defined in:

```text
lib/features/customer/presentation/screens/item_details_screen.dart
```

This provider starts as `false` for every item and is changed only in memory.

## 4.2 P0-01 — Menu Favorites never reach the backend

**File:**

```text
lib/features/customer/presentation/screens/menu_screen.dart
```

**Relevant lines:**

```text
20–21
43–46
174–188
```

The screen watches `menuFavoritesProvider`, then manually adds/removes IDs from its local Set.

### User impact

- Favorite appears selected in Menu.
- No `POST /me/favorites` or `DELETE /me/favorites/:id` request occurs.
- Favorites screen may not show the item.
- State disappears after app restart.
- Home, Menu, Item Details, and Favorites disagree.

### Required fix

Remove `menuFavoritesProvider`.

Menu must read:

```dart
final favoritesState = ref.watch(customerFavoritesProvider);
final isFavorite = favoritesState.favoriteIds.contains(item.id);
```

The button must await:

```dart
final success = await ref
    .read(customerFavoritesProvider.notifier)
    .toggleFavorite(item.id);
```

Prevent duplicate taps while a mutation is in progress and display a failure message when `success == false`.

## 4.3 P0-02 — Item Details Favorites never reach the backend

**File:**

```text
lib/features/customer/presentation/screens/item_details_screen.dart
```

**Relevant lines:**

```text
19–22
approximately 807–887
```

The screen watches a local boolean family and flips it directly.

### User impact

- Heart changes visually.
- No API call occurs.
- Opening the item again resets the heart.
- Other screens remain unsynchronized.

### Required fix

Delete `itemFavoriteProvider`.

Use `customerFavoritesProvider.favoriteIds` as the only favorite truth.

The heart button must call `toggleFavorite(widget.itemId)` and await the result.

## 4.4 P1-02 — Favorites do not react to auth changes

**File:**

```text
lib/features/customer/presentation/notifiers/favorites_notifier.dart
```

**Relevant lines:**

```text
36–118
```

Problems:

- Provider is not auto-disposed.
- Constructor calls `loadFavorites()` once.
- Auth state is read, not watched.
- No listener reloads after login/session restoration.
- No listener clears data on logout.
- State is not keyed by active user.

### Risk

User A’s favorites can remain visible after logout or when User B logs in until a manual reload occurs.

### Required implementation

Preserve one canonical provider, but make it session-aware.

Acceptable implementation options:

1. Convert to an `AsyncNotifier` that watches authenticated user/session identity.
2. Keep `StateNotifier`, but add a single centralized auth-state listener that:
   - clears immediately on logout;
   - reloads after login/session restoration;
   - reloads when user ID changes.

Do not create more favorite providers.

## 4.5 Favorites acceptance criteria

- [ ] Home, Menu, Item Details, Search, and Favorites all use one canonical provider.
- [ ] Add sends `POST /me/favorites` with `{menuItemId}`.
- [ ] Add consumes the full updated list.
- [ ] Remove sends `DELETE /me/favorites/:menuItemId`.
- [ ] Remove handles `204 No Content`.
- [ ] Every mutation is awaited.
- [ ] Optimistic UI rolls back on failure.
- [ ] API failures are not converted into an empty list.
- [ ] Favorites reload after fresh login.
- [ ] Favorites reload after session restoration.
- [ ] Favorites clear immediately on logout.
- [ ] Switching users cannot show the previous user’s favorites.
- [ ] Rapid repeated taps cannot issue overlapping duplicate mutations.

---

# 5. Loyalty — End-to-End Audit

## 5.1 P0-03 — Backend failures become zero points

**File:**

```text
lib/features/customer/presentation/notifiers/loyalty_notifier.dart
```

**Relevant lines:**

```text
22–58
```

Current behavior:

```dart
final account = accResult.fold(
  (failure) => LoyaltyAccount(pointsBalance: 0, ...),
  (data) => data,
);

final history = histResult.fold(
  (failure) => <LoyaltyTransaction>[],
  (data) => data,
);
```

### User impact

Any of these situations are displayed as a legitimate zero balance:

- access token/session problem;
- network failure;
- backend 500 error;
- parsing error;
- wrong endpoint/model;
- user-specific provider not rehydrated.

This matches the reported behavior where loyalty appears to disappear after logout/login.

### Required fix

Failures must remain failures.

A failure in either required loyalty request should produce `AsyncError`, a typed partial-data state, or a domain result with explicit error metadata.

Never use these fallbacks for an authenticated non-guest user:

```dart
pointsBalance: 0
history: []
```

unless the backend successfully returned those values.

**Current status (2026-07-28): RESOLVED.** `LoyaltyNotifier.build()` (`lib/features/customer/presentation/notifiers/loyalty_notifier.dart:38-48`) now throws the `Failure` from `accResult`/`histResult` instead of folding to a zero balance or empty history, which surfaces as `AsyncError` to the UI. No remaining fallback-to-zero code path found.

## 5.2 Auth dependency is not reactive

The notifier uses:

```dart
final authState = ref.read(authNotifierProvider);
```

It does not rebuild when:

- login succeeds;
- session restoration completes;
- logout occurs;
- active user changes.

### Required fix

Watch a stable session identity:

```text
authenticated user ID + guest state + session generation
```

The provider should:

- return a controlled “authentication required” state for unauthenticated users;
- return a controlled “guest not eligible” state for guests;
- fetch server data for authenticated non-guests;
- clear cached data when the active user changes.

**Current status (2026-07-28): RESOLVED (via a different mechanism than proposed).** The notifier still uses `ref.read(authNotifierProvider)` (not `watch`), but `lib/core/session/session_coordinator.dart` (`sessionLifecycleProvider`, wired in `lib/app.dart:26`) centrally `ref.invalidate(loyaltyProvider)` on login, logout, and user-switch transitions, which disposes the AutoDispose notifier and forces a fresh `build()` with the new auth state. Manually verified this covers logout/login/switch; no separate fix needed here.

## 5.3 P1-03 — Loyalty model mapping fabricates fields

**Files:**

```text
lib/features/shared/data/api_loyalty_repository.dart
lib/features/shared/domain/models/loyalty.dart
```

### Current fabricated values

```dart
lifetimePointsEarned = pointsBalance
userId = ''
balanceAfter = 0
```

The transaction `reason` is discarded and transaction type is inferred only from the sign of `delta`.

### Required model direction

Model the actual API response directly.

Suggested account model:

```dart
LoyaltyAccount {
  String id;
  String userId;
  int pointsBalance;
  DateTime createdAt;
  DateTime updatedAt;
}
```

Suggested transaction model:

```dart
LoyaltyTransaction {
  String id;
  int delta;
  String reason;
  String? orderId;
  DateTime createdAt;
}
```

Computed UI helpers may expose:

```dart
bool get isEarned => delta > 0;
int get absolutePoints => delta.abs();
```

Do not store fake `balanceAfter` or fake lifetime points.

**Current status (2026-07-28): STILL OPEN.** `ApiLoyaltyRepository._mapAccount`/`_mapTransaction` (`lib/features/shared/data/api_loyalty_repository.dart:35-58`) still set `lifetimePointsEarned = pointsBalance`, `userId = ''` on transactions, and `balanceAfter = 0`. Left unchanged this pass — neither field is currently rendered anywhere in the UI (checked `loyalty_screen.dart` and `profile_screen.dart`), so it is not a confirmed user-visible defect, and reworking the frozen model/DTO was out of scope for this focused pass.

## 5.4 Loyalty policy UI uses unmapped defaults

**Files:**

```text
lib/features/shared/domain/models/restaurant_settings.dart
lib/features/shared/data/api_settings_repository.dart
lib/features/customer/presentation/screens/loyalty_screen.dart
lib/features/customer/presentation/screens/profile_screen.dart
```

`RestaurantSettings` contains local defaults for:

- loyalty earning step;
- points per step;
- minimum redemption;
- maximum discount.

`ApiSettingsRepository` does not map these from the backend response, so the UI displays defaults as if they were server configuration.

### Required fix

Choose one explicit source:

- Backend-configured loyalty policy endpoint/fields; or
- A versioned client constant matching the confirmed backend policy.

Do not imply that `/settings` supplied values it did not return.

**Current status (2026-07-28): NOT RE-VERIFIED.** This finding lives primarily in `api_settings_repository.dart`, outside this pass's Loyalty-only scope — not reinspected.

## 5.5 Loyalty errors are hidden in Profile

`ProfileScreen._buildLoyaltyCard()` returns an empty `SizedBox` on error.

The user receives no explanation or retry path.

### Required fix

Show a compact error state with retry, or a clear “Rewards unavailable” state. Do not hide the entire feature silently.

**Current status (2026-07-28): RESOLVED.** `ProfileScreen._buildLoyaltyCard()` (`lib/features/customer/presentation/screens/profile_screen.dart`) now renders an error card (icon + `common.something_wrong` message + `common.retry` button that calls `ref.invalidate(loyaltyProvider)`) instead of `const SizedBox()`.

## 5.6 Loyalty redemption integration

`ApiLoyaltyRepository.redeemReward(rewardId)` exists, but the Loyalty screen does not expose a redemption mutation.

Checkout separately contains a hardcoded reward catalog and sends `redeemRewardId`.

Because the user identified older backend documentation as stale, verify the current backend checkout DTO before retaining or changing `redeemRewardId`.

Classify this flow as:

```text
Backend verification required
```

until controller/DTO/service source confirms the active contract.

**Current status (2026-07-28): ALREADY WORKING, differs from `KZ_API_CONTRACT_FOR_FLUTTER.md` §13.** Redemption is not driven through the standalone `POST /me/loyalty/redeem` call — `ApiLoyaltyRepository.redeemReward()` exists but is unused by any screen. Instead, `CheckoutScreen` sends the selected `rewardId` as `redeemRewardId` on `POST /orders` (`lib/features/shared/data/api_order_repository.dart:92-93`), and the response's `loyaltyRedemption` field (mapped at `api_order_repository.dart:252-279`) triggers `ref.invalidate(loyaltyProvider)` in `checkout_notifier.dart:57-58` after a successful order. This is backend-authoritative (server computes the discount and debits points atomically with order creation) and was not touched this pass, since the code and its inline comments indicate it is an intentional, working design — not a bug. The contract doc's dedicated redeem endpoint appears to be for a future/alternate non-order-tied redemption flow; flagging the discrepancy for backend-doc reconciliation rather than changing checkout behavior, per scope (Loyalty-only, no checkout/order redesign).

## 5.8 Localization key displayed raw on Checkout (new finding, 2026-07-28)

**File:** `lib/features/customer/presentation/screens/checkout_screen.dart:215,325`

`'checkout.loyalty_points_suffix'.tr(namedArgs: {'points': ...})` was called for the loyalty-rewards header points count and each reward's point cost, but `checkout.loyalty_points_suffix` did not exist in `assets/translations/en.json` or `ar.json`. `easy_localization` falls back to printing the raw key when a key is missing, which is the exact bug the user reported ("loyalty.some_key" shown instead of translated text) — it surfaces on the Checkout screen rather than the Loyalty screen itself, since that's where the key is used.

**Status: RESOLVED.** Added `"loyalty_points_suffix": "{points} Pts"` (en) / `"{points} نقطة"` (ar) under `checkout` in both translation files. No `.tr()` call sites or reward IDs changed.

Also corrected `loyalty_screen.dart`'s and `profile_screen.dart`'s error-state copy from the menu-specific `home.failed_load` / `home.retry` keys to the generic `common.something_wrong` / `common.retry` keys — the old keys rendered "Failed to load menu" on a Loyalty error, which is misleading but not a raw-key bug.

## 5.7 Loyalty acceptance criteria

- [x] Authenticated user sees server balance, not a local default.
- [x] Failure never becomes `0`.
- [x] Transaction failure never becomes `[]`.
- [x] Guest state is distinct from zero balance.
- [ ] Account and transaction models match actual JSON. (still fabricates `lifetimePointsEarned`/`balanceAfter`/`userId`, see 5.3 — unused by UI, left open)
- [x] Data reloads after login/session restoration.
- [x] Data clears on logout/user switch.
- [x] Profile shows loading/error/data states explicitly.
- [x] Loyalty screen shows loading/error/empty/data states explicitly.
- [ ] Reward redemption uses a confirmed backend contract.
- [ ] Tests cover relogin, user switching, 401 refresh, 403 guest, 500, malformed JSON, and offline behavior.

---

# 6. Authentication and Session Audit

## 6.1 Good behavior to preserve

- Cached user is not treated as an authenticated session before refresh.
- Session bootstrap refreshes before confirming `/users/me`.
- Refresh attempts are single-flight.
- Logout calls device cleanup before invalidating the session.
- Logout sends the stored refresh token when present.

## 6.2 P1-01 — Refresh-token write is not awaited after login

**File:**

```text
lib/features/shared/data/api_auth_repository.dart
```

**Relevant lines:**

```text
23–44
```

`_handleAuthResult()` calls `_saveTokens(...)` without awaiting it and immediately returns success.

### Risk

- UI navigates before durable refresh-token storage completes.
- Storage errors are unobserved.
- Fast process termination can leave a cached logged-in flag without a saved refresh token.

### Required fix

Make auth-result parsing asynchronous:

```dart
Future<Result<User>> _handleAuthResult(Response response) async {
  ...
  await _saveTokens(accessToken, refreshToken);
  return Success(user);
}
```

Await it in login/register/admin-login/guest-login.

Only publish authenticated UI state after token persistence succeeds.

## 6.3 P0-05 — Retry interceptor retries unsafe operations

**File:**

```text
lib/core/api/api_interceptors.dart
```

**Relevant lines:**

```text
88–139
```

The retry interceptor retries:

- connection timeout;
- receive timeout;
- connection error;
- every HTTP status >= 500.

It does not check:

- HTTP method;
- endpoint;
- request body replay safety;
- idempotency key.

### Critical refresh-token failure scenario

1. Flutter sends `/auth/refresh`.
2. Backend rotates the refresh token and returns success.
3. Response is lost due to a connection problem.
4. Retry interceptor resends the old single-use refresh token.
5. Backend detects reuse and revokes the refresh-token family.
6. User is unexpectedly logged out.

### Required retry policy

Never automatically retry:

```text
/auth/refresh
/auth/login
/auth/register
/auth/guest
/me/favorites POST
/cart/items POST
/admin/uploads/image
```

Default automatic retries should be limited to safe/idempotent methods:

```text
GET
HEAD
OPTIONS
```

Allow mutation retries only when explicitly proven safe, for example checkout with a stable `Idempotency-Key`.

## 6.4 P0-04 — No central user-scoped state reset

**File:**

```text
lib/features/customer/presentation/notifiers/auth_notifier.dart
```

**Relevant lines:**

```text
285–302
```

Logout clears auth persistence and state but does not clear:

- Favorites
- Addresses
- Cart
- Orders
- Loyalty
- Checkout state
- user-specific notification/device state beyond token deletion

### Required fix

Implement one central session-bound state reset at the composition/root layer.

On logout or definitive refresh rejection:

```text
clear/invalidate Favorites
clear/invalidate Addresses
clear/invalidate Cart
clear/invalidate Orders
clear/invalidate Loyalty
clear/invalidate Checkout
clear user-scoped caches
```

On login/session restoration:

```text
reload Favorites
reload Addresses
reload Cart
reload Orders
reload Loyalty for eligible users
```

Avoid importing every feature provider directly into `AuthNotifier` if that creates circular dependencies. Prefer a root session coordinator/provider listener.

---

# 7. Address State and Privacy

## P0-06 — Address provider is not session-aware

**File:**

```text
lib/features/customer/presentation/notifiers/address_notifier.dart
```

**Relevant lines:**

```text
41–68
119–122
```

The provider:

- loads once in the constructor;
- reads auth state;
- persists for the process;
- does not clear on logout;
- does not reload on new login.

Home reads this provider to show the default delivery address.

### User impact

- New login may show no addresses until manual reload.
- Previous user’s default address may remain visible after logout or account switching.

### Required fix

Make the provider depend on active user/session identity, or reset/reload it through the central session coordinator.

### Additional note

The repository paths and methods themselves are correctly implemented:

```http
GET /me/addresses
POST /me/addresses
PUT /me/addresses/:id
DELETE /me/addresses/:id
PATCH /me/addresses/:id/default
```

---

# 8. User Model Contract

## P1-04 — Backend user fields are dropped or inferred

**File:**

```text
lib/features/shared/domain/models/user.dart
```

Current model does not explicitly contain:

- `avatarUrl`
- `locale`
- `isGuest`

Instead, `isGuest` is inferred using email/name text.

### Risk

- A legitimate user whose name/email contains “guest” can be misclassified.
- Backend guest state can be lost.
- Profile update response fields are discarded.
- Session eligibility logic for Loyalty/Addresses becomes unreliable.

### Required model

Include the actual backend fields:

```dart
required bool isGuest
String? avatarUrl
required String locale
```

Use backend `isGuest` directly.

Remove the heuristic extension after migration.

---

# 9. Cart and Checkout Audit

## 9.1 Correct API integration

`ApiCartRepository` uses the correct general route pattern and maps server-returned line prices.

Checkout:

- sends delivery method and payment method;
- maps selected saved address into the inline checkout address object;
- sends an idempotency key;
- disables CARD UI while gateway support is unavailable;
- does not send subtotal/tax/total as authoritative request fields.

## 9.2 P1-06 — Cart item replacement is destructive

**File:**

```text
lib/features/customer/presentation/notifiers/cart_notifier.dart
```

**Relevant lines:**

```text
57–71
```

Current edit flow:

```text
DELETE old item
POST new item
```

If POST fails, the original item is already gone.

### Required fix

Use the backend update endpoint for editable fields:

```http
PUT /cart/items/:id
```

Expand the repository update contract to support:

- quantity;
- variantId;
- addonIds;
- specialInstructions.

Do not emulate an update through remove + add.

## 9.3 Local cart totals

`ApiCartRepository` calculates preview subtotal, promo discount, tax, and grand total locally.

This is acceptable only as a clearly labeled preview. The order response must remain authoritative after checkout.

Do not use locally calculated values to:

- persist an order;
- confirm payment amount;
- overwrite the backend order total.

## 9.4 Checkout loyalty contract requires verification

Frontend sends:

```json
{
  "redeemRewardId": "..."
}
```

Verify this field against the current backend Checkout DTO/controller/service before implementation changes. Do not rely on stale documentation.

---

# 10. Orders Audit

## P1-05 — Wrong `menuItemId` mapping

**File:**

```text
lib/features/shared/data/api_order_repository.dart
```

**Relevant lines:**

```text
282–293
```

Current code:

```dart
menuItemId: json['id']
```

`json['id']` is the order-item row ID, not necessarily the menu-item ID.

Home then uses `OrderItem.menuItemId` to deduplicate recently ordered products.

### Impact

- Recently ordered items can be deduplicated incorrectly.
- Reorder/item navigation can target the wrong ID.
- Order-item identity and catalog-item identity are conflated.

### Required fix

Map from the actual backend snapshot/response field that represents the menu item.

If the backend does not return a stable menu-item ID in order snapshots, then:

- do not pretend the order-item ID is a menu-item ID;
- change the domain field naming;
- disable item navigation/reorder that requires unavailable identity; or
- add a backend response field only after explicit backend approval.

## Good behavior

- Lower-camel order status mapping supports `outForDelivery`.
- Tracking polls `/orders/:id/status`.
- Polling stops at delivered/cancelled.

---

# 11. Admin Integration

## P0-07 — Nested variants/add-ons may be deleted during update

**File:**

```text
lib/features/shared/data/api_menu_repository.dart
```

**Relevant lines:**

```text
178–220
```

Create/update payload contains only:

- category ID;
- bilingual names/descriptions copied from one field;
- price;
- image URL;
- availability/popularity.

It omits:

- variants;
- addon groups;
- addons;
- nested IDs;
- display order.

If the current backend `PUT /admin/menu/items/:id` uses full replacement/diff synchronization, this can delete nested catalog configuration.

### Required action

Before modifying this area, verify the current backend DTO and service implementation.

If full replacement is confirmed:

- Fetch and retain the complete nested structure.
- Submit the full current structure on every PUT.
- Preserve existing nested entity IDs.
- Add regression tests proving edit of a title/price does not delete variants/add-ons.

## Role-routing issue

`router.dart` has no client-side auth/role guard, and Profile always exposes an Admin Dashboard link.

The backend still protects admin endpoints, so this is not a backend authorization bypass. It is a UX and session-routing problem.

Required behavior:

- Hide Admin entry points from non-admin users.
- Redirect unauthenticated users away from protected customer/admin routes.
- Redirect CUSTOMER users away from `/admin/*`.
- Keep backend authorization as the final security boundary.

**Current status (2026-07-28): PARTIALLY RESOLVED (CASHIER scope only).** Phase 5 added a `redirect` callback on the top-level `GoRouter` (`lib/core/router/router.dart`) that: (1) confines a `CASHIER` role to `/admin/orders*` — any other `/admin/*` path redirects back there, even on direct/manual navigation; (2) gates the new `/admin/staff` route to `role == 'ADMIN'` only, redirecting a cashier to `/admin/orders` and anyone else to `/login`. `AdminShell` (`lib/features/admin/presentation/shells/admin_shell.dart`) also hides all owner-only nav destinations (dashboard, menu, offers, notifications, settings, staff) for `CASHIER`, showing only Orders + a new Logout action. **Still open / not touched this pass:** no guard yet for an unauthenticated user or a plain `CUSTOMER` navigating to `/admin/*` — that part of the original finding remains as described above. Backend authorization (`@Roles(...)`) is unaffected and remains the real security boundary either way.

---

# 12. API Configuration

## P1-08 — LAN IP fallback

**File:**

```text
lib/core/api/api_config.dart
```

Current fallback:

```text
http://192.168.1.51:3000/api/v1
```

### Risk

A release build without `--dart-define` silently targets an unreachable private network address.

### Required fix

Use environment-specific build configuration.

For release builds, fail fast when `API_BASE_URL` is missing, or use a reviewed production URL supplied by CI/build commands.

Do not hardcode:

- localhost;
- emulator host;
- LAN IP;
- VPS IP inside Dart source.

---

# 13. Currency and Market Configuration

The app contains hardcoded EGP labels and defaults while the restaurant target is Saudi Arabia.

Examples include:

- `10 EGP Off`
- `25 EGP Off`
- default currency `EGP`
- translation key names such as `common.egp`

### Required fix

Use the backend/settings currency consistently.

The UI must not derive business currency from a translation key.

This is a production consistency issue, not a reason to redesign the UI.

---

# 14. Test Audit

## P1-09 — API tests are actually fake-repository tests

### Favorites test

```text
test/api_favorites_repository_test.dart
```

Imports:

```dart
FakeFavoritesRepository
```

### Loyalty test

```text
test/api_loyalty_repository_test.dart
```

Imports:

```dart
FakeLoyaltyRepository
```

These tests do not validate:

- endpoint paths;
- HTTP methods;
- auth header;
- request JSON;
- response parsing;
- 204 handling;
- error envelope mapping;
- session restoration;
- provider invalidation.

## Required tests

### Favorites repository

- GET parses list.
- POST sends `{menuItemId}` and parses full list.
- DELETE handles 204.
- 401 triggers one refresh/retry.
- 404/409 map correctly.
- Offline does not become empty list.

### Favorites widgets/state

- Menu button calls canonical notifier.
- Item Details button calls canonical notifier.
- Home/Menu/Details/Favorites synchronize.
- Optimistic failure rolls back.
- Logout clears state.
- User switch loads the new user’s list.

### Loyalty repository

- Account parses `pointsBalance`.
- Transactions preserve `delta`, `reason`, `orderId`, and date.
- 403 guest maps to explicit not-eligible state.
- 500/offline remains an error.
- Malformed JSON does not become zero.

### Loyalty state

- Successful login triggers load.
- Session restoration triggers load.
- Logout clears data.
- Switching users cannot reuse previous balance.
- Error UI is visible.
- Successful zero is distinguishable from failure.

### Retry interceptor

- GET may retry.
- POST favorite/cart does not retry automatically.
- `/auth/refresh` never retries.
- Checkout may retry only with a stable idempotency key and explicit policy.

---

# 15. Recommended Implementation Order

## Phase 1 — Session safety

1. Restrict RetryInterceptor.
2. Await token persistence.
3. Add a central session lifecycle coordinator.
4. Invalidate/clear user-scoped state on logout/rejection.
5. Reload user-scoped state after login/session restoration.

Run:

```bash
dart format .
flutter analyze
flutter test test/auth_interceptor_test.dart
flutter test test/token_refresh_coordinator_test.dart
flutter test test/session_bootstrap_notifier_test.dart
```

## Phase 2 — Favorites

1. Remove `menuFavoritesProvider`.
2. Remove `itemFavoriteProvider`.
3. Make all screens use `customerFavoritesProvider`.
4. Make Favorites session-aware.
5. Add real API and widget tests.

Run:

```bash
dart format .
flutter analyze
flutter test test/api_favorites_repository_test.dart
```

## Phase 3 — Loyalty

1. Stop converting failures to zero/empty.
2. Correct domain/API models.
3. Make provider auth-reactive.
4. Add guest/error/data UI.
5. Correct Profile card behavior.
6. Verify redemption contract against backend.
7. Add real tests.

Run:

```bash
dart format .
flutter analyze
flutter test test/api_loyalty_repository_test.dart
```

## Phase 4 — Addresses and user isolation

1. Make Address provider session-aware.
2. Clear/reload on auth transitions.
3. Add user-switch test.

## Phase 5 — Cart and Orders

1. Replace destructive cart-item edit.
2. Correct order-item identity mapping.
3. Verify recent-order behavior.
4. Confirm all totals remain server-authoritative.

## Phase 6 — Admin and production configuration

1. Verify nested menu update contract.
2. Add role-aware routing/visibility.
3. Replace LAN fallback.
4. Replace hardcoded EGP usage.
5. Validate release build configuration.

---

# 16. Instructions for Claude Flutter

Use this report as an implementation plan, not permission to redesign the app.

## Mandatory rules

- Work with one agent sequentially.
- Do not redesign architecture.
- Do not replace Riverpod.
- Do not change backend routes or JSON contracts.
- Do not redesign UI while fixing integrations.
- Do not remove fake repository files unless confirmed unused everywhere.
- Do not modify navigation except for confirmed auth/role protection defects.
- Complete one phase and run checks before moving to the next.
- Record every modified file and reason.
- Stop and report when current backend source contradicts this audit.

## Before editing

Verify each cited file against the current local checkout and confirm the repository commit.

Create a small implementation checklist, then begin Phase 1 only.

## Quality gate after every phase

```bash
dart format .
flutter analyze
flutter test
```

Also perform targeted runtime verification against a safe development backend:

- no runtime exceptions;
- no unhandled Dio errors;
- no duplicate refresh requests;
- no duplicate Favorite mutations;
- no stale user data after logout/login;
- no fake zero Loyalty balance on API failure;
- no RenderFlex/layout overflow;
- responsive phone/tablet/desktop behavior remains intact;
- no localization warnings.

---

# 17. Final Release Acceptance Criteria

- [ ] One canonical Favorites state source exists.
- [ ] Menu and Item Details Favorite buttons call the backend.
- [ ] Loyalty failures never display as zero.
- [ ] Guest Loyalty state is explicit.
- [ ] User-scoped data is cleared on logout.
- [ ] User-scoped data reloads on login/session restoration.
- [ ] Switching users cannot expose prior user data.
- [ ] Refresh endpoint is never automatically retried.
- [ ] Unsafe POST requests are not automatically retried.
- [ ] Auth token persistence is awaited.
- [ ] User model consumes backend `isGuest`.
- [ ] Cart editing is not delete-then-add.
- [ ] Order item identity is mapped correctly.
- [ ] Admin menu edit preserves variants/add-ons.
- [ ] Release API URL cannot silently fall back to LAN.
- [ ] Currency is configuration-driven.
- [ ] Favorites and Loyalty tests use actual API repositories.
- [ ] `flutter analyze` passes.
- [ ] Full test suite passes.
- [ ] Live login → favorite → logout → login test passes.
- [ ] Live loyalty persistence test passes.
