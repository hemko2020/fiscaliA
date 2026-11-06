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
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJMrQcqoe6D-2US4CdaqgKSyRhTFg-KHg',
    appId: '1:699214934639:android:d9ef1651c5368822ca139a',
    messagingSenderId: '699214934639',
    projectId: 'fiscalia-f1eaa',
    storageBucket: 'fiscalia-f1eaa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDDFSebfCo3lQb_XhrfogBGHA5WJtOmh0',
    appId: '1:699214934639:ios:e71a7faa87e94ca2ca139a',
    messagingSenderId: '699214934639',
    projectId: 'fiscalia-f1eaa',
    storageBucket: 'fiscalia-f1eaa.firebasestorage.app',
    iosBundleId: 'com.ianovadev.fiscalia',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBDDFSebfCo3lQb_XhrfogBGHA5WJtOmh0',
    appId: '1:699214934639:ios:e71a7faa87e94ca2ca139a',
    messagingSenderId: '699214934639',
    projectId: 'fiscalia-f1eaa',
    storageBucket: 'fiscalia-f1eaa.firebasestorage.app',
    iosBundleId: 'com.ianovadev.fiscalia',
  );
}
