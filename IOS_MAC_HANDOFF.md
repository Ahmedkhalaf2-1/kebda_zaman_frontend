# Kebda Zaman iOS handoff

The Flutter and iOS project files are prepared for bundle ID
`com.kebdtzaman.app`. Complete the account-bound steps below before the first
iOS archive.

## Required Firebase setup

1. In Firebase project `keebda-zaman`, register a new iOS app with bundle ID
   `com.kebdtzaman.app`.
2. Download its `GoogleService-Info.plist` and place it at
   `ios/Runner/GoogleService-Info.plist`.
3. Add that file to the Runner target in Xcode (Copy items if needed and enable
   Runner target membership).
4. Re-run FlutterFire configuration so `lib/firebase_options.dart` contains the
   new iOS app ID and `iosBundleId: 'com.kebdtzaman.app'`. The currently checked
   in iOS Firebase entry belongs to `com.example.kebdaZaman` and must not be used
   for the App Store build.
5. Copy `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` into the Runner URL
   Types configuration. This is required for Google Sign-In to return to the app.
6. In Firebase Authentication, keep Google enabled and enable Apple. Complete
   Firebase's Apple provider configuration using the Apple Developer Team ID,
   Key ID, private key, and Service ID requested by the Firebase console.

## Required Apple Developer setup

1. Create or select App ID `com.kebdtzaman.app`.
2. Enable Push Notifications and Sign in with Apple for that App ID.
3. Create an APNs authentication key and upload it in Firebase Console under
   Project Settings > Cloud Messaging > Apple app configuration.
4. In Xcode, select the correct Apple Team and Automatic Signing for Runner.
5. Confirm Runner capabilities show:
   - Push Notifications
   - Background Modes > Remote notifications
   - Sign in with Apple

## Mac build commands

```bash
flutter clean
flutter pub get
cd ios
pod install --repo-update
open Runner.xcworkspace
```

Always open `Runner.xcworkspace`, not `Runner.xcodeproj`.

## Smoke tests before Archive

- Email/password login and account creation.
- Google Sign-In returns to the app and creates a backend session.
- Apple Sign-In works with both Share My Email and Hide My Email.
- Account deletion after Google or Apple Sign-In.
- Location permission and map address selection.
- Photo library and camera permission flows.
- FCM notification in foreground, background, and terminated states.
- Release build uses the production API base URL.

Then run Product > Archive, validate the archive, upload it to TestFlight, and
complete the App Store Connect privacy labels to match the in-app privacy policy.
