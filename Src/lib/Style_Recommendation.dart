import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

class StyleRecommendation extends StatefulWidget {
  const StyleRecommendation({super.key});
  @override
  State<StyleRecommendation> createState() => _StyleRecommendation();
}

class _StyleRecommendation extends State<StyleRecommendation> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> list_ = [];
  bool isLoading = false; // 로딩 상태 추적
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (isLoading) return; // 이미 로딩 중이면 중복 실행 방지
    setState(() => isLoading = true);
    var querySnapshot = await db.collection("data_real").get();
    List<Map<String, dynamic>> newList = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> newItem = {
        'img': doc['img'],
        'link': doc['link'],
      };
      newList.add(newItem);
    }
    setState(() {
      list_ = newList;
      isLoading = false;
    });
  }

  // @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로 돌아감
            },
          ),
          title: Text(
            'FTTI',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
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
            Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "편한게 좋은 프로페셔널 직장인(O5C4F1)' 유형의\n길동님 맞춤 패션 추천", //임시 텍스트
                  style: TextStyle(fontSize: 15), textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: grid_generator(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget grid_generator(BuildContext context) {
    if (list_.isEmpty) {
      // list_가 비어 있는지 확인
      return Center(child: CircularProgressIndicator()); // 로딩 인디케이터 표시
    }
    return MasonryGridView.builder(
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: list_.length, // itemCount를 list_의 길이로 설정
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            String ShoppingmallUrl = list_[index]['link'];
            await launchUrl(Uri.parse(ShoppingmallUrl));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(list_[index]['img']),
          ),
        );
      },
    );
  }
}
