# Kebda Zaman — Push Notification System & Backend Integration Contract

## 1. Executive Summary & Architecture Overview

This document specifies the technical contract and API endpoints required for the future Backend API service to support Push Notifications for **Kebda Zaman** (Customer Flutter App & Admin Panel).

### Security Architecture Rule
- **No secrets in frontends**: Firebase Admin SDK service account credentials, private keys, and FCM Server Keys MUST NEVER be stored in the Flutter mobile application or the Admin Panel frontend.
- **Backend as Proxy & Controller**: The Admin Panel communicates exclusively with the Backend API. The Backend API validates admin authorization, persists campaigns, and invokes the Firebase Admin SDK / FCM HTTP v1 API.

```
+------------------+         POST /admin/notifications/send       +-------------------+
|                  | -------------------------------------------> |                   |
|   Admin Panel    |                                              |                   |
|     Frontend     | <------------------------------------------- |                   |
+------------------+           HTTP 200 / Campaign JSON           |    Backend API    |
                                                                  |  (Node / Python / |
+------------------+          POST /devices/register              |      Go / Java)   |
|  Flutter Customer| -------------------------------------------> |                   |
|       App        |                                              +-------------------+
+------------------+                                                        |
         ^                                                                  | Firebase Admin SDK /
         |                      FCM Push Notification                       | FCM HTTP v1 API
         +------------------------------------------------------------------+
                                  (Google FCM Servers)
```

---

## 2. Customer Device Token APIs

### 2.1 Device Registration
**Endpoint:** `POST /api/v1/devices/register`  
**Authentication:** Required (User JWT / Bearer Token or Guest Session ID)  
**Description:** Registers or updates a device's FCM token on the backend for targeted push notifications.

#### Request Headers
```http
Authorization: Bearer <user_jwt_token>
Content-Type: application/json
```

#### Request Body
```json
{
  "fcmToken": "f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2...",
  "platform": "android",
  "appVersion": "1.0.0",
  "deviceModel": "Pixel 7 Pro",
  "locale": "ar"
}
```

#### Response (200 OK)
```json
{
  "success": true,
  "message": "Device token registered successfully",
  "deviceId": "dev_987654321"
}
```

---

### 2.2 Token Refresh & Invalidation
- `PUT /api/v1/devices/token`: Called when `FirebaseMessaging.instance.onTokenRefresh` triggers on mobile.
- `DELETE /api/v1/devices/token`: Called when user logs out of the customer app to stop receiving personal push notifications.

#### Request Body (Invalidate on Logout)
```json
{
  "fcmToken": "f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2..."
}
```

---

## 3. Admin Notification Campaign APIs

### 3.1 Send Immediate Campaign
**Endpoint:** `POST /api/v1/admin/notifications/send`  
**Authentication:** Required (Admin JWT with `ROLE_ADMIN` permission)

#### Request Body
```json
{
  "campaignName": "Weekend Kebda Deal",
  "title": "خصم 20% على كل الوجبات! 🔥",
  "body": "استمتع بأقوى العروض مع كبدة زمان، اطلب الآن طازج وسريع!",
  "imageUrl": "https://cdn.kebdazaman.com/promos/weekend_special.jpg",
  "type": "offer",
  "targetAudience": "all_users",
  "destinationRoute": "/menu",
  "entityId": "item_kebda_01"
}
```

#### Response (200 OK)
```json
{
  "success": true,
  "campaignId": "camp_2026_07_001",
  "status": "sent",
  "sentAt": "2026-07-23T18:30:00Z",
  "totalRecipients": 1540
}
```

---

### 3.2 Schedule Campaign for Later
**Endpoint:** `POST /api/v1/admin/notifications/schedule`  
**Authentication:** Required (`ROLE_ADMIN`)

#### Request Body
```json
{
  "campaignName": "Friday Special",
  "title": "عروض الجمعة المباركة من كبدة زمان 🎉",
  "body": "جمع العيلة واستمتع بوجبة كبدة وزقزوقة زمان!",
  "imageUrl": null,
  "type": "promotion",
  "targetAudience": "city:cairo",
  "destinationRoute": "/offers",
  "scheduledAt": "2026-07-25T12:00:00Z"
}
```

---

### 3.3 List Campaigns & History
**Endpoint:** `GET /api/v1/admin/notifications/campaigns`  
**Response (200 OK):**
```json
{
  "campaigns": [
    {
      "id": "camp_001",
      "campaignName": "Weekend Kebda Special Deal",
      "title": "خصم 20% على جميع الوجبات",
      "body": "استمتع بالعرض الخاص اليوم!",
      "type": "offer",
      "targetAudience": "All Users",
      "status": "sent",
      "sentAt": "2026-07-21T14:00:00Z",
      "totalRecipients": 1450,
      "deliveredCount": 1420,
      "openedCount": 890,
      "clickRate": 62.6
    }
  ]
}
```

---

## 4. Standard FCM Payload Contract

When the Backend sends a notification through FCM HTTP v1 API to Google FCM servers, the data payload MUST follow this standardized JSON schema so the Flutter app's `AppNotificationPayload` can safely parse it and handle deep-link navigation:

```json
{
  "message": {
    "topic": "all_users",
    "notification": {
      "title": "خصم 20% على وجبات الكبدة!",
      "body": "اطلب الآن واستمتع بالطعم الأصلي"
    },
    "data": {
      "id": "notif_100982",
      "type": "offer",
      "title": "خصم 20% على وجبات الكبدة!",
      "body": "اطلب الآن واستمتع بالطعم الأصلي",
      "route": "/item/item_kebda_01",
      "entityId": "item_kebda_01",
      "imageUrl": "https://cdn.kebdazaman.com/images/kebda.jpg",
      "timestamp": "2026-07-23T18:30:00Z"
    },
    "android": {
      "priority": "HIGH",
      "notification": {
        "channel_id": "kebda_zaman_high_importance_channel",
        "sound": "default"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "alert": {
            "title": "خصم 20% على وجبات الكبدة!",
            "body": "اطلب الآن واستمتع بالطعم الأصلي"
          },
          "sound": "default",
          "badge": 1
        }
      }
    }
  }
}
```

---

## 5. In-App Notification & Analytics Specification

### 5.1 In-App Inbox (`GET /api/v1/notifications`)
Allows the customer app to display an in-app notifications inbox.
- `GET /notifications`: Retrieve list of past notifications for logged-in user.
- `PATCH /notifications/:id/read`: Mark notification as read.

### 5.2 Delivery & Click Analytics
- `POST /api/v1/notifications/:id/track-click`: Track when a user taps a push notification to compute click rates (`clickRate`) in Admin Analytics.

---

## 6. Checklist for Firebase Setup & Backend Developer

1. **FlutterFire CLI Setup (When ready for Firebase):**
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
2. **Backend FCM Integration:**
   - Install `firebase-admin` SDK on backend.
   - Generate Service Account JSON from Firebase Console -> Project Settings -> Service Accounts.
   - Store Service Account JSON securely in Backend Environment Variables (e.g. `GOOGLE_APPLICATION_CREDENTIALS`).
