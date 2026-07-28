# Kebda Zaman — API Contract for Flutter

**Backend repository:** `Ahmedkhalaf2-1/kebda-zaman`  
**Branch:** `main`  
**Commit:** `b562de5ed5d056e808ac9958c4d5f0b24eda6b2d`  
**Purpose:** Authoritative Flutter integration contract generated from the latest backend source snapshot.  
**Important:** Do not use `API_INTEGRATION_GUIDE.md` as the source of truth. Claude Flutter must verify the current Flutter implementation against this contract and the actual backend behavior.

---

## 1. Global API Rules

### Base URL

```text
http://<host>:3000/api/v1
```

Production must use a build-time Flutter value:

```bash
--dart-define=API_BASE_URL=https://api.<domain>/api/v1
```

Do not hardcode localhost, a LAN IP, or the VPS IP in Dart source.

### Authentication header

```http
Authorization: Bearer <ACCESS_TOKEN>
```

### Global request validation

The backend uses strict DTO validation:

- Unknown JSON fields are rejected.
- Query values are transformed to their declared types.
- Invalid DTOs return `400 VALIDATION_ERROR`.

### Canonical error JSON

```json
{
  "statusCode": 400,
  "error": "BadRequest",
  "message": "Human-readable message",
  "code": "MACHINE_READABLE_CODE",
  "details": [],
  "timestamp": "2026-07-28T00:00:00.000Z",
  "path": "/api/v1/example",
  "requestId": "request-id"
}
```

Flutter must branch primarily on `code`, not on `message`.

### Serialization rules

- IDs: UUID strings.
- Dates: ISO-8601 strings.
- Money: JSON numbers, not strings.
- List endpoints: bare arrays unless explicitly documented otherwise.
- No generic `{success, data}` response wrapper.
- Order statuses on the wire are lower camel case.
- Several Prisma-facing enums remain uppercase; map each enum exactly.

---

# 2. Authentication API

## Register

```http
POST /auth/register
```

Alias:

```http
POST /auth/signup
```

Public.

Request:

```json
{
  "name": "Ahmed Ali",
  "email": "ahmed@example.com",
  "password": "SecurePass123",
  "phone": "+201000000000"
}
```

Rules:

- `name`: 2–100 chars.
- `email`: valid email, max 255.
- `password`: 8–72 chars.
- `phone`: optional, max 30.

Response `201`:

```json
{
  "user": {
    "id": "uuid",
    "name": "Ahmed Ali",
    "email": "ahmed@example.com",
    "phone": "+201000000000",
    "avatarUrl": null,
    "role": "CUSTOMER",
    "isGuest": false,
    "locale": "en",
    "createdAt": "2026-07-28T00:00:00.000Z"
  },
  "accessToken": "<ACCESS_TOKEN>",
  "refreshToken": "<REFRESH_TOKEN>"
}
```

Errors:

- `400 VALIDATION_ERROR`
- `409 EMAIL_ALREADY_EXISTS`

## Login

```http
POST /auth/login
```

Public.

Request:

```json
{
  "email": "ahmed@example.com",
  "password": "SecurePass123"
}
```

Response `200`: same auth result as registration.

Errors:

- `401 INVALID_CREDENTIALS`
- `423 ACCOUNT_LOCKED`

## Admin login

```http
POST /admin/auth/login
```

Alias:

```http
POST /auth/admin/login
```

Public.

Request is identical to normal login.

Errors:

- `401 INVALID_CREDENTIALS`
- `403 NOT_ADMIN`
- `423 ACCOUNT_LOCKED`

## Guest session

```http
POST /auth/guest
```

Public.

Request:

```json
{
  "deviceId": "optional-device-id"
}
```

`deviceId` is currently accepted but not persisted.

Response `201`: standard auth result with:

```json
{
  "role": "CUSTOMER",
  "isGuest": true
}
```

## Refresh token

```http
POST /auth/refresh
```

Public. Do not send the access token as the refresh credential.

Request:

```json
{
  "refreshToken": "<REFRESH_TOKEN>"
}
```

Response `200`:

```json
{
  "accessToken": "<NEW_ACCESS_TOKEN>",
  "refreshToken": "<NEW_REFRESH_TOKEN>"
}
```

The refresh token rotates. Flutter must atomically replace both stored tokens.

Errors:

- `401 INVALID_REFRESH_TOKEN`
- `401 REFRESH_TOKEN_EXPIRED`
- `401 REFRESH_TOKEN_REUSED`

For `REFRESH_TOKEN_REUSED`, clear the session and force full login.

## Logout

```http
POST /auth/logout
Authorization: Bearer <ACCESS_TOKEN>
```

Request:

```json
{
  "refreshToken": "<REFRESH_TOKEN>"
}
```

Response: `204 No Content`.

Flutter must send the refresh token; omitting it may leave the refresh session active.

## Logout all devices

```http
POST /auth/logout-all
Authorization: Bearer <ACCESS_TOKEN>
```

No body. Response: `204 No Content`.

## Flutter session flow

