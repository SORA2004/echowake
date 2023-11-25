import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'signup_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class InstagramLogin extends StatefulWidget {
  @override
  _InstagramLoginState createState() => _InstagramLoginState();
}

class _InstagramLoginState extends State<InstagramLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MainScreen()));
    } catch (e) {
      print('로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: 이메일과 비밀번호를 확인해주세요.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // 사용자가 로그인을 취소한 경우

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      return userCredential.user;
    } catch (error) {
      print('Google 로그인 실패: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/AppIcon-1024x+(7).png',
                  height: 100,
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: '이메일',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: _resetPassword,
                      child: Text('비밀번호를 잊으셨습니까?'),
                      style: TextButton.styleFrom(
                        primary: Colors.black, // 텍스트 버튼의 색상을 검정색으로 설정
                      ),
                    ),
                  ],
                ),
                if (_isLoading) CircularProgressIndicator(),
                if (!_isLoading)
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('로그인'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlueAccent,
                      onPrimary: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("or"),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    User? user = await _signInWithGoogle();
                    if (user != null) {
                      // 로그인 성공
                      print('Google 로그인 성공: ${user.displayName}');
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => MainScreen()));
                    } else {
                      // 로그인 실패
                      print('Google 로그인 실패');
                    }
                  },
                  child: Text('Google로 로그인'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('계정이 없으신가요?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) =>
                              SignUpScreen()),
                        );
                      },
                      child: Text('가입하기'),
                      style: TextButton.styleFrom(
                        primary: Colors.black, // 텍스트 버튼의 색상을 검정색으로 설정
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 재설정 링크가 이메일로 전송되었습니다.')),
      );
    } catch (e) {
      print('비밀번호 재설정 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 재설정 실패: 이메일을 확인해주세요.')),
      );
    }
  }
}

