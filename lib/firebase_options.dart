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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4a2aD7iIvdBC5ABATxyGaiMCA9vvTXtk',
    appId: '1:446445257756:android:9350f1800c446be2140bd9',
    messagingSenderId: '446445257756',
    projectId: 'novoact-fa1e1',
    storageBucket: 'novoact-fa1e1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4a2aD7iIvdBC5ABATxyGaiMCA9vvTXtk',
    appId: '1:446445257756:ios:9350f1800c446be2140bd9',
    messagingSenderId: '446445257756',
    projectId: 'novoact-fa1e1',
    storageBucket: 'novoact-fa1e1.firebasestorage.app',
    iosBundleId: 'com.example.novoact',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC4a2aD7iIvdBC5ABATxyGaiMCA9vvTXtk',
    appId: '1:446445257756:web:9350f1800c446be2140bd9',
    messagingSenderId: '446445257756',
    projectId: 'novoact-fa1e1',
    authDomain: 'novoact-fa1e1.firebaseapp.com',
    storageBucket: 'novoact-fa1e1.firebasestorage.app',
  );
}