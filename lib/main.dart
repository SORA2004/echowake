import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:echowake/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // 스플래시 화면을 앱의 첫 화면으로 지정
    );
  }
}