1. Login/register/guest.
2. Store refresh token securely.
3. Store access token securely or in protected session memory.
4. Fetch `/users/me`.
5. Hydrate user-specific providers.
6. On `401`, perform one coordinated refresh.
7. Retry the original request once.
8. On refresh failure, clear auth and user-specific state.
9. On logout, call backend logout, remove FCM token if appropriate, clear tokens, invalidate user-scoped providers, and reset navigation.

---

# 3. Profile API

## Get current user

```http
GET /users/me
Authorization: Bearer <ACCESS_TOKEN>
```

Response `200`:

```json
{
  "id": "uuid",
  "name": "Ahmed Ali",
  "email": "ahmed@example.com",
  "phone": null,
  "avatarUrl": null,
  "role": "CUSTOMER",
  "isGuest": false,
  "locale": "en",
  "createdAt": "2026-07-28T00:00:00.000Z"
}
```

## Update current user

```http
PATCH /users/me
Authorization: Bearer <ACCESS_TOKEN>
```

All fields are optional:

```json
{
  "name": "Ahmed Ali",
  "phone": "+201000000000",
  "avatarUrl": "https://example.com/avatar.jpg",
  "locale": "ar"
}
```

`locale` accepts only:

```text
ar
en
```

Response `200`: updated user object.

---

# 4. Categories and Menu API

## List categories

```http
GET /categories
```

Public.

Response `200`:

```json
[
  {
    "id": "uuid",
    "nameAr": "ساندوتشات",
    "nameEn": "Sandwiches",
    "iconUrl": "https://example.com/icon.png",
    "displayOrder": 1
  }
]
```

## Category details

```http
GET /categories/:id
```

Public.

Errors:

- `404 CATEGORY_NOT_FOUND`

## List menu items

```http
GET /menu?categoryId=<UUID>&page=1&limit=20
```

Public.

Query:

- `categoryId`: optional UUID.
- `page`: integer >= 1.
- `limit`: integer 1–100.

Response: bare array.

## Search menu

```http
GET /menu/search?q=<TEXT>
```

Public.

Errors:

- `400 SEARCH_QUERY_EMPTY`

## Menu item details

```http
GET /menu/items/:id
```

Public.

Errors:

- `404 MENU_ITEM_NOT_FOUND`

## Home featured

```http
GET /home/featured
```

Public.

Response:

```json
{
  "featured": [],
  "categories": []
}
```

## Menu item response shape

```json
{
  "id": "uuid",
  "categoryId": "uuid",
  "nameAr": "كبدة",
  "nameEn": "Liver",
  "descriptionAr": "وصف",
  "descriptionEn": "Description",
  "basePrice": 25.5,
  "imageUrl": "https://example.com/item.jpg",
  "isAvailable": true,
  "isPopular": false,
  "variants": [
    {
      "id": "uuid",
      "nameAr": "كبير",
      "nameEn": "Large",
      "priceDelta": 10,
      "isDefault": true
    }
  ],
  "addonGroups": [
    {
      "id": "uuid",
      "titleAr": "إضافات",
      "titleEn": "Add-ons",
      "isRequired": false,
      "minSelect": 0,
      "maxSelect": 2,
      "addons": [
        {
          "id": "uuid",
          "nameAr": "جبنة",
          "nameEn": "Cheese",
          "price": 5
        }
      ]
    }
  ]
}
```

---

# 5. Cart API

All cart routes require an access token. Guests are accepted.

## Get cart

```http
GET /cart
Authorization: Bearer <ACCESS_TOKEN>
```

Response:

```json
{
  "items": [],
  "appliedPromo": null,
  "deliveryFee": 20,
  "taxRate": 14
}
```

The cart response does not contain aggregate `subtotal` or `total`.

Flutter may sum `items[].totalPrice` for preview display only. Checkout totals remain server-authoritative.

## Add cart item

```http
POST /cart/items
Authorization: Bearer <ACCESS_TOKEN>
```

Request:

```json
{
  "menuItemId": "uuid",
  "variantId": "uuid",
  "addonIds": ["uuid"],
  "quantity": 2,
  "specialInstructions": "No onions"
}
```

Response `201`: full updated cart.

Errors:

- `404 ITEM_UNAVAILABLE`
- `422 INVALID_VARIANT`
- `422 INVALID_ADDON_SELECTION`

## Update cart item

```http
PUT /cart/items/:id
Authorization: Bearer <ACCESS_TOKEN>
```

Patch semantics:

```json
{
  "quantity": 3,
  "variantId": null,
  "addonIds": [],
  "specialInstructions": null
}
```

Response `200`: full updated cart.

Errors:

- `404 CART_ITEM_NOT_FOUND`
- `422 INVALID_VARIANT`
- `422 INVALID_ADDON_SELECTION`

## Remove cart item

```http
DELETE /cart/items/:id
Authorization: Bearer <ACCESS_TOKEN>
```

Response `200`: full updated cart.

## Clear cart

```http
DELETE /cart
Authorization: Bearer <ACCESS_TOKEN>
```

Response `200`: empty cart object.

## Apply promo

```http
POST /cart/apply-promo
Authorization: Bearer <ACCESS_TOKEN>
```

Request:

```json
{
  "code": "WELCOME10"
}
```

