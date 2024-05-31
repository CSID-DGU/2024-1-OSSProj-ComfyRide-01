import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

class StyleRecommendation extends StatefulWidget {
  final String uid;
  final String FTTI_eng;
  final String FTTI_kor;
  final double bestF;
  final double bestO;
  final double bestC;

  StyleRecommendation({
    required this.uid,
    required this.FTTI_eng,
    required this.FTTI_kor,
    required this.bestF,
    required this.bestO,
    required this.bestC,
    super.key,
  });

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

    // 전달받은 bestF, bestO, bestC 값을 사용
    double f = widget.bestF;
    double o = widget.bestO;
    double c = widget.bestC;

    List<Map<String, dynamic>> newList = [];

    // 각 비율에 맞게 데이터를 가져옴
    newList.addAll(await _getDataByRatio('f', f));
    newList.addAll(await _getDataByRatio('o', o));
    newList.addAll(await _getDataByRatio('c', c));

    print('총 이미지 개수: ${newList.length}');
    print('f: $f');
    print('o: $o');
    print('c: $c');

    setState(() {
      list_ = newList;
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _getDataByRatio(
      String code, double ratio) async {
    var querySnapshot = await db.collection("data_real").get();

    // code에 따라 데이터를 필터링
    List<Map<String, dynamic>> filteredDataList = querySnapshot.docs
        .where((doc) => doc['code'] == code)
        .map((doc) => {
              'img': doc['img'],
              'link': doc['link'],
              'code': doc['code'],
            })
        .toList();

    int totalFilteredDocs = filteredDataList.length;
    int count = (totalFilteredDocs * ratio).round();

    List<Map<String, dynamic>> selectedData = [];

    // 비율에 맞게 데이터를 선택
    for (int i = 0; i < count; i++) {
      selectedData.add(filteredDataList[i % totalFilteredDocs]);
    }

    // code 필드를 콘솔에 출력
    for (var data in selectedData) {
      print('Code: ${data['code']}');
    }

    return selectedData;
  }

  @override
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
                  "'${widget.FTTI_kor}(${widget.FTTI_eng})' 맞춤 패션 추천", // 임시 텍스트
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
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
