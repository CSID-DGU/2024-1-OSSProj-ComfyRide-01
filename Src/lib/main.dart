import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/provider/ImageProviderNotifier.dart';
import 'package:ossproj_comfyride/screen/splash_screen.dart';
import 'package:provider/provider.dart';

/*
 File Name: main.dart
 Description: FTTI의 main 코드입니다.
 Author: 이보성
 Date Created: 2024-04-01
 Last Modified by: 장주리
 Last Modified on: 2024-06-09
 Copyright (c) 2024, ComfyRide. All rights reserved.
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageProviderNotifier()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FTTI',
        home: SplashScreen(),
      ),
    );
  }
}