Response `200`: full updated cart.

## Remove promo

```http
DELETE /cart/promo
Authorization: Bearer <ACCESS_TOKEN>
```

Response `200`: full updated cart.

## Cart item shape

```json
{
  "id": "uuid",
  "menuItem": {},
  "selectedVariant": null,
  "selectedAddons": [],
  "quantity": 2,
  "specialInstructions": null,
  "unitPrice": 30.5,
  "totalPrice": 61,
  "isAvailable": true
}
```

---

# 6. Promo Validation API

```http
POST /promos/validate
Authorization: Bearer <ACCESS_TOKEN>
```

Request:

```json
{
  "code": "WELCOME10"
}
```

A submitted `subtotal` is accepted by the DTO but the server calculates against the caller’s real cart.

Response:

```json
{
  "valid": true,
  "discountType": "PERCENT",
  "value": 10,
  "computedDiscount": 12.5
}
```

This endpoint previews validation only. Apply the promo with `/cart/apply-promo`.

Errors:

- `404 PROMO_NOT_FOUND`
- `422 PROMO_INVALID`
- `422 PROMO_EXPIRED`
- `422 PROMO_MIN_ORDER`

---

# 7. Restaurant Settings API

```http
GET /settings
```

Public.

Response:

```json
{
  "deliveryFee": 20,
  "taxRatePercent": 14,
  "minOrderAmount": 50,
  "workingHours": {
    "open": "10:00",
    "close": "02:00"
  },
  "isMaintenanceMode": false
}
```

Flutter must enforce the maintenance-mode UI. The backend does not block all endpoints automatically.

---

# 8. Checkout API

Equivalent routes:

```http
POST /checkout
POST /orders
```

Require `CUSTOMER` role. Guest users also carry `CUSTOMER`, unless blocked by a feature-specific rule.

Recommended header:

```http
Idempotency-Key: <UNIQUE_CHECKOUT_ATTEMPT_ID>
```

Request:

```json
{
  "deliveryMethod": "DELIVERY",
  "paymentMethod": "CASH",
  "deliveryAddress": {
    "title": "Home",
    "street": "Example Street",
    "building": "10",
    "floor": "2",
    "apartment": "5",
    "city": "Jeddah"
  },
  "promoCode": "WELCOME10",
  "notes": "Call on arrival"
}
```

For pickup:

```json
{
  "deliveryMethod": "PICKUP",
  "paymentMethod": "CASH"
}
```

Do not send price, subtotal, fee, tax, discount, or total fields.

Response `201`: full order object.

Errors include:

- `422 DELIVERY_ADDRESS_REQUIRED`
- `409 EMPTY_CART`
- `422 BELOW_MIN_ORDER`
- Promo errors
- `404 ITEM_UNAVAILABLE`
- `422 INVALID_VARIANT`
- `422 INVALID_ADDON_SELECTION`

---

# 9. Orders API

## List orders

```http
GET /orders?status=pending&page=1&limit=20
Authorization: Bearer <ACCESS_TOKEN>
```

Customer role. Bare array response.

## Order details

```http
GET /orders/:id
Authorization: Bearer <ACCESS_TOKEN>
```

Owner-scoped.

## Order tracking/status

```http
GET /orders/:id/status
Authorization: Bearer <ACCESS_TOKEN>
```

Response:

```json
{
  "status": "preparing",
  "statusHistory": [
    {
      "status": "pending",
      "note": null,
      "changedAt": "2026-07-28T00:00:00.000Z"
    }
  ],
  "estimatedDeliveryTime": null
}
```

There is currently:

- No customer cancel endpoint.
- No SSE tracking endpoint.
- Flutter must poll the status endpoint when live tracking is needed.

## Order response shape

```json
{
  "id": "uuid",
  "orderNumber": "KZ-260728-a1b2c3d4",
  "userId": "uuid",
  "user": {},
  "items": [
    {
      "id": "uuid",
      "menuItem": {
        "nameAr": "كبدة",
        "nameEn": "Liver",
        "imageUrl": "https://example.com/item.jpg"
      },
      "selectedVariant": null,
      "selectedAddons": [],
      "quantity": 2,
      "specialInstructions": null,
      "unitPrice": 30.5,
      "totalPrice": 61
    }
  ],
  "status": "pending",
  "deliveryAddress": {
    "title": "Home",
    "street": "Example Street",
    "building": "10",
    "floor": null,
    "apartment": null,
    "city": "Jeddah"
  },
  "paymentMethod": "cash",
  "subtotal": 120,
  "deliveryFee": 20,
  "tax": 16.8,
  "discount": 0,
  "totalAmount": 156.8,
  "createdAt": "2026-07-28T00:00:00.000Z",
  "estimatedDeliveryTime": null
}
```

---

# 10. Payments API

## Create payment intent

```http
POST /payments/intent
Authorization: Bearer <ACCESS_TOKEN>
```

Request:

```json
{
  "orderId": "uuid"
}
```

Cash response:

```json
{
  "paymentId": "uuid",
  "status": "PENDING",
  "providerData": {
    "instructions": "Pay with cash upon delivery"
  }
}
```

Errors:

