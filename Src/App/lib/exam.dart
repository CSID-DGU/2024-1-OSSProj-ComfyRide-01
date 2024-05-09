import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBKfAD9spPQ1xAEaEjG3tyu9CmENPskjFw',
        appId: '1:358036639779:android:fe10abe0d875856a346196',
        messagingSenderId: '358036639779',
        projectId: 'ossproj-comfyride',
        storageBucket: 'ossproj-comfyride.appspot.com',
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Future<void> _incrementCounter() async {
      await db.collection("style_data").get().then((event) {
        for (var doc in event.docs) {
          print("${doc.id} => ${doc.data()}");
        }
      });
    }
    _incrementCounter();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('파이어2베이스11테스트'),
        ),
        body: const Center(
          child: Text(
            '여기 @@@받아올11거에요.',
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}