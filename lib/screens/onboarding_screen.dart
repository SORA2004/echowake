import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final List<String> onboardingTexts = [
    "EchoWake로 새로운 경험을 시작하세요!",
    "자신만의 알람 소리를 공유하고 다른 사람의 소리도 경험해보세요!",
    "지금 바로 시작해보세요!"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: 3,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(child:
                Text(
                  onboardingTexts[index],
                  style: TextStyle(
                    color: Colors.white, // 글씨 색상을 검정색으로 설정
                    // 기타 스타일 설정...
                  ),
                )
                );
              },
            ),
          ),
          if (currentPage == 2)
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => InstagramLogin()));
              },
              child: Text("시작하기"),
            ),
        ],
      ),
    );
  }
}