- `404 ORDER_NOT_FOUND`
- `404 PAYMENT_NOT_FOUND`
- `409 PAYMENT_ALREADY_PROCESSED`
- `501 PAYMENT_PROVIDER_NOT_CONFIGURED`

CARD and WALLET are not operational. Hide or disable those options in production Flutter until a provider is implemented.

## Get payment

```http
GET /payments/:id
Authorization: Bearer <ACCESS_TOKEN>
```

Owner or admin.

Response:

```json
{
  "id": "uuid",
  "orderId": "uuid",
  "method": "CASH",
  "status": "PENDING",
  "amount": 156.8,
  "currency": "SAR",
  "provider": null,
  "providerRef": null,
  "createdAt": "2026-07-28T00:00:00.000Z",
  "updatedAt": "2026-07-28T00:00:00.000Z"
}
```

## Payment webhook

```http
POST /payments/webhook
```

Server/gateway only. Flutter must never call it.

---

# 11. Saved Addresses API

All routes require authentication.

## List

```http
GET /me/addresses
```

## Create

```http
POST /me/addresses
```

Request:

```json
{
  "title": "Home",
  "street": "Example Street",
  "building": "10",
  "floor": "2",
  "apartment": "5",
  "city": "Jeddah",
  "notes": "Near the mosque",
  "latitude": 21.5433,
  "longitude": 39.1728,
  "isDefault": true
}
```

The first saved address is forced to default.

## Replace/update

```http
PUT /me/addresses/:id
```

Full body replacement.

## Delete

```http
DELETE /me/addresses/:id
```

Response: `204`.

## Set default

```http
PATCH /me/addresses/:id/default
```

Response: updated address.

## Address shape

```json
{
  "id": "uuid",
  "userId": "uuid",
  "title": "Home",
  "street": "Example Street",
  "building": "10",
  "floor": "2",
  "apartment": "5",
  "city": "Jeddah",
  "notes": null,
  "latitude": 21.5433,
  "longitude": 39.1728,
  "isDefault": true,
  "createdAt": "2026-07-28T00:00:00.000Z",
  "updatedAt": "2026-07-28T00:00:00.000Z"
}
```

Checkout currently accepts an inline `deliveryAddress`, not an `addressId`. Flutter must map a selected saved address into the checkout DTO.

---

# 12. Favorites API

All routes require `CUSTOMER` role.

## List favorites

```http
GET /me/favorites
Authorization: Bearer <ACCESS_TOKEN>
```

Response `200`: bare `MenuItemResponseDto[]`, newest favorite first.

## Add favorite

```http
POST /me/favorites
Authorization: Bearer <ACCESS_TOKEN>
Content-Type: application/json
```

Request:

```json
{
  "menuItemId": "uuid"
}
```

Response `201`: full updated favorites list.

Errors:

- `404 MENU_ITEM_NOT_FOUND`
- `409 FAVORITE_ALREADY_EXISTS`

## Remove favorite

```http
DELETE /me/favorites/:menuItemId
Authorization: Bearer <ACCESS_TOKEN>
```

Response: `204`.

Errors:

- `404 FAVORITE_NOT_FOUND`

## Required Flutter flow

1. Ensure the authenticated access token exists.
2. Await the repository mutation.
3. For add, parse the returned full favorites list.
4. For remove, on `204`, remove locally or refetch.
5. Invalidate the canonical favorites provider.
6. Synchronize favorite icons in Home, Menu, Item Details, and Favorites.
7. Roll back optimistic UI after an error.
8. Never convert a favorites API error into `[]`.
9. After login/session restoration, fetch favorites again for the active user.
10. On logout or user switch, clear/invalidate all user-specific favorite state.

Likely Flutter bug checks:

- Wrong endpoint such as `/favorites` instead of `/me/favorites`.
- Sending item ID in the URL for add instead of JSON body.
- Expecting one item from `POST` when the backend returns a list.
- Expecting JSON from `DELETE` although the response is `204`.
- Calling mutation without `await`.
- UI reading a separate local favorites provider.
- Repository provider still bound to a fake/local implementation.
- Missing auth header.
- Failure swallowed and replaced with an empty list.

---

# 13. Loyalty API

Requires `CUSTOMER` and `isGuest == false`.

## Get loyalty account

```http
GET /me/loyalty
Authorization: Bearer <ACCESS_TOKEN>
```

Response:

```json
{
  "id": "uuid",
  "userId": "uuid",
  "pointsBalance": 120,
  "createdAt": "2026-07-28T00:00:00.000Z",
  "updatedAt": "2026-07-28T00:00:00.000Z"
}
```

The backend lazily creates the loyalty account on first request.

## Transaction history

```http
GET /me/loyalty/transactions
Authorization: Bearer <ACCESS_TOKEN>
```

Response:

```json
[
  {
    "id": "uuid",
    "delta": 15,
    "reason": "ORDER_EARNED",
    "orderId": "uuid",
    "createdAt": "2026-07-28T00:00:00.000Z"
  }
]
```

`reason` must be treated as an open string, not a closed Dart enum.

## Redeem

