# Kebda Zaman — iOS Publisher Handoff

This document is for whoever finishes the iOS release on a Mac. Everything
that could safely be prepared from Windows has already been done (see
"Current state" below). The steps in this document are the remaining
account-bound, signing, and device-testing work that requires Xcode and
Apple/Firebase account access.

- **Production API:** `https://api.kebdazaman.cloud/api/v1`
- **App version:** `1.0.0+1`
- **Bundle ID:** `com.kebdtzaman.app`
- **Firebase project:** `keebda-zaman`
- **Privacy Policy URL:** `https://legal.kebdazaman.cloud/privacy`

## Current state (already done, for context)

- `ios/Runner.xcodeproj/project.pbxproj` has `PRODUCT_BUNDLE_IDENTIFIER =
  com.kebdtzaman.app` for Debug/Release/RunnerTests.
- The real `ios/Runner/GoogleService-Info.plist` (for `com.kebdtzaman.app`)
  is in place and referenced in the Runner target's Resources build phase.
- `lib/firebase_options.dart`'s `ios` block has been regenerated to match
  that plist (real app ID, `iosBundleId: 'com.kebdtzaman.app'`).
- `ios/Runner/Info.plist` has a `CFBundleURLTypes` entry with the real
  `REVERSED_CLIENT_ID` for Google Sign-In.
- `ios/Runner/AppDelegate.swift` calls `GMSServices.provideAPIKey(...)` with
  a real (already-restricted) iOS Google Maps API key.
- `ios/Runner/Runner.entitlements` declares `aps-environment` and
  `com.apple.developer.applesignin`.
- `ios/Runner/PrivacyInfo.xcprivacy` exists and is included in the Runner
  target.
- Permission usage descriptions (Camera, Location, Photo Library) are set
  in `ios/Runner/Info.plist`.

None of that removes the need for the manual steps below — Xcode signing,
Firebase Console/Apple Developer account configuration, and device testing
cannot be done from Windows.

## 1. Open and prepare the project on macOS

1. Pull the latest branch onto the Mac.
2. Confirm you're on Flutter's stable channel and the SDK version matches
   `environment.sdk` in `pubspec.yaml` (`^3.8.1`).
3. Do **not** run `flutter create .` — the iOS project is already
   hand-configured; regenerating it would discard the setup above.

## 2. Run Flutter and CocoaPods setup commands

```bash
flutter clean
flutter pub get
cd ios
pod install --repo-update
cd ..
```

## 3. Open the workspace

Always open `ios/Runner.xcworkspace` in Xcode — **never**
`ios/Runner.xcodeproj` directly (opening the `.xcodeproj` skips CocoaPods'
linked frameworks and the build will fail).

```bash
open ios/Runner.xcworkspace
```

## 4. Select the correct Apple Developer Team

In Xcode: select the `Runner` project → `Runner` target → **Signing &
Capabilities** tab → set **Team** to the Kebda Zaman Apple Developer
account/team. Do this for both the `Runner` and `RunnerTests` targets if
you intend to run tests on-device.

## 5. Verify the Bundle Identifier

In the same **Signing & Capabilities** tab, confirm **Bundle Identifier**
reads exactly:

```
com.kebdtzaman.app
```

