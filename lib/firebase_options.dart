// IMPORTANT: මෙම ගොනුව flutterfire configure command එකෙන් auto-generate කල යුතුය
// නමුත් ඔබ Firebase Console වෙතින් values copy කර මෙහි paste කළ හැක
//
// ✅ Steps:
// 1. https://console.firebase.google.com/ → ඔබේ project → Project Settings → General
// 2. "Your apps" section → Web app → SDK setup → Config
// 3. පහත values update කරන්න

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
        throw UnsupportedError('iOS not configured yet');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS not configured yet');
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux not configured yet');
      default:
        throw UnsupportedError('Unknown platform: $defaultTargetPlatform');
    }
  }

  // ⚠️ මෙම values Firebase Console → Project Settings → General → Your apps → Web app → Config වෙතින් ලබා ගන්න
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:
        'AIzaSyCt53udBqwRxr9oXuAhJD84w9O_yJV1ITc', // ← Firebase Console → Web app config
    appId: '1:668766133031:web:f95b7c113530796af26702',
    messagingSenderId: '668766133031',
    projectId: 'quiz-app-202612',
    authDomain: 'quiz-app-202612.firebaseapp.com',
    storageBucket: 'quiz-app-202612.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
}
