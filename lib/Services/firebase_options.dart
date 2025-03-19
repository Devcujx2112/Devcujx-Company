import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDxaB1cEVqP3R0oT43IdkRumRzjFirIzkI',
    appId: '1:82366284949:web:56a6cdb5b80f81b894479c',
    messagingSenderId: '82366284949',
    projectId: 'crud-firebase-7b852',
    authDomain: 'crud-firebase-7b852.firebaseapp.com',
    databaseURL: 'https://crud-firebase-7b852-default-rtdb.firebaseio.com',
    storageBucket: 'crud-firebase-7b852.appspot.com',
    measurementId: 'G-F968HLKVD4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBm7_74rxl3YZSxbX_jP2vZIVPe0iQwKM0',
    appId: '1:82366284949:android:33569289b34b249b94479c',
    messagingSenderId: '82366284949',
    projectId: 'crud-firebase-7b852',
    databaseURL: 'https://crud-firebase-7b852-default-rtdb.firebaseio.com',
    storageBucket: 'crud-firebase-7b852.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD9WDRvKQAogvPZ5QqASiJTvpD_58cjquc',
    appId: '1:82366284949:ios:360f43e42f5aa02d94479c',
    messagingSenderId: '82366284949',
    projectId: 'crud-firebase-7b852',
    databaseURL: 'https://crud-firebase-7b852-default-rtdb.firebaseio.com',
    storageBucket: 'crud-firebase-7b852.appspot.com',
    iosBundleId: 'com.example.orderFood',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD9WDRvKQAogvPZ5QqASiJTvpD_58cjquc',
    appId: '1:82366284949:ios:360f43e42f5aa02d94479c',
    messagingSenderId: '82366284949',
    projectId: 'crud-firebase-7b852',
    databaseURL: 'https://crud-firebase-7b852-default-rtdb.firebaseio.com',
    storageBucket: 'crud-firebase-7b852.appspot.com',
    iosBundleId: 'com.example.orderFood',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDxaB1cEVqP3R0oT43IdkRumRzjFirIzkI',
    appId: '1:82366284949:web:1b849fe77cd74b1194479c',
    messagingSenderId: '82366284949',
    projectId: 'crud-firebase-7b852',
    authDomain: 'crud-firebase-7b852.firebaseapp.com',
    databaseURL: 'https://crud-firebase-7b852-default-rtdb.firebaseio.com',
    storageBucket: 'crud-firebase-7b852.appspot.com',
    measurementId: 'G-TC5B6RV86L',
  );

}