import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echowake/screens/login_screen.dart';
import 'package:echowake/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/audio_files_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';
import 'dart:io';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  await initializeAppCheck();
  runApp(EchoWakeApp());
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  HttpOverrides.global = MyHttpOverrides();
  FlutterNativeSplash.remove();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? token = await messaging.getToken();
  print("FCM Token: $token");

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> initializeAppCheck() async {
  await FirebaseAppCheck.instance.activate();
}

class EchoWakeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioFilesProvider(),
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: FutureBuilder(
          // FirebaseAuth 인스턴스를 사용하여 사용자 로그인 상태 확인
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            // 연결 상태 확인
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen(); // 로딩 중 SplashScreen 표시
            } else if (snapshot.hasData) {
              // 로그인된 사용자가 있을 경우
              User user = snapshot.data as User;
              // 사용자의 프로필 정보를 Firestore에서 가져오기
              return FutureBuilder(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return SplashScreen(); // 로딩 중 SplashScreen 표시
                  }
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    // 프로필 정보가 있으면 MainScreen으로 이동
                    return MainScreen();
                  } else {
                    // 프로필 정보가 없으면 ProfileCreationPage로 이동
                    return ProfileCreationPage();
                  }
                },
              );
            } else {
              // 로그인되지 않은 경우 로그인 페이지로 이동
              return InstagramLogin();
            }
          },
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void _saveTokenToDatabase(String? token) {
    // 사용자 ID를 가져옵니다.
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Firestore 사용자 문서에 토큰을 저장합니다.
    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'token': token,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
  }

  _initFirebaseMessaging() async {
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      print("FCM Token: $token");
    });
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _saveTokenToDatabase(token);
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      // 여기에서 알림이 도착했을 때의 로직을 추가하세요.
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      // 여기에서 사용자가 알림을 클릭했을 때의 로직을 추가하세요.
    });
  }

  Duration _audioDuration = Duration();
  Duration _currentPosition = Duration();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱의 나머지 부분을 여기에 구현하세요.
    );
  }
}






