import 'package:flutter/material.dart';

class OtherProfilePage extends StatelessWidget {
  // 예시를 위해 사용자 ID를 매개변수로 받을 수 있습니다.
  // 실제로는 사용자 데이터를 불러오는 로직이 추가됩니다.
  final String userId;

  OtherProfilePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다른 사용자의 프로필'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('사용자 ID: $userId'),
            // 사용자의 프로필 사진, 이름, 팔로워/팔로잉 수 등을 표시합니다.
            // 사용자의 업로드한 소리 목록을 표시할 수 있습니다.
            // 팔로우/언팔로우 버튼을 포함할 수 있습니다.
          ],
        ),
      ),
    );
  }
}
