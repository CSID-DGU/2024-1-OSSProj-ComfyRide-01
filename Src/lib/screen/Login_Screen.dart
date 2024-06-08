import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ossproj_comfyride/screen/choice_style.dart';
import 'package:ossproj_comfyride/screen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  String _uid = "";
  bool newUser = true;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Text(
                    'FTTI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Fashion Tendency Types Indicator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * (isLandscape ? 0.1 : 0.25)),
              Center(
                child: Text(
                  '알려줘, 나의 패션 코드!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.065,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * (isLandscape ? 0.1 : 0.16)),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // 구글 로그인 수행
                    final UserCredential? userCredential =
                        await signInWithGoogle();
                    if (userCredential != null) {
                      // 로그인 상태를 SharedPreferences에 저장
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);
                      await prefs.setString('uid', _uid);

                      // Firestore에 사용자 추가
                      await addUser(userCredential);

                      // 신규 유저이면 스타일 선택 페이지로 이동
                      if (newUser) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              Choice_Style(uid: _uid, isFirstLogin: true),
                        ));
                      } else {
                        // 기존 유저이면 MainScreen의 설명 페이지로 이동
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MainScreen(
                              uid: _uid,
                              initialIndex: 1), // 초기 index를 1로 설정해 설명 페이지로 이동
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: screenWidth * 0.1),
                      SizedBox(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        child: Image.asset(
                          'assets/google.png',
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Text(
                        'Google로 시작하기',
                        style: TextStyle(
                            color: Colors.black, fontSize: screenWidth * 0.05),
                      ),
                      SizedBox(width: screenWidth * 0.1),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 구글 로그인 함수
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('Google 로그인이 취소되었습니다.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      _uid = userCredential.user?.uid ?? "UID not available";

      print('Firebase UID: $_uid');

      return userCredential;
    } catch (e) {
      print('error: $e');
      return null;
    }
  }

  // Firestore에 사용자 추가 함수
  Future<void> addUser(UserCredential userCredential) async {
    try {
      _uid = userCredential.user?.uid ?? "UID not available";

      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(_uid);

      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null &&
            data.containsKey('selected_codes') &&
            data.containsKey('FTTI') &&
            data['selected_codes'] != '' &&
            data['FTTI'] != '') {
          newUser = false;
          print('User data already exists and is set properly.');
          return;
        }
      }

      final userData = {
        'uid': _uid,
        'selected_codes': '',
        'FTTI': '',
      };

      await userDocRef.set(userData);

      print('Success add user id!');
    } catch (e) {
      print('Error: $e');
    }
  }
}
