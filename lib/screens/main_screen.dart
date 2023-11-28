import 'package:echowake/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'upload_page.dart';

class MainScreen extends StatefulWidget {
  final String? videoTitle;
  final String? thumbnailPath;
  final int initialIndex;

  MainScreen({
    Key? key,
    this.videoTitle,
    this.thumbnailPath,
    this.initialIndex = 0, // 기본값 0으로 설정
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex; // 초기 인덱스 설정
  }

  void updateHome() {
    setState(() {
      currentIndex = 0; // 홈 탭으로 업데이트
    });
  }

  List<Widget> get pages => [
    HomePage(videoTitle: widget.videoTitle ?? '', thumbnailPath: widget.thumbnailPath ?? ''), // HomePage에 데이터 전달
    UploadPage(updateHome: updateHome),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index; // 선택된 인덱스로 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_outlined),
            activeIcon: Icon(Icons.upload),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
