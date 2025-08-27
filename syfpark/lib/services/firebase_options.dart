// lib/services/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    }
    throw UnsupportedError('Only Android is supported for now');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYCTppBRZyo7aIz8LNh-cXyS3aS-uJbOw',
    appId: '1:54095230231:android:32f0e9020d5f2258dd7352',
    messagingSenderId: '54095230231',
    projectId: 'geecko-d0f14',
    storageBucket: 'geecko-d0f14.firebasestorage.app',
  );
}