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
  File? _image;
  late TabController _tabController;
  String _userName = "사용자 이름";
  String _userBio = "";
  String _userEmail = "";
  String _selectedGender = "";
  int _followers = 0;
  int _following = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadProfileInfo();
  }

  Future getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    // 이미지 업로드 로직 구현 필요
    return '업로드된 이미지 URL';
  }

  Future<void> updateProfileInfo() async {
    String imageUrl = '';
    if (_image != null) {
      imageUrl = await uploadImageToStorage(_image!);
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'userName': _userName,
        'userBio': _userBio,
        'userEmail': _userEmail,
        'selectedGender': _selectedGender,
        'imageUrl': imageUrl,
      });
    }
  }

  Future<void> saveProfileInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', _userName);
    prefs.setString('userBio', _userBio);
    prefs.setString('userEmail', _userEmail);
    prefs.setString('selectedGender', _selectedGender);
  }

  Future<void> loadProfileInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _userName = userData['userName'] ?? _userName;
          _userBio = userData['userBio'] ?? _userBio;
          _userEmail = userData['userEmail'] ?? _userEmail;
          _selectedGender = userData['selectedGender'] ?? _selectedGender;
          if (userData['imageUrl'] != null && userData['imageUrl'].isNotEmpty) {
            // 이미지 URL을 사용하여 _image 처리
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: Image.asset('assets/images/AppIcon-1024x+(7).png'),
        ),
        title: Text('Blissom', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        // Drawer 위젯 구현
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 120),
          Center(
            child: GestureDetector(
              onTap: () {
                if (_image != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
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
                  borderRadius: BorderRadius.circular(25.0),
                  image: _image != null
                      ? DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_image!),
                  )
                      : DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/default_profile_image.png'),
                  ),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '편집',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '팔로우 $_following명',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 16),
              ),
              SizedBox(width: 10),
              Text(
                '팔로워 $_followers명',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 40),
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
          Container(
            height: MediaQuery.of(context).size.height,
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
    );
  }
}
