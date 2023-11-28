import 'package:flutter/material.dart';

class SoundDownloadedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '본인이 좋아하는 작품을 다운로드해보고,',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Text(
                '그 작품들을 오프라인에서도 들어보세요!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}