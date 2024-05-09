import 'package:image_network/image_network.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math' as math;

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
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<String> list_ = <String>[];
  bool isLoading = false; // 로딩 상태 추적

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (isLoading) return; // 이미 로딩 중이면 중복 실행 방지
    setState(() => isLoading = true);
    var querySnapshot = await db.collection("data_").get();
    List<String> newList = [];
    for (var doc in querySnapshot.docs) {
      newList.add(doc['img']);
    }
    setState(() {
      list_ = newList;
      isLoading = false;
    });
  }


  // @override
   Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FTTI'),
        ),
        body:
        Container(child: grid_generator(context)),
      ),
    );
  }
  // todo-해야될것 : streaming 해온 데이터를 아래 generator에 리스트로 맞추기ㄴㄴ


  
  Widget grid_generator(BuildContext context) {
    if (list_.isEmpty) { // list_가 비어 있는지 확인
      return Center(child: CircularProgressIndicator()); // 로딩 인디케이터 표시
    }
    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: list_.length, // itemCount를 list_의 길이로 설정
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(list_[index]),
        );
      },
    );
  }
}

//   Stream<QuerySnapshot> _commentStream() {
//     stopTrigger +=1;
//     if(stopTrigger == 2 ){
//       return unchanging;
//
//   }
// }