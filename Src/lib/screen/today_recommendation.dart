import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/screen/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TodayRecommedation extends StatefulWidget {
  const TodayRecommedation({super.key});

  @override
  State<TodayRecommedation> createState() => _TodayRecommedation();
}

class _TodayRecommedation extends State<TodayRecommedation> {
  bool _isLoading = true;
  String randomImageUrl = '';
  String shoppingMallUrl = '';

  @override
  void initState() {
    super.initState();
    _getRandomStyle();
  }

  Future<void> _getRandomStyle() async {
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection('data_real');
    // 컬렉션에서 랜덤 문서 가져오기
    final querySnapshot = await collectionRef.get();
    final documentSnapshot =
        querySnapshot.docs[Random().nextInt(querySnapshot.size)];
    randomImageUrl = documentSnapshot['img'];
    shoppingMallUrl = documentSnapshot['link'];
    setState(() {
      _isLoading = false;
    });
    print(randomImageUrl);
    print('쇼핑몰 $shoppingMallUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: Center(
          child: Text(
            'FTTI',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("로그아웃"),
                    content: Text("로그아웃 됐습니다."),
                    actions: <Widget>[
                      TextButton(
                        child: Text("확인"),
                        onPressed: () async {
                          Navigator.of(context).pop(); // 안내창 닫기
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove('isLoggedIn');
                          await prefs.remove('uid');
                          print('로그아웃 완료');
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => Login_Screen(),
                          )); // 로그인 페이지로 이동
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.blue,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          SizedBox(height: 5),
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 10)),
                Text(
                  '오늘의 추천 스타일! ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  '어떤 스타일을 매치할지 고민된다면! \n오늘의 스타일을 이용해보세요! ',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Container(
                  height: 400,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : CachedNetworkImage(
                            imageUrl: randomImageUrl,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Column(
                              children: [
                                Icon(Icons.error),
                                Text('Error: $error'), // 에러 내용 출력
                              ],
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () async {
                      await launchUrl(Uri.parse(shoppingMallUrl));
                    },
                    child: Text(
                      '스타일 보러 가기 ',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    )),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Column(
                        children: [Container()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
