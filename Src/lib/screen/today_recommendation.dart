import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TodayRecommendation extends StatefulWidget {
  const TodayRecommendation({super.key});

  @override
  State<TodayRecommendation> createState() => _TodayRecommendation();
}

class _TodayRecommendation extends State<TodayRecommendation> {
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
          SizedBox(height: screenHeight * 0.01),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                Padding(padding: EdgeInsets.only(top: screenHeight * 0.01)),
                Text(
                  '오늘의 추천 스타일! ',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '어떤 스타일을 매치할지 고민된다면! \n오늘의 스타일을 이용해보세요! ',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.03),
                Container(
                  height: screenHeight * 0.4,
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
                SizedBox(height: screenHeight * 0.05),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.01,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.01),
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
