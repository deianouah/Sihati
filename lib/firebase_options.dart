import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      return ios;
    }
    // Add Android options here if needed
    return ios; // fallback
  }

  static const FirebaseOptions ios = FirebaseOptions(
    appId: '1:941708085558:ios:a1bb070ca0891f5bcd8b97',
    apiKey: 'AIzaSyABnaNVnziiFzt0mUDYG7l6_aU7WHMSxr4',
    projectId: 'sihati-b5868',
    messagingSenderId: '941708085558',
    storageBucket: 'sihati-b5868.firebasestorage.app',
    iosBundleId: 'taysirone',
  );

  // You can define android options similarly if required.
}