```http
POST /me/loyalty/redeem
Authorization: Bearer <ACCESS_TOKEN>
```

Request:

```json
{
  "rewardId": "free-delivery"
}
```

Current reward IDs:

```text
free-delivery
discount-10
discount-25
```

Response:

```json
{
  "account": {
    "id": "uuid",
    "userId": "uuid",
    "pointsBalance": 20,
    "createdAt": "2026-07-28T00:00:00.000Z",
    "updatedAt": "2026-07-28T00:00:00.000Z"
  },
  "redemption": {
    "rewardId": "free-delivery",
    "rewardName": "Free Delivery",
    "pointsCost": 100,
    "transactionId": "uuid",
    "redeemedAt": "2026-07-28T00:00:00.000Z"
  }
}
```

Errors:

- `403 GUEST_NOT_ELIGIBLE`
- `404 REWARD_NOT_FOUND`
- `422 INSUFFICIENT_POINTS`

Points are earned automatically when an admin marks an eligible non-guest order as `delivered`. The current earning rate is 1 point per 10 currency units of final order total.

## Required Flutter flow

1. Complete authentication/session restoration.
2. Load `/users/me`.
3. Only for a non-guest authenticated customer, call `/me/loyalty`.
4. Load transactions separately.
5. Represent account, history, loading, empty, and error states separately.
6. Never map an API failure to `pointsBalance = 0`.
7. Never overwrite server balance with a local default.
8. Refresh account and transactions after redemption.
9. Refresh loyalty after an eligible delivered order becomes visible.
10. Invalidate loyalty account/history on logout and user switch.
11. On next login, fetch both again for the active user.

Likely Flutter bug checks:

- Loyalty provider is not invoked after login/session restoration.
- Provider is auto-disposed and rebuilt with a zero default.
- Logout clears local state but login does not rehydrate it.
- API errors are caught and replaced with zero balance.
- Repository provider is bound to fake/local implementation.
- Wrong field name such as `points` instead of `pointsBalance`.
- Guest state is treated as normal zero balance.
- History and account providers use different user/session sources.

---

# 14. FCM Device API

All routes require authentication.

## Register token

```http
POST /devices/register
```

Request:

```json
{
  "token": "<FCM_TOKEN>",
  "platform": "ANDROID"
}
```

Response `201`: device-token row.

## Rotate/update token

```http
PUT /devices/token
```

Request:

```json
{
  "oldToken": "<OLD_FCM_TOKEN>",
  "token": "<NEW_FCM_TOKEN>",
  "platform": "ANDROID"
}
```

## Delete token

```http
DELETE /devices/token
```

Request:

```json
{
  "token": "<FCM_TOKEN>"
}
```

Response: `204`.

Platform values:

```text
ANDROID
IOS
WEB
MACOS
WINDOWS
```

FCM data payload keys:

```json
{
  "id": "notification-id",
  "type": "order_preparing",
  "title": "Order update",
  "body": "Your order is being prepared",
  "route": "/orders/tracking/uuid",
  "entityId": "uuid",
  "imageUrl": null,
  "timestamp": "2026-07-28T00:00:00.000Z"
}
```

There is no backend notification inbox/history endpoint.

---

# 15. Admin Upload API

```http
POST /admin/uploads/image
Authorization: Bearer <ADMIN_ACCESS_TOKEN>
Content-Type: multipart/form-data
```

Multipart field:

```text
file
```

Response:

```json
{
  "imageUrl": "https://api.example.com/uploads/generated-file-name.jpg"
}
```

Uploaded files are served from the unversioned static path:

```text
/uploads/<filename>
```

This endpoint is for the admin application, not the customer Flutter app.

---

# 16. Admin Orders API

Require `ADMIN` or `CASHIER` (Phase 5 — `PHASE_5_CASHIER_API_CONTRACT.md`).
Behavior and validation are identical for both roles; a cashier account has no
reduced capability on these three routes.

## List

```http
GET /admin/orders?status=pending&q=<TEXT>&page=1&limit=20
```

## Details

```http
GET /admin/orders/:id
```

## Update status

```http
PATCH /admin/orders/:id/status
```

Request:

```json
{
  "status": "confirmed",
  "note": "Accepted by restaurant"
}
```

Allowed transitions:

```text
pending -> confirmed | cancelled
confirmed -> preparing | cancelled
preparing -> outForDelivery | cancelled
outForDelivery -> delivered | cancelled
```

Terminal:

```text
delivered
cancelled
```

On `delivered`:

- Cash payment settles to `PAID`.
- Loyalty points are credited.
- Push notification is attempted.

---

# 16a. Cashier / Staff API (Phase 5)

Source: `PHASE_5_CASHIER_API_CONTRACT.md` (backend branch
`feat/phase-5-cashier-staff`, commit `5830166`).

`UserRole` gains a `CASHIER` value alongside `CUSTOMER`/`ADMIN`. A cashier
logs in through the existing normal login endpoint — no new login system:

```http
POST /api/v1/auth/login
Body: { "email": string, "password": string }
```

`POST /admin/auth/login` (and its `/auth/admin/login` alias) stay
**ADMIN-only** — a cashier gets `403 NOT_ADMIN` there.

