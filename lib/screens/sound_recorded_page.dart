import 'package:flutter/material.dart';

class SoundRecordedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 흰색 배경 설정
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '본인의 재밌는 소리와 음악을 녹음해보고',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal, // 중간 폰트
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '여러 사람들과 공유해 보세요!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold, // 굵은 폰트
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
