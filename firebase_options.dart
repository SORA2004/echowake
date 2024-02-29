// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
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
    apiKey: 'AIzaSyBa9fQJpS20HxQde07AWZEjeIziOlEIgg4',
    appId: '1:1029106640002:android:9ea94436e70e77d223009b',
    messagingSenderId: '1029106640002',
    projectId: 'echowake-b5331',
    storageBucket: 'echowake-b5331.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAurwLq28j68c_M-z59hUzN3OAcwSb2cZo',
    appId: '1:1029106640002:ios:3102b71a4cf48f8523009b',
    messagingSenderId: '1029106640002',
    projectId: 'echowake-b5331',
    storageBucket: 'echowake-b5331.appspot.com',
    androidClientId:
        '1029106640002-2gt6rc78225t79cq36hemvha2tfsqa2e.apps.googleusercontent.com',
    iosClientId:
        '1029106640002-tnkjrehooiukjvvjpe18f26mr66mdlql.apps.googleusercontent.com',
    iosBundleId: 'com.example.echowake',
  );
}