import 'package:flutter/material.dart';

class SecondProfilePage extends StatefulWidget {
  @override
  _SecondProfilePageState createState() => _SecondProfilePageState();
}

class _SecondProfilePageState extends State<SecondProfilePage> {
  @override
  Widget build(BuildContext context) {
    // 여기에 두 번째 프로필 페이지의 UI 구성 요소를 구현하세요.
    return Scaffold(
      appBar: AppBar(
        title: Text('두 번째 프로필 페이지'),
      ),
      body: Center(
        child: Text('여기는 두 번째 프로필 페이지입니다.'),
      ),
    );
  }
}