This should already be correct (it's set in the pbxproj) — this step is a
verification, not a change. If it does not match, stop and investigate
before continuing; do not edit it to "make it work."

## 6. Configure automatic signing

In **Signing & Capabilities**, enable **Automatically manage signing** with
the Team selected in step 4. Xcode will provision a signing certificate and
profile for `com.kebdtzaman.app` under that team. Resolve any signing
errors here before proceeding (e.g. missing paid Apple Developer Program
membership, or the App ID not yet existing — see section 8).

## 7. Enable required capabilities

Still in **Signing & Capabilities**, use **+ Capability** to add (if not
already listed):

- **Sign in with Apple**
- **Push Notifications**
- **Background Modes** → check **Remote notifications**

Adding these in Xcode updates `ios/Runner/Runner.entitlements` and the
project's provisioning automatically — the entitlements file already has
the `aps-environment` and Apple Sign-In keys set from the Windows-side
prep, so Xcode should recognize and match them rather than create
duplicates. If Xcode reports a mismatch, let Xcode's UI regenerate the
entitlement rather than hand-editing the file.

## 8. Create and upload the APNs authentication key to Firebase

1. In [Apple Developer](https://developer.apple.com) → **Certificates,
   Identifiers & Profiles** → **Keys**, create a new key with the **Apple
   Push Notifications service (APNs)** capability enabled.
2. Download the `.p8` key file **once** (Apple only lets you download it
   once) and store it securely (see the checklist below — do not commit it
   to the repo).
3. Note the **Key ID** and your **Team ID**.
4. In [Firebase Console](https://console.firebase.google.com) → project
   `keebda-zaman` → **Project Settings** → **Cloud Messaging** → **Apple
   app configuration** → upload the `.p8` file along with the Key ID and
   Team ID.

## 9. Configure Apple Sign-In in Firebase Authentication

1. In Apple Developer, ensure the App ID `com.kebdtzaman.app` has **Sign in
   with Apple** enabled (done as part of step 7/App ID setup).
2. Create a **Services ID** for Sign in with Apple if Firebase's console
   flow requires one for your configuration, and register the domain/return
   URL Firebase specifies.
3. In Firebase Console → **Authentication** → **Sign-in method** → enable
   **Apple**, and provide the Team ID, Key ID, private key, and Service ID
   Firebase's setup flow asks for.
4. Confirm **Google** remains enabled alongside Apple — do not disable it.

## 10. Run and test on a real iPhone

Connect a physical iPhone (the simulator cannot receive real APNs pushes
or exercise real Sign in with Apple / Maps location behavior reliably).
In Xcode, select the device as the run destination and run the app
(`Cmd+R`), or via CLI:

```bash
flutter run --release -d <device-id>
```

## 11. Smoke test checklist (must all pass before Archive)

Run these against the production API — confirm the app's debug console
shows `Running with API_BASE_URL: https://api.kebdazaman.cloud/api/v1`
(no `--dart-define` override active):

- [ ] Email/password login and account creation.
- [ ] **Google Sign-In** — returns to the app and creates a backend
      session.
- [ ] **Apple Sign-In** — works with both "Share My Email" and "Hide My
      Email" options.
- [ ] **Maps** — map screens render (address picker, admin location
      picker) with the real Maps API key.
- [ ] **Location** — When-In-Use permission prompt appears with the
      expected message; location-based address selection works.
- [ ] **Notifications** — FCM push received in foreground, background, and
      terminated app states; tapping a notification navigates correctly.
- [ ] **Ordering** — full flow: browse menu → cart → checkout → order
      placed and tracked.
- [ ] **Payment** — exercise whatever payment path is currently wired for
      production (confirm with the team whether this is still a stub or a
      real gateway before testing — do not assume).
- [ ] **Account deletion** — after both a Google-linked and an
      Apple-linked account, confirm the account is deleted and the app
      returns to a logged-out state.
- [ ] Camera and Photo Library permission prompts appear correctly when
      picking a profile photo.

## 12. Create an Archive

In Xcode: **Product → Archive**. This requires a physical-device or
"Any iOS Device" build target (not the simulator) and a release
configuration with valid signing from steps 4–7.

## 13. Upload the build to TestFlight

From the Xcode Organizer window after archiving: **Distribute App → App
Store Connect → Upload**. Wait for Apple's processing to complete, then
confirm the build appears under **TestFlight** in App Store Connect and
passes automated compliance checks (export compliance — this app does not
use non-exempt encryption beyond standard HTTPS/TLS, confirm this is still
accurate before answering the compliance questionnaire).

## 14. Complete App Store Connect information and submit for review

- App description, screenshots (per required device sizes), keywords,
  support URL, marketing URL.
- Privacy Policy URL: `https://legal.kebdazaman.cloud/privacy`. Also set
  the **Privacy Nutrition Label** answers to match what the app actually
  collects (auth identifiers, location for delivery, order history,
  device/FCM token for push). Cross-check against `PrivacyInfo.xcprivacy`
  and the permission descriptions already set.
- Age rating questionnaire.
- A **demo/review account** (see checklist below) if the app requires
  login to be reviewed, with instructions for the reviewer in the "Notes"
  field.
- Attach the uploaded TestFlight build to the App Store version and submit
  for review.

---

## Checklist — assets and information you must securely provide

Do **not** paste any of these values into chat, commit them to the repo,
or store them in plaintext files tracked by git. Use a password manager,
Apple Developer/Firebase's own secure storage, or a secrets manager.

- [ ] Apple Developer Program membership access (Team ID + admin/App
      Manager role) for the account that owns `com.kebdtzaman.app`.
- [ ] APNs authentication key (`.p8` file) + its Key ID.
- [ ] Firebase Console admin access to project `keebda-zaman`.
- [ ] Apple Sign-In Services ID / Team ID / Key ID / private key as
      requested by Firebase's Apple provider setup flow.
- [ ] App Store Connect access (admin or App Manager role) for the app
      record.
- [ ] App icon and marketing assets already in `assets/photos/` — confirm
      these are current (`AppIcon~ios-marketing.png`,
      `play_store_512.png`) or supply updated ones.
- [ ] Screenshots for each required App Store device size.
- [ ] Support URL (Privacy Policy URL is already set: `https://legal.kebdazaman.cloud/privacy`).
- [ ] A demo/reviewer account (username + password) if the app cannot be
      reviewed without logging in — provide this only through App Store
      Connect's own "App Review Information" fields, never in chat or in
      the repo.
- [ ] Confirmation of the current production payment integration status,
      so reviewers/testers know what to expect from the payment flow.

## ⚠️ Warning

**Do not commit, paste into chat/PRs, or otherwise print in plaintext:**
API keys (Firebase, Google Maps, etc.), passwords, the APNs `.p8` private
key or its contents, Apple/Firebase account credentials, or App Store
Connect reviewer/demo account credentials. Store and transmit all of these
only through the platforms' own secure mechanisms (Apple Developer, App
Store Connect "App Review Information," Firebase Console, a password
manager). If a secret is ever accidentally committed or pasted, rotate/
revoke it immediately rather than just deleting the message or commit.
