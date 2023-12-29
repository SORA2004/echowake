import 'package:echowake/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // kDebugMode를 위해 추가
import 'package:echowake/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 디버그 모드가 아닐 경우에만 Firebase App Check 활성화
  if (!kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: '6LeCSj8pAAAAADUSQuPX_KJKFTj2oHrGtUG1R-fZ',
    );
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}