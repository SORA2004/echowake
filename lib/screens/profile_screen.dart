import 'package:echowake/screens/second_profile_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileCreationPage(),
    );
  }
}

class ProfileCreationPage extends StatefulWidget {
  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  File? _selectedImage;

  bool get isFormFilled =>
      nameController.text.isNotEmpty &&
          birthDateController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          emailController.text.contains('@');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // 오늘 날짜로 설정
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        birthDateController.text = "${picked.year}.${picked.month.toString().padLeft(2, '0')}.${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // 선택한 이미지로 상태 업데이트
      });
    }
  }

  Future<void> saveProfile() async {
    // FirebaseAuth 인스턴스를 사용하여 현재 로그인된 사용자의 UID를 가져옵니다.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && _selectedImage != null) {
      // 이미지를 Firebase Storage에 업로드하고, 다운로드 URL을 가져옵니다.
      final ref = FirebaseStorage.instance.ref().child('userImages').child(uid + '.jpg');
      await ref.putFile(_selectedImage!);
      final imageUrl = await ref.getDownloadURL();

      // Firestore에 사용자 정보를 저장합니다.
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text,
        'birthDate': birthDateController.text,
        'email': emailController.text,
        'imageUrl': imageUrl, // 저장된 이미지의 URL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),
              Text('프로필 만들기', style: TextStyle(fontSize: 24.0, color: Colors.black)), // 제목 텍스트 색상 설정
              SizedBox(height: 70),
              Container(
                padding: EdgeInsets.all(4), // 테두리 크기를 조절하려면 이 값을 조정하세요.
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey, // 테두리 색상 설정
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null ? Icon(Icons.add_photo_alternate, size: 50, color: Colors.black) : null, // 아이콘 색상 설정
                  backgroundColor: Colors.transparent,
                ),
              ),
              Text('프로필 사진 바꾸기', style: TextStyle(fontSize: 13.0, color: Colors.black)), // 설명 텍스트 색상 설정
              SizedBox(height: 50),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('이름', style: TextStyle(color: Colors.black)), // 이름 필드 제목 텍스트 색상 설정
              ),
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.black), // 입력 텍스트 색상 설정
                decoration: InputDecoration(
                  hintText: '프로필에 사용할 이름을 입력해주세요.',
                  hintStyle: TextStyle(color: Colors.black54), // 힌트 텍스트 색상 설정
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0), // 여기서 모서리 둥글기를 설정하세요
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // 비활성 테두리 색상 설정
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // 활성 테두리 색상 설정
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('생일', style: TextStyle(color: Colors.black)), // 태어난 날 제목
              ),
              GestureDetector(
                onTap: () => _selectDate(context), // 여기서 날짜 선택기를 호출합니다.
                child: AbsorbPointer(
                  child: TextField(
                    controller: birthDateController,
                    decoration: InputDecoration(
                      hintText: 'xxxx.xx.xx',
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0), // 여기서 모서리 둥글기를 설정하세요
                        borderSide: BorderSide(color: Colors.grey), // 테두리를 회색으로 설정합니다.
                      ),
                    ),
                    style: TextStyle(color: Colors.black), // 입력 텍스트 색상을 검정색으로 설정합니다.
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isFormFilled
                    ? () {
                  // 프로필 정보를 저장하고, 두 번째 페이지로 넘어갑니다.
                  saveProfile();
                }
                    : null, // 버튼 비활성화
                child: Text('프로필 저장'),
                style: ElevatedButton.styleFrom(
                  primary: isFormFilled ? Colors.purple : Colors.grey, // 조건부 색상 설정
                  onSurface: Colors.grey, // 버튼 비활성화 시 색상
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void saveProfile() {
  // TODO: 프로필 정보를 저장하는 로직을 구현하세요.
}

void navigateToSecondPage(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => SecondProfilePage(), // 변경된 부분: SecondPage 대신 SecondProfilePage를 사용합니다.
    ),
  );
}





