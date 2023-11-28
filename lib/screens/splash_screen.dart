import 'package:echowake/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      if (mounted) { // 현재 위젯이 여전히 활성화되어 있는지 확인
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen())); // NextScreen으로 이동
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 색상을 흰색으로 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/AppIcon-1024x+(7).png',
              width: 120.0, // 이미지 너비를 120픽셀로 설정
              height: 120.0, // 이미지 높이를 120픽셀로 설정
            ),
            SizedBox(height: 20),
            Text(
              'Blissom',
              style: TextStyle(
                color: Colors.lightBlue, // 텍스트 색상을 lightBlue로 설정
                fontSize: 24.0, // 텍스트 크기를 24픽셀로 설정
                fontWeight: FontWeight.bold, // 굵은 글씨체
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // 로딩 인디케이터
          ],
        ),
      ),
    );
  }
}