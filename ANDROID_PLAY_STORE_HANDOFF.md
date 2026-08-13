# Kebda Zaman — Android / Google Play Publisher Handoff

This document is for whoever finishes the Android release. Everything that
could safely be prepared ahead of time has already been done (see "Current
state" below). What's left is Play Console account-bound work: creating the
app listing, filling in Play's own forms, and uploading the build.

- **Production API:** `https://api.kebdazaman.cloud/api/v1`
- **App version:** `1.0.0+1` (`versionName 1.0.0`, `versionCode 1`)
- **Package name (applicationId):** `com.kebdtzaman.app`
- **Firebase project:** `keebda-zaman`
- **Privacy Policy URL:** `https://legal.kebdazaman.cloud/privacy`

None of the remaining work requires any backend/API changes — everything
below is either a Play Console form, a store-listing asset, or a build/
packaging step.

## Current state (already done, for context)

- `applicationId = com.kebdtzaman.app`, `compileSdk = 36`, `targetSdk = 36`
  (Android 16) — already meets Google Play's **August 31, 2026** new-app
  target-API requirement; nothing to change here.
- Android Gradle Plugin **8.7.3** (Gradle 8.12) — meets the ≥8.5.1 minimum
  for the 16 KB memory page-size requirement (see step 4 below for the part
  that still needs verifying).
- Release signing is fully configured: `android/key.properties` points at
  a real upload keystore (`keyAlias=upload`), and `android/app/build.gradle.kts`
  wires it into the `release` build type. `key.properties`, `*.jks`, and
  `local.properties` are all `.gitignore`d — none of that is in the repo.
- Adaptive launcher icon is complete for every density, including the
  Android 13+ **monochrome** variant (themed icons).
- `android/app/google-services.json` (real Firebase Android config) is in
  place — committed to the repo, which is fine per Firebase's own guidance
  (it's not a secret; it ships inside every APK/AAB regardless).
- Manifest is clean: no cleartext traffic, `android:exported="true"`
  correctly declared on the launcher activity (required on API 31+), and
  only the permissions the app actually uses (`INTERNET`,
  `POST_NOTIFICATIONS`, `VIBRATE`, `ACCESS_FINE_LOCATION`,
  `ACCESS_COARSE_LOCATION`, `USE_BIOMETRIC`).
- In-app Privacy Policy and Terms of Service screens exist and are routed
  (`/legal/privacy`, `/legal/terms`), and in-app account deletion exists
  (`delete_account_dialog.dart`) — Play requires both.
- App icon assets for the store listing already exist in `assets/photos/`
  (`play_store_512.png`).

## 1. Create the Play Console app record

If it doesn't already exist: [Play Console](https://play.google.com/console)
→ **Create app** → package name `com.kebdtzaman.app`. Requires a Google
Play Developer account (one-time $25 registration fee if not already
enrolled).

## 2. Build the signed release App Bundle

Google Play requires the **Android App Bundle (.aab)** format, not a plain
APK, for new app submissions.

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`. This is
already signed with the real upload keystore (from `key.properties`) — it's
ready to upload to Play Console as-is, no further signing step needed.

If you also want an installable file for manual sideload-testing on a
device before uploading (Play Console can't be used for that — it only
accepts the `.aab`):

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk` — same signing key,
directly installable via `adb install` or by copying it to a device.

## 3. Verify the 16 KB page-size requirement

Google Play started blocking updates on **May 31, 2026** for apps that
don't support 16 KB memory page-size devices. AGP 8.7.3 (used here) handles
*this app's own* code correctly, but third-party native libraries (Google
Maps, Firebase, `local_auth`, `webview_flutter`, Moyasar) also have to ship
16 KB-aligned binaries — that can only really be confirmed after uploading,
via Play Console's **App Bundle Explorer** / pre-launch report, which flags
any non-compliant native library. Check this on the first upload before
assuming the build is fully compliant.

## 4. Store listing

In Play Console → your app → **Store presence → Main store listing**:

- App name, short description, full description.
- **Screenshots** — phone screenshots (minimum 2, Google recommends 4-8) at
  at least 320px on the short side. Tablet screenshots are optional but
  recommended if you want tablet placement.
- **Feature graphic** — 1024×500px banner shown at the top of the listing
  (does not exist in this repo yet — needs to be created).
- App icon — `assets/photos/play_store_512.png` already exists (512×512,
  32-bit PNG with alpha, matches Play's spec).
- Category, contact details, and the same Privacy Policy URL above.

## 5. Data Safety form

Play Console → **App content → Data safety**. This just needs to describe
what the app already collects/sends — matches exactly what the iOS handoff
doc's Privacy Nutrition Label answers cover, since it's the same app/API:

- **Personal info**: name, email, phone (account/profile, delivery contact).
- **Location**: precise location (delivery address selection — collected,
  not shared with third parties beyond what's needed to compute delivery
  distance/fee).
- **App activity**: order history, in-app search history.
- **Device/other IDs**: FCM device/push token.
- **Financial info**: only if/when a real payment gateway is live in
  production — confirm current payment integration status (see the iOS
  handoff doc's note on the same question) before answering this section,
  since it changes the answer.

Also answer: data is transmitted over HTTPS (yes — the API is HTTPS-only,
no cleartext), and whether users can request data deletion (yes — in-app,
see step 6).

## 6. Data deletion — public web page requirement

Play requires apps that support account creation to provide a way to
request account/data deletion **that doesn't require having the app
installed** (a web page), in addition to the in-app deletion flow that
already exists. Confirm whether `https://legal.kebdazaman.cloud` already
has this page; if not, it needs to be added (a static page — not an API
change) and its URL entered in the Data Safety form.

## 7. Content rating questionnaire

Play Console → **App content → Content rating** — answer Play's
questionnaire (food ordering app, no user-generated content beyond order
notes, no violence/gambling/etc.) to get an IARC rating.

## 8. Recommended: internal/closed testing track first

Rather than releasing straight to production, upload the `.aab` to an
**Internal testing** or **Closed testing** track first, add a few tester
emails, and confirm the production API, push notifications, Google Sign-In,
Maps, and checkout all work on a real device from a Play-installed build
(not just `flutter run`) before promoting to production.

## 9. Promote to production

Once the internal/closed test passes: Play Console → promote the tested
release to the **Production** track, complete the release notes, and
submit. Google's review is typically faster than Apple's, but can still
take from a few hours to a few days.

---

## Checklist — access/assets you'll need

- [ ] Google Play Developer account access (with permission to create/manage
      this app) for whoever does the Play Console work.
- [ ] The real upload keystore file (`kebda-zaman-upload-keystore.jks`) plus
      its store/key passwords — hand these off only through a password
      manager or other secure channel, never in chat or committed to git.
- [ ] Feature graphic (1024×500px) — does not exist yet, needs designing.
- [ ] Phone screenshots (and optionally tablet) for the store listing.
- [ ] Confirmation of current production payment integration status, so the
      Data Safety "Financial info" section is answered accurately.
- [ ] Confirmation that `legal.kebdazaman.cloud` has (or will have) a public
      data-deletion request page, and its URL.

## ⚠️ Warning

**Do not commit, paste into chat, or otherwise print in plaintext:** the
upload keystore file or its passwords, the Play Console account
credentials, or any API keys. `android/key.properties` and the `.jks` file
are already `.gitignore`d — keep it that way. If a secret is ever
accidentally committed or pasted, rotate/revoke it immediately rather than
just deleting the message or commit.
