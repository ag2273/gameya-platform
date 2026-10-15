import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Generated from google-services.json for project `gameya-platform`.
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
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVB1OwVX2es2WNCKMlc7EVA_jBDIzizqE',
    appId: '1:44131805915:android:4dbff7a9ddf6e06bfbfafe',
    messagingSenderId: '44131805915',
    projectId: 'gameya-platform',
    storageBucket: 'gameya-platform.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVB1OwVX2es2WNCKMlc7EVA_jBDIzizqE',
    appId: '1:44131805915:android:4dbff7a9ddf6e06bfbfafe', // Fallback until iOS app is registered
    messagingSenderId: '44131805915',
    projectId: 'gameya-platform',
    storageBucket: 'gameya-platform.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVB1OwVX2es2WNCKMlc7EVA_jBDIzizqE',
    appId: '1:44131805915:android:4dbff7a9ddf6e06bfbfafe',
    messagingSenderId: '44131805915',
    projectId: 'gameya-platform',
    storageBucket: 'gameya-platform.firebasestorage.app',
  );
}