A deactivated cashier (`isActive: false`, backed by `User.deletedAt`) cannot
log in (`401 INVALID_CREDENTIALS`) or refresh (`401 INVALID_REFRESH_TOKEN`).
An already-issued access token stays valid until its normal short TTL expiry
— there is no separate revocation mechanism.

## Staff endpoints (`ADMIN` only — `CASHIER` gets `403 FORBIDDEN`)

```http
GET /admin/staff
```
Lists all cashier accounts (active and deactivated), newest first. Returns `StaffResponseDto[]`.

```http
POST /admin/staff
Body: { "name": string, "email": string, "password": string (8-72 chars), "phone"?: string }
```
Creates a cashier. `201 StaffResponseDto`. Errors: `409 EMAIL_ALREADY_EXISTS`.

```http
PATCH /admin/staff/:id
Body: { "name"?, "email"?, "phone"?, "isActive"?: boolean, "password"?: string }
```
Partial update, all fields optional. `isActive: false` deactivates
(sets `deletedAt`); `isActive: true` reactivates. `password` re-hashes via the
normal Argon2id flow (no reset-token flow). `200 StaffResponseDto`. Errors:
`404 STAFF_NOT_FOUND`, `409 EMAIL_ALREADY_EXISTS`.

`StaffResponseDto`:

```json
{
  "id": "uuid",
  "name": "string",
  "email": "string | null",
  "phone": "string | null",
  "isActive": true,
  "createdAt": "2026-07-28T00:00:00.000Z"
}
```

## Routes still ADMIN-only (unchanged, `CASHIER` gets `403 FORBIDDEN`)

Categories, Menu, Promos, Settings, Notification campaigns, Notification
center, Uploads, Staff management itself, Customer management (below), and
both admin login routes.

---

# 16b. Customer Management API (Phase 6)

Source: `PHASE_6_CUSTOMER_MANAGEMENT_API_CONTRACT.md` (backend branch
`feat/phase-6-customer-management`, commit `561ccd1`). All routes
`@Roles('ADMIN')` only — `CASHIER` gets `403 FORBIDDEN`, same as the rest of
`/admin/*`.

```http
GET /admin/customers?q=<TEXT>&isActive=<bool>&page=1&limit=20
```
Lists `CUSTOMER`-role accounts only (ADMIN/CASHIER accounts excluded
server-side). Plain JSON array, no envelope — same convention as
`GET /admin/orders`. `q` matches name/email/phone (case-insensitive
contains). `limit` is 1-100, default 20.

`CustomerListItemDto`:
```json
{
  "id": "uuid", "name": "string", "email": "string | null",
  "phone": "string | null", "isGuest": true, "isActive": true,
  "createdAt": "ISO 8601", "orderCount": 0, "totalSpent": 0
}
```

```http
GET /admin/customers/:id
```
Returns `CustomerDetailDto` = `CustomerListItemDto` + `recentOrders` (most
recent 10, newest first, concise fields: `id`, `orderNumber`, `status`,
`totalAmount`, `paymentMethod`, `fulfillmentType`, `createdAt`). Errors:
`404 CUSTOMER_NOT_FOUND`.

```http
PATCH /admin/customers/:id/status
Body: { "isActive": true }
```
Reuses the `User.deletedAt` soft-delete column (same mechanism as Phase 5
cashier deactivation) — `isActive: false` sets `deletedAt`, blocking login/
refresh; `isActive: true` clears it. Returns the updated `CustomerDetailDto`.
Errors: `404 CUSTOMER_NOT_FOUND` (an ADMIN/CASHIER id 404s here too — this
endpoint can never touch a staff account).

`totalSpent` = sum of `Order.totalAmount` for `DELIVERED` orders only.
`orderCount` = count of all orders, any status. Both computed server-side —
never calculate locally in Flutter.

---

# 17. Admin Categories API

All require `ADMIN`.

```http
GET /admin/categories
POST /admin/categories
PUT /admin/categories/:id
DELETE /admin/categories/:id
```

Create/replace request:

```json
{
  "nameAr": "ساندوتشات",
  "nameEn": "Sandwiches",
  "iconUrl": "https://example.com/icon.jpg",
  "displayOrder": 1
}
```

Delete is soft delete.

Errors include:

- `404 CATEGORY_NOT_FOUND`
- `409 CATEGORY_HAS_ITEMS`

---

# 18. Admin Menu API

All require `ADMIN`.

```http
GET /admin/menu
POST /admin/menu/items
PUT /admin/menu/items/:id
PATCH /admin/menu/items/:id/availability
DELETE /admin/menu/items/:id
```

Create/replace body:

```json
{
  "categoryId": "uuid",
  "nameAr": "كبدة",
  "nameEn": "Liver",
  "descriptionAr": "وصف",
  "descriptionEn": "Description",
  "basePrice": 25.5,
  "imageUrl": "https://example.com/item.jpg",
  "isAvailable": true,
  "isPopular": true,
  "displayOrder": 1,
  "variants": [],
  "addonGroups": []
}
```

Update uses full diff-sync behavior for nested variants/addons. Existing nested entities omitted from the submitted set may be deleted.

