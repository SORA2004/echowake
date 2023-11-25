import 'package:flutter/material.dart';

class LikesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '내가 좋아하는 작품들을 모아서 들어보세요!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}