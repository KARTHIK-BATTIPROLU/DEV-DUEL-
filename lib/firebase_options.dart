// File generated for Firebase configuration
// IMPORTANT: Replace these placeholder values with your actual Firebase project configuration
// You can get these values from the Firebase Console -> Project Settings -> Your apps
//
// For production, run: flutterfire configure
// This will automatically generate the correct configuration for your project

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for the current platform
/// 
/// SETUP INSTRUCTIONS:
/// 1. Go to Firebase Console (https://console.firebase.google.com)
/// 2. Create a new project or select existing project
/// 3. Add your apps (Android, iOS, Web)
/// 4. Copy the configuration values to this file
/// 5. OR run: flutterfire configure (recommended)
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ============================================================
  // REPLACE THESE PLACEHOLDER VALUES WITH YOUR FIREBASE CONFIG
  // ============================================================

  /// Web configuration

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAd3p_8MDWaOf2n4aDSZsQ2IQFuNi9aMeA',
    appId: '1:758249619738:web:c2019f03592a38b9146ca3',
    messagingSenderId: '758249619738',
    projectId: 'online-learning-app-2bd4b',
    authDomain: 'online-learning-app-2bd4b.firebaseapp.com',
    storageBucket: 'online-learning-app-2bd4b.firebasestorage.app',
    measurementId: 'G-CVME2NM5FJ',
  );

  /// Get these values from Firebase Console -> Project Settings -> Web app

  /// Android configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtJ-kwneANtMiciDjLDtVl496blNKUkOM',
    appId: '1:758249619738:android:1dc0e7d460974da3146ca3',
    messagingSenderId: '758249619738',
    projectId: 'online-learning-app-2bd4b',
    storageBucket: 'online-learning-app-2bd4b.firebasestorage.app',
  );

  /// Get these values from Firebase Console -> Project Settings -> Android app

  /// iOS configuration

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjexMRorW8nXemUzB5H6MK-kIzMf3txmA',
    appId: '1:758249619738:ios:699ae5c63d77f897146ca3',
    messagingSenderId: '758249619738',
    projectId: 'online-learning-app-2bd4b',
    storageBucket: 'online-learning-app-2bd4b.firebasestorage.app',
    iosBundleId: 'com.learning.onlineLearningApp',
  );

  /// Get these values from Firebase Console -> Project Settings -> iOS app
}