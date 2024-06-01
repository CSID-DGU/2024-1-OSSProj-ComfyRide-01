import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/Login_Screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    //앱 중복 생성 방지
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyBKfAD9spPQ1xAEaEjG3tyu9CmENPskjFw',
      appId: '1:358036639779:android:fe10abe0d875856a346196',
      messagingSenderId: '358036639779',
      projectId: 'ossproj-comfyride',
      storageBucket: 'ossproj-comfyride.appspot.com',
    ));
  } else {
    Firebase.app();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FTTI',
      home: Login_Screen(),
    );
  }
}
