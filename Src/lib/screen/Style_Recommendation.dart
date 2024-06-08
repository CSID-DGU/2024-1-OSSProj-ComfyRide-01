import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/provider/ImageProviderNotifier.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
      });

      // 이미지 URL들을 provider에 추가
      List<String> urls = list_.map((item) => item['img'] as String).toList();
      Provider.of<ImageProviderNotifier>(context, listen: false)
          .addUrls(urls, context);
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
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
            SizedBox(height: screenHeight * 0.02),
            Text(
              "'${widget.FTTI_full_eng}(${widget.FTTI_eng})' 맞춤 패션 추천",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.03),
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
    double screenWidth = MediaQuery.of(context).size.width;
    var likedUrls = Provider.of<ImageProviderNotifier>(context).likedUrls;
    return MasonryGridView.builder(
      controller: _scrollController,
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: recommendationList.length,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemBuilder: (context, index) {
        bool isLiked = likedUrls.contains(recommendationList[index]['img']);
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
              bottom: screenWidth * 0.025,
              right: screenWidth * 0.012,
              child: IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (isLiked) {
                      likedUrls.remove(recommendationList[index]['img']);
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
                    } else {
                      likedUrls.add(recommendationList[index]['img']);
                      db.collection('cart_data').doc().set({
                        'uid': widget.uid,
                        'img': recommendationList[index]['img'],
                        'link': recommendationList[index]['link']
                      });
                    }
                  });
                  Provider.of<ImageProviderNotifier>(context, listen: false)
                      .notifyListeners();
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
