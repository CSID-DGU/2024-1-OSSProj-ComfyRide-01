import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/screen/Login_Screen.dart';
import 'package:ossproj_comfyride/screen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

//ui 없이 앱 로딩시 로그인 여부 검사하는 class임
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
    if (isLoggedIn) {
      String uid = prefs.getString('uid') ?? '';
      // 로그인 상태라면 설명 페이지로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => MainScreen(uid: uid, initialIndex: 1)),
      );
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