Availability:

```json
{
  "isAvailable": false
}
```

---

# 19. Admin Promo API

All require `ADMIN`.

```http
GET /admin/promos
POST /admin/promos
PUT /admin/promos/:id
DELETE /admin/promos/:id
```

Request:

```json
{
  "code": "WELCOME10",
  "discountType": "PERCENT",
  "value": 10,
  "minOrderAmount": 50,
  "maxDiscountAmount": 20,
  "maxUsage": 1000,
  "perUserLimit": 1,
  "startsAt": "2026-07-28T00:00:00.000Z",
  "expiresAt": "2026-12-31T23:59:59.000Z",
  "isActive": true
}
```

Codes are normalized to uppercase.

---

# 20. Admin Settings API

All require `ADMIN`.

```http
GET /admin/settings
PUT /admin/settings
```

`PUT` is full replacement.

```json
{
  "restaurantName": "Kebda Zaman",
  "phone": "+966500000000",
  "addressText": "Jeddah",
  "taxRatePercent": 15,
  "deliveryFee": 10,
  "minOrderAmount": 30,
  "currency": "SAR",
  "workingHours": {
    "open": "10:00",
    "close": "02:00"
  },
  "isMaintenanceMode": false
}
```

---

# 21. Admin Notification Campaigns

All require `ADMIN`.

```http
POST /admin/notifications/send
POST /admin/notifications/schedule
GET /admin/notifications/campaigns
DELETE /admin/notifications/campaigns/:id
```

Immediate send request:

```json
{
  "campaignName": "Weekend Offer",
  "title": "Special offer",
  "body": "Order now",
  "imageUrl": "https://example.com/promo.jpg",
  "type": "promotion",
  "targetAudience": "ALL",
  "destinationRoute": "/menu",
  "entityId": null
}
```

Schedule adds:

```json
{
  "scheduledAt": "2026-07-30T18:00:00.000Z"
}
```

Notification type values:

```text
general
promotion
offer
new_product
category
order_created
order_confirmed
order_preparing
order_ready
order_out_for_delivery
order_delivered
order_cancelled
payment_success
payment_failed
```

Audience values:

```text
ALL
CUSTOMERS
GUESTS
```

---

# 21a. Admin Reports & Analytics API (Phase 7)

All require `ADMIN` only (unlike `admin/orders`, `CASHIER` is rejected here with
`403 FORBIDDEN`). Consumed by the admin dashboard's analytics sections
(`ReportsRepository` / `ApiReportsRepository` / `reportsDashboardProvider`).

```http
GET /admin/reports/overview?from=&to=
GET /admin/reports/sales?from=&to=&groupBy=day|week|month
GET /admin/reports/orders?from=&to=
GET /admin/reports/top-items?from=&to=&limit=10
```

- `from`/`to` are UTC date-only strings (`"YYYY-MM-DD"`); `to` is inclusive.
  Omitted on `overview`/`orders`/`top-items` means "all time"; `sales` defaults
  to a trailing 30-UTC-day window when omitted.
- `overview` — `totalRevenue`, `totalOrders`, `deliveredOrders`,
  `cancelledOrders`, `averageOrderValue`, `activeCustomers`, `newCustomers`,
  `deliveryOrders`, `pickupOrders`, `cashOrders`, `cardOrders`. Revenue/average
  are delivered-orders-only; `activeCustomers` is a global snapshot, not
  date-scoped.
- `sales` — array of `{ period, revenue, orderCount, deliveredOrderCount }`,
  already sorted ascending and gap-filled by the backend. Never re-sort,
  interpolate, or re-bucket client-side.
- `orders` — `{ byStatus[], byFulfillmentType[], byPaymentMethod[] }`, every
  enum value always present with `count: 0` (6 statuses, 2 fulfillment types,
  3 payment methods incl. `WALLET`).
- `top-items` — array of `{ menuItemId, nameAr, nameEn, quantitySold, revenue }`,
  delivered-orders-only, sorted by `quantitySold` desc then `revenue` desc.
- Do not recompute any of these numbers client-side — every field comes
  straight from the backend. See
  `PHASE_7_REPORTS_ANALYTICS_API_CONTRACT.md` (backend repo) for full field
  semantics and the `INVALID_DATE_RANGE`/`DATE_RANGE_TOO_LARGE` error codes.

---

# 22. API-Facing Enums

| Enum | Wire values |
|---|---|
| User role | `CUSTOMER`, `ADMIN` |
| Order status | `pending`, `confirmed`, `preparing`, `outForDelivery`, `delivered`, `cancelled` |
| Delivery method | `DELIVERY`, `PICKUP` |
| Checkout payment method | `CASH`, `CARD`, `WALLET` |
| Order payment method response | `cash`, `card`, `wallet` |
| Payment status | `PENDING`, `PAID`, `FAILED`, `REFUNDED` |
| Discount type | `PERCENT`, `FIXED` |
| Device platform | `ANDROID`, `IOS`, `WEB`, `MACOS`, `WINDOWS` |
| Campaign audience | `ALL`, `CUSTOMERS`, `GUESTS` |
| Campaign status | `DRAFT`, `SCHEDULED`, `SENDING`, `SENT`, `FAILED` |

