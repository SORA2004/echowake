import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echowake/screens/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'sound_recorded_page.dart';
import 'sound_downloaded_page.dart';
import 'likes_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  // 이전과 동일한 변수 선언 및 initState, getImage 메소드

  File? _image;
  late TabController _tabController;
  String _userName = "사용자 이름"; // 사용자 이름 초기값 설정
  String _userBio = ""; // 사용자 소개 초기값 설정
  String _userEmail = ""; // 사용자 이메일 초기값 설정
  String _selectedGender = ""; // 선택된 성별 초기값 설정
  int _followers = 0; // 팔로워 수 초기값 설정
  int _following = 0; // 팔로잉 수 초기값 설정

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadProfileInfo();
  }

  Future getImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Firebase Storage에 이미지 업로드
  Future<String> uploadImageToStorage(File imageFile) async {
    // 이미지 업로드 로직 구현
    // 예: var uploadTask = FirebaseStorage.instance.ref().child('path').putFile(imageFile);
    // return await uploadTask.then((res) => res.ref.getDownloadURL());
    return '업로드된 이미지 URL'; // 여기에 실제 업로드 로직을 구현해야 합니다.
  }

  Future<void> updateProfileInfo() async {
    String imageUrl = '';
    if (_image != null) {
      imageUrl = await uploadImageToStorage(_image!);
    }

    // Firestore에 사용자 프로필 정보 업데이트
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'userName': _userName,
        'userBio': _userBio,
        'userEmail': _userEmail,
        'selectedGender': _selectedGender,
        'imageUrl': imageUrl, // Firestore에 이미지 URL 저장
      });
    }
  }

  // 프로필 정보를 저장하는 메소드
  Future<void> saveProfileInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', _userName);
    prefs.setString('userBio', _userBio);
    prefs.setString('userEmail', _userEmail);
    prefs.setString('selectedGender', _selectedGender);
    String imageUrl = '';
    // 이미지는 따로 저장해야 합니다.
  }

  Future<void> loadProfileInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          Map<String, dynamic> userData =
          snapshot.data() as Map<String, dynamic>;
          setState(() {
            _userName = userData['userName'] ?? _userName;
            _userBio = userData['userBio'] ?? _userBio;
            _userEmail = userData['userEmail'] ?? _userEmail;
            _selectedGender = userData['selectedGender'] ?? _selectedGender;
            // 여기에서 사진 URL을 처리합니다.
            String imageUrl = userData['imageUrl'] ?? '';
            if (imageUrl.isNotEmpty) {
              // _image 변수에 사진을 할당합니다.
            }
          });
        }
      }
    } catch (e) {
      print("Firestore 로딩 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/AppIcon-1024x+(7).png'),
        ),
        title: Text(
          'Blissom',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('메뉴'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('설정'),
              onTap: () {
                Navigator.pop(context); // 사이드바 닫기
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ));
              },
            ),
            ListTile(
              title: Text('저장된 페이지'),
              onTap: () {
                // 저장된 페이지로 이동하는 로직
                Navigator.pop(context); // 사이드바 닫기
              },
            ),
            // 기타 메뉴 항목들
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 120), // 프로필 사진 위의 여백 추가
            GestureDetector(
              onTap: () {
                if (_image != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        // AlertDialog 대신 Dialog를 사용하면 padding 없이 이미지를 표시할 수 있습니다.
                        content: Image.file(_image!),
                      );
                    },
                  );
                }
              },
              child: Container(
                width: 130.0,
                height: 130.0,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10.0),
                  image: _image != null
                      ? DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_image!),
                  )
                      : DecorationImage(
                    fit: BoxFit.cover,
                    image: Image
                        .asset(
                      'assets/images/default_profile_image.png',
                    )
                        .image,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                // 편집 화면으로 이동하고, 반환된 정보를 받습니다.
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(),
                  ),
                );
                // 반환된 정보가 있을 경우 상태를 업데이트합니다.
                if (result != null) {
                  setState(() {
                    _userName = result['userName'];
                    _userBio = result['userBio'];
                    _userEmail = result['userEmail'];
                    _selectedGender = result['selectedGender'];
                    _image = result['image'];
                  });
                  saveProfileInfo();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.blue, // 하늘색 배경
                  borderRadius: BorderRadius.circular(20), // 모서리를 둥글게 설정
                ),
                child: Text(
                  '편집',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15), // 추가 여백
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '팔로우 $_following명',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 10), // 가로 간격 추가
                Text(
                  '팔로워 $_followers명',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40), // 추가 여백
            // 녹음한 소리, 다운로드한 소리, 좋아요 순서로 탭 바를 표시
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: '녹음한 소리'),
                Tab(text: '다운로드한 소리'),
                Tab(text: '좋아요'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SoundRecordedPage(),
                  SoundDownloadedPage(),
                  LikesPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}