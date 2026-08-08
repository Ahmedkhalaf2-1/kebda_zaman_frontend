// File generated using values from android/app/google-services.json
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChY2M91N0h4yYhGBczkOF87z9zpgnqOjM',
    appId: '1:168591231387:web:a8c926bf0f4b72ce42793e',
    messagingSenderId: '168591231387',
    projectId: 'keebda-zaman',
    authDomain: 'keebda-zaman.firebaseapp.com',
    storageBucket: 'keebda-zaman.firebasestorage.app',
    measurementId: 'G-7LHDM3JDVC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDit0ZuQAPZiPvgbtSqdMp-QVltOmGRktc',
    appId: '1:168591231387:android:c997be1364dc28de42793e',
    messagingSenderId: '168591231387',
    projectId: 'keebda-zaman',
    storageBucket: 'keebda-zaman.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxFTS2dJy5HX3lpnpRQQ6NXwvY2KnedGw',
    appId: '1:168591231387:ios:ceb4fe71d1511a7542793e',
    messagingSenderId: '168591231387',
    projectId: 'keebda-zaman',
    storageBucket: 'keebda-zaman.firebasestorage.app',
    iosBundleId: 'com.kebdtzaman.app',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDxFTS2dJy5HX3lpnpRQQ6NXwvY2KnedGw',
    appId: '1:168591231387:ios:cae51cc8b2fffcfd42793e',
    messagingSenderId: '168591231387',
    projectId: 'keebda-zaman',
    storageBucket: 'keebda-zaman.firebasestorage.app',
    iosBundleId: 'com.example.kebdaZaman',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyChY2M91N0h4yYhGBczkOF87z9zpgnqOjM',
    appId: '1:168591231387:web:50acd21707c3054942793e',
    messagingSenderId: '168591231387',
    projectId: 'keebda-zaman',
    authDomain: 'keebda-zaman.firebaseapp.com',
    storageBucket: 'keebda-zaman.firebasestorage.app',
    measurementId: 'G-1EJBZFQ53N',
  );
}
