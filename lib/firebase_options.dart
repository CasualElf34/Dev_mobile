import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAsIkQR8ftqGrv9-gRM3N1nnVSEb_uoEck',
    appId: '1:113350609039:android:ef01effffbfd34e4a088fa', 
    messagingSenderId: '113350609039',
    projectId: 'automobile-e5798',
    authDomain: 'automobile-e5798.firebaseapp.com',
    storageBucket: 'automobile-e5798.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsIkQR8ftqGrv9-gRM3N1nnVSEb_uoEck',
    appId: '1:113350609039:android:ef01effffbfd34e4a088fa', // Mis à jour pour com.LeCoinAuto
    messagingSenderId: '113350609039',
    projectId: 'automobile-e5798',
    storageBucket: 'automobile-e5798.firebasestorage.app',
  );
}
