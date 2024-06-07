import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/provider/ImageProviderNotifier.dart';
import 'package:ossproj_comfyride/screen/Cart_Screen.dart';
import 'package:ossproj_comfyride/screen/Login_Screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class StyleRecommendation extends StatefulWidget {
  final String uid;
  final String FTTI_eng;
  final String FTTI_full_eng;
  final double bestF;
  final double bestO;
  final double bestC;

  StyleRecommendation({
    required this.uid,
    required this.FTTI_eng,
    required this.FTTI_full_eng,
    required this.bestF,
    required this.bestO,
    required this.bestC,
    super.key,
  });

  @override
  State<StyleRecommendation> createState() => _StyleRecommendationState();
}

class _StyleRecommendationState extends State<StyleRecommendation> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> list_ = [];
  List<Map<String, dynamic>> recommendationList = [];
  var list_cart = [];
  bool isLoading = false; // 로딩 상태 추적
  bool initialLoading = true; // 첫 로딩 상태 추적
  bool _isLoadingMore = false; // 추가 데이터 로딩 상태 추적
  DocumentSnapshot? _lastDocument; // 마지막으로 로드된 문서
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
  List<bool> likedList = [];

  @override
  void initState() {
    super.initState();
    _loadData(initial: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        _loadData();
      }
    });
  }

  Future<void> _loadData({bool initial = false}) async {
    if (isLoading || _isLoadingMore) return; // 이미 로딩 중이면 중복 실행 방지

    if (initial) {
      setState(() => isLoading = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    QuerySnapshot querySnapshot;
    if (_lastDocument == null) {
      querySnapshot = await db.collection('data_real').limit(30).get();
    } else {
      querySnapshot = await db
          .collection('data_real')
          .startAfterDocument(_lastDocument!)
          .limit(20)
          .get();
    }

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (!list_.any((item) => item['img'] == data['img'])) {
        list_.add({
          'img': data['img'],
          'link': data['link'],
          'code': data['code'],
        });
      }
    }

    // 현재 리스트에 없는 데이터로만 비율에 맞게 추가
    double f = widget.bestF;
    double o = widget.bestO;
    double c = widget.bestC;

    var fList = await _getDataByRatio('f', f, list_);
    var oList = await _getDataByRatio('o', o, list_);
    var cList = await _getDataByRatio('c', c, [...list_, ...fList, ...oList]);

    print('Best f: $f, Best o: $o, Best c: $c');
    print('f 추가된 개수: ${fList.length}');
    print('o 추가된 개수: ${oList.length}');
    print('c 추가된 개수: ${cList.length}');

    recommendationList.addAll(fList);
    recommendationList.addAll(oList);
    recommendationList.addAll(cList);

    // 리스트를 섞음
    recommendationList.shuffle(_random);

    likedList =
        List<bool>.filled(recommendationList.length, false); // 좋아요 상태 초기화

    for (int i = 0; i < recommendationList.length; i++) {
      print(recommendationList[i]['code']);
    }

    if (mounted) {
      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        isLoading = false;
        initialLoading = false;
        _isLoadingMore = false;
        print('현재 list_ 총 개수 : ${list_.length}');

        for (var i = 0; i < list_.length; i++) {
          list_cart.add(false);
        }
        likedList =
            List<bool>.filled(recommendationList.length, false); // 좋아요 상태 초기화
      });

      // 이미지 URL들을 provider에 추가
      List<String> urls = list_.map((item) => item['img'] as String).toList();
      Provider.of<ImageProviderNotifier>(context, listen: false)
          .addUrls(urls, context); // context 전달
    }
  }

  Future<List<Map<String, dynamic>>> _getDataByRatio(
      String code, double ratio, List<Map<String, dynamic>> currentList) async {
    var querySnapshot =
        await db.collection("data_real").where('code', isEqualTo: code).get();

    List<Map<String, dynamic>> filteredDataList = querySnapshot.docs
        .map((doc) => {
              'img': doc['img'],
              'link': doc['link'],
              'code': doc['code'],
            })
        .where((doc) => !currentList.any((item) => item['img'] == doc['img']))
        .toList();

    int totalFilteredDocs = filteredDataList.length;
    int count = (totalFilteredDocs * ratio).round();

    var selectedData = filteredDataList.take(count).toList();

    return selectedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // 우측의 액션 버튼들
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Cart(
                            uid: widget.uid,
                            FTTI_eng: widget.FTTI_eng,
                            FTTI_full_eng: widget.FTTI_full_eng,
                            bestF: widget.bestF,
                            bestO: widget.bestO,
                            bestC: widget.bestC)));
              },
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              )),
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
        title: Center(
            child: Padding(
          padding: EdgeInsets.only(left: 90),
          child: Text(
            'FTTI',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
        )),
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
                "'${widget.FTTI_full_eng}(${widget.FTTI_eng})' 맞춤 패션 추천",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Expanded(
                child: initialLoading
                    ? Center(child: CircularProgressIndicator())
                    : gridGenerator(context),
              ),
              if (_isLoadingMore)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Widget gridGenerator(BuildContext context) {
    return MasonryGridView.builder(
      controller: _scrollController,
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: recommendationList.length,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () async {
                String shoppingMallUrl = recommendationList[index]['link'];
                await launchUrl(Uri.parse(shoppingMallUrl));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: recommendationList[index]['img'],
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 5,
              child: IconButton(
                icon: Icon(
                  likedList[index] ? Icons.favorite : Icons.favorite_border,
                  color: likedList[index] ? Colors.red : Colors.white,
                ),
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    likedList[index] = !likedList[index];
                  });
                  if (likedList[index]) {
                    db.collection('cart_data').doc().set({
                      'uid': widget.uid,
                      'img': recommendationList[index]['img'],
                      'link': recommendationList[index]['link']
                    });
                  } else {
                    // 좋아요 취소 시 해당 데이터 삭제
                    db
                        .collection('cart_data')
                        .where('uid', isEqualTo: widget.uid)
                        .where('img',
                            isEqualTo: recommendationList[index]['img'])
                        .get()
                        .then((querySnapshot) {
                      for (var doc in querySnapshot.docs) {
                        db.collection('cart_data').doc(doc.id).delete();
                      }
                    });
                  }
                  print('좋아요 버튼 클릭됨');
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
