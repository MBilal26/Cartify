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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDh1b2RfiEC3iLo1Z7pL250xwpyElkQoGw',
    appId: '1:569078026706:web:c14bc7e91a2d225675b80b',
    messagingSenderId: '569078026706',
    projectId: 'cartify-38744',
    authDomain: 'cartify-38744.firebaseapp.com',
    storageBucket: 'cartify-38744.firebasestorage.app',
    measurementId: 'G-W5PREW2JET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAH07qnepW213xP063-2GmhASS0P-5mB0k',
    appId: '1:569078026706:android:c5c38416ac3be2a275b80b',
    messagingSenderId: '569078026706',
    projectId: 'cartify-38744',
    storageBucket: 'cartify-38744.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQIq6oX3UrzODXcXglCa_xy_PPOf33TLQ',
    appId: '1:569078026706:ios:c2d1d754aef59e4575b80b',
    messagingSenderId: '569078026706',
    projectId: 'cartify-38744',
    storageBucket: 'cartify-38744.firebasestorage.app',
    iosBundleId: 'com.example.cartify',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQIq6oX3UrzODXcXglCa_xy_PPOf33TLQ',
    appId: '1:569078026706:ios:c2d1d754aef59e4575b80b',
    messagingSenderId: '569078026706',
    projectId: 'cartify-38744',
    storageBucket: 'cartify-38744.firebasestorage.app',
    iosBundleId: 'com.example.cartify',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDh1b2RfiEC3iLo1Z7pL250xwpyElkQoGw',
    appId: '1:569078026706:web:e5a9c93b304c71f375b80b',
    messagingSenderId: '569078026706',
    projectId: 'cartify-38744',
    authDomain: 'cartify-38744.firebaseapp.com',
    storageBucket: 'cartify-38744.firebasestorage.app',
    measurementId: 'G-S2R9QEBVYQ',
  );
}
