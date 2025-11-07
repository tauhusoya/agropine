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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWWB1or28RgDZ0GIBPue8mCO86Vp7YHi4',
    appId: '1:612503189153:web:7eb50aa047ad8def5462e0',
    messagingSenderId: '612503189153',
    projectId: 'agropine-242ef',
    authDomain: 'agropine-242ef.firebaseapp.com',
    storageBucket: 'agropine-242ef.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWWB1or28RgDZ0GIBPue8mCO86Vp7YHi4',
    appId: '1:612503189153:android:82501f83c8082ded5462e0',
    messagingSenderId: '612503189153',
    projectId: 'agropine-242ef',
    storageBucket: 'agropine-242ef.firebasestorage.app',
  );
}
