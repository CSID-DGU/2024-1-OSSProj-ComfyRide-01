import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/screen/Login_Screen.dart';
import 'package:ossproj_comfyride/screen/explain_FTTI.dart';
import 'package:ossproj_comfyride/screen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// UI 없이 앱 로딩 시 로그인 여부 검사하는 클래스임
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // SharedPreferences를 사용하여 로그인 상태 확인
  _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    FirebaseFirestore db = FirebaseFirestore.instance;

    if (isLoggedIn) {
      String uid = prefs.getString('uid') ?? 'no id';
      DocumentSnapshot userDoc = await db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String ftti = userDoc.get('FTTI') ?? "";
        if (ftti.isEmpty) {
          // FTTI가 빈 문자열이면 로그인 페이지로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Login_Screen()),
          );
        } else {
          // FTTI가 저장되어 있으면 설명 페이지로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => MainScreen(uid: uid, initialIndex: 1)),
          );
        }
      } else {
        // 사용자 문서가 존재하지 않으면 로그인 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Login_Screen()),
        );
      }
    } else {
      // 로그인 상태가 아니라면 Login_Screen으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Login_Screen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 로딩 화면
      ),
    );
  }
}