Do not create one global case-conversion rule. Map each API enum explicitly.

---

# 23. Confirmed Backend/Contract Limitations

- Production domain/TLS base URL must still be configured.
- CARD and WALLET are not implemented.
- No customer order cancellation endpoint.
- No SSE order tracking endpoint.
- No backend notification history/inbox endpoint.
- No password reset endpoint.
- No pagination metadata in list responses.
- Checkout accepts an inline address object, not a saved `addressId`.
- Loyalty reward catalog and earning rate are hardcoded.
- Order status/payment casing is inconsistent with several other enums.
- Cart does not return an aggregate total.
- The app must not call the payment webhook.
- Public static uploads are under `/uploads`, outside `/api/v1`.

---

# 24. Instructions for Claude Flutter

Treat this file as the backend contract for the specified backend commit.

## Phase 1 — Audit only

Before editing code, inspect the full Flutter project and produce:

```text
FLUTTER_BACKEND_COMPARISON_AUDIT.md
```

For every endpoint verify:

1. Base URL.
2. Path.
3. HTTP method.
4. Authentication.
5. Headers.
6. Path/query parameters.
7. Request JSON.
8. Response JSON.
9. Nullable fields.
10. Enum casing.
11. Status-code handling.
12. Error-code mapping.
13. API model.
14. Repository interface.
15. Repository implementation.
16. Riverpod binding.
17. Notifier/controller.
18. UI caller.
19. Loading state.
20. Error state.
21. Empty state.
22. Mutation awaiting.
23. Provider invalidation.
24. Session restoration.
25. Logout cleanup.
26. User switching.
27. App restart.
28. Fake/local fallback.

Classify each flow as:

- Correctly connected
- Partially connected
- Missing
- Wrong path
- Wrong method
- Wrong auth
- Wrong request JSON
- Wrong response model
- Wrong enum mapping
- Fake/local implementation
- UI not connected
- Error swallowed
- Not verified

## Critical investigation order

1. Authentication and session restoration.
2. Favorites.
3. Loyalty.
4. Cart and server pricing.
5. Checkout and order creation.
6. Orders/tracking.
7. Addresses.
8. Profile.
9. FCM.
10. Remaining endpoints.

## Favorites acceptance criteria

- Add calls `POST /me/favorites` with `{menuItemId}`.
- Add parses the returned full list.
- Remove calls `DELETE /me/favorites/:menuItemId`.
- Remove correctly handles `204`.
- All favorite icons share one canonical source of truth.
- Mutations are awaited.
- Optimistic updates roll back on failure.
- Favorites reload after login/session restoration.
- Favorites clear on logout/user switch.
- API errors remain errors, not empty lists.

## Loyalty acceptance criteria

- `/me/loyalty` runs after authenticated non-guest session hydration.
- Transactions load from `/me/loyalty/transactions`.
- `pointsBalance` maps correctly.
- Failure does not become zero balance.
- Loading/error/data states remain distinct.
- Account/history refresh after redemption.
- State invalidates on logout/user switch.
- Same user sees server data after relogin.
- Guest receives a controlled not-eligible state, not zero points.

## Prohibited changes

Do not:

- Redesign application architecture.
- Replace Riverpod without necessity.
- Change backend contracts.
- Modify navigation unless required by a confirmed integration issue.
- Add fake success fallbacks.
- Keep server-persisted features as local-only data.
- Redesign UI while fixing integration.
- Modify unrelated repositories/providers.
- Recalculate authoritative checkout/order totals locally.

## Implementation sequence after approval

1. Fix P0 issues only.
2. Run `flutter analyze`.
3. Run targeted tests.
4. Fix P1 issues.
5. Run tests again.
6. Continue feature-by-feature.
7. Record every changed file and reason.
8. Stop on any backend contradiction and report it.

---

# 25. Flutter Verification Checklist

- [ ] API base URL comes from build configuration.
- [ ] All protected requests attach `Bearer` token.
- [ ] Refresh uses one shared coordinator.
- [ ] Refresh token rotation replaces both tokens.
- [ ] Refresh request is not intercepted into a refresh loop.
- [ ] Logout sends the refresh token.
- [ ] User-specific providers invalidate on logout.
- [ ] Favorites use the real API repository.
- [ ] Loyalty uses the real API repository.
- [ ] Cart uses server-returned prices.
- [ ] Checkout sends no monetary values.
- [ ] Checkout uses an idempotency key.
- [ ] Order status mapper supports `outForDelivery`.
- [ ] No unsupported `ready` order status assumption.
- [ ] No customer cancel/SSE call exists in Flutter.
- [ ] Address selection maps to inline checkout JSON.
- [ ] CARD/WALLET are disabled until backend support exists.
- [ ] FCM token registers and rotates.
- [ ] FCM token is deleted or detached on logout as required.
- [ ] Error code mapping uses backend `code`.
- [ ] Failed calls are not converted to empty/default success values.
- [ ] `flutter analyze` passes.
- [ ] No runtime exceptions.
- [ ] No layout overflow introduced during integration fixes.
