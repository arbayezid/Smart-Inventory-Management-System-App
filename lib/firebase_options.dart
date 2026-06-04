// File generated manually from Firebase project: smart-inventory-cf61a
// For flutterfire-generated options, run: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web; // fallback to web options for desktop
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD6hfmsp_2aIrVfbTRAtKOSeW2lpfXFVGs',
    authDomain: 'smart-inventory-cf61a.firebaseapp.com',
    projectId: 'smart-inventory-cf61a',
    storageBucket: 'smart-inventory-cf61a.appspot.com',
    messagingSenderId: '361423125686',
    appId: '1:361423125686:web:e8b7cde835aa1907117a17',
  );

  // Android: values sourced from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnjNCvd30WgLttoNeNOPC3o2GtpBtVb2o', // Android-specific key from google-services.json
    appId: '1:361423125686:android:35030bb7f194f94b117a17',
    messagingSenderId: '361423125686',
    projectId: 'smart-inventory-cf61a',
    storageBucket: 'smart-inventory-cf61a.firebasestorage.app',
  );

  // iOS: add GoogleService-Info.plist and update these values
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6hfmsp_2aIrVfbTRAtKOSeW2lpfXFVGs',
    appId:
        '1:361423125686:ios:000000000000000', // Replace with real value from GoogleService-Info.plist
    messagingSenderId: '361423125686',
    projectId: 'smart-inventory-cf61a',
    storageBucket: 'smart-inventory-cf61a.appspot.com',
    iosBundleId: 'com.example.mobileApp',
  );
}
