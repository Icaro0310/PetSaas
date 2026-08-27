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
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions ainda nao configurado para $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA2v_Z4wV4v4Q9zfRFTf20ueDv7B8_-ypU',
    appId: '1:401594264567:web:150c29e4949b1d52701cf2',
    messagingSenderId: '401594264567',
    projectId: 'saaspet-3386c',
    authDomain: 'saaspet-3386c.firebaseapp.com',
    storageBucket: 'saaspet-3386c.firebasestorage.app',
    measurementId: 'G-8CKVV4T99C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlsoSL-rmuepF2GFcMFpp5_bErc1Z3M4A',
    appId: '1:401594264567:android:56d305bc5716bae0701cf2',
    messagingSenderId: '401594264567',
    projectId: 'saaspet-3386c',
    storageBucket: 'saaspet-3386c.firebasestorage.app',
  );
}
