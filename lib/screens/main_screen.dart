import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echowake/screens/second_profile_page.dart';
import 'package:echowake/screens/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'alarm_page.dart';
import 'sound_share_page.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final List<Widget> pages = [
    AlarmPage(),
    SoundSharePage(),
    ProfileCreationPage(), // 변경된 부분
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "알람"),
          BottomNavigationBarItem(icon: Icon(Icons.share), label: "소리공유"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "프로필"),
        ],
        onTap: (index) async {
          print('BottomNavigationBar onTap called with index: $index');
          try {
            if (index == 2) { // 프로필 아이콘을 선택했을 때
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                print('Fetching user profile for uid: ${user.uid}');
                DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                if (userProfile.exists) {
                  print('User profile exists, navigating to SecondProfilePage');
                  // 프로필이 이미 생성되었다면, 두 번째 프로필 페이지로 이동
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SecondProfilePage()));
                } else {
                  print('User profile does not exist, setting currentIndex to $index');
                  // 프로필이 생성되지 않았다면, ProfileCreationPage로 이동
                  setState(() => currentIndex = index);
                }
              }
            } else {
              print('Setting currentIndex to $index');
              setState(() => currentIndex = index);
            }
          } catch (e) {
            print('Error in onTap: $e');
          }
        },

      ),
    );
  }
}