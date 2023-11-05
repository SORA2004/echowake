import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) { // 위젯이 현재 마운트된 상태인지 확인합니다.
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OnboardingScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B2B2B),
      body: Container(
          alignment: Alignment.center,// 내용을 화면 중앙에 위치시킴
        child: RichText(
          textDirection: TextDirection.ltr, // or TextDirection.rtl, depending on your text direction
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Echo',
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFAB57FF), // 보라색
                ),
              ),
              WidgetSpan(
                child: SizedBox(height: 20), // 여기서 높이를 조절하여 'Wake'의 위치를 조정할 수 있습니다.
              ),
              WidgetSpan(
                child: SizedBox(width: 20), // 'Wake'를 오른쪽으로 움직이기 위해 추가
              ),
              TextSpan(
                text: '\nWake',
                style: TextStyle(
                  fontSize: 65,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300], // 밝은 회색
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




