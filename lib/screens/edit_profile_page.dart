import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String _userName = "사용자 이름";
  String _userBio = ""; // 이 줄을 추가합니다.
  File? _image;
  String _userEmail = "";
  List<String> _genderOptions = ["남자", "여자", "알리고 싶지 않음"];
  String _selectedGender = "남자";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> saveProfileInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userName': _userName,
          'userBio': _userBio,
          'userEmail': _userEmail,
          'selectedGender': _selectedGender,
          // 이미지는 Firebase Storage에 따로 업로드하고, URL을 여기에 저장해야 합니다.
        });
      }
    } catch (e) {
      print("Firestore 저장 에러: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = _userName;
    _bioController.text = _userBio;
    _emailController.text = _userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 18, color: Colors.black12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('이름 편집'),
          content: TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userName = _nameController.text;
                });
                Navigator.pop(context);
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = _userName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '프로필 편집',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: getImage,
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(50.0),
                    image: _image == null
                        ? null
                        : DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: _showEditDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.black, size: 20),
                      onPressed: _showEditDialog,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildSectionTitle('자기소개'),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _bioController,
                style: TextStyle(color: Colors.black),
                decoration: _inputDecoration('본인을 간단히 소개해주세요!'),
                minLines: 1,
                maxLines: 5,
              ),
            ),
            SizedBox(height: 20),
            _buildSectionTitle('이메일'),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.black),
                decoration: _inputDecoration('이메일을 입력해주세요!'),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: _buildSectionTitle('성별'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DropdownButton<String>(
                dropdownColor: Colors.white, // 드롭다운 메뉴의 배경색을 흰색으로 설정
                value: _selectedGender,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
                underline: Container(
                  height: 2,
                  color: Colors.black,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
                items: _genderOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Container(
                  width: 350,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _userName = _nameController.text;
                        _userBio = _bioController.text;
                        _userEmail = _emailController.text;
                        _selectedGender = _selectedGender;
                      });
                      saveProfileInfo();
                      Navigator.pop(context, {
                        'userName': _userName,
                        'userBio': _userBio,
                        'userEmail': _userEmail,
                        'selectedGender': _selectedGender,
                        'image': _image,
                      });
                    },
                    child: Text(
                      '저장하기',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}