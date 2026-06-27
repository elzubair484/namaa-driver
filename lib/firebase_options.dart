// ⚠️  This file is a placeholder.
// Run `flutterfire configure` to generate the real values for your Firebase project.
// That command will overwrite this file automatically.
//
// Steps:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<your-firebase-project-id>

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for $defaultTargetPlatform. '
          'Run flutterfire configure.',
        );
    }
  }

  // Replace these values with output from `flutterfire configure`

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALQyO2Gun6I1JAH9nRmglMVRFrndaNb9w',
    appId: '1:739032693246:web:8e1db1b530baf4ed9768af',
    messagingSenderId: '739032693246',
    projectId: 'namaa-driver-dba2f',
    authDomain: 'namaa-driver-dba2f.firebaseapp.com',
    storageBucket: 'namaa-driver-dba2f.firebasestorage.app',
    measurementId: 'G-X3C4GNKMVE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYKtV3NCxvARnAzLxE8PiP-SGuj8Y7ePg',
    appId: '1:739032693246:android:a18f3db6c12d389b9768af',
    messagingSenderId: '739032693246',
    projectId: 'namaa-driver-dba2f',
    storageBucket: 'namaa-driver-dba2f.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.namaa.driver',
  );
}
