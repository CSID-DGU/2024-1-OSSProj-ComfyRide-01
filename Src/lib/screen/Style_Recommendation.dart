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

    print('UID: ${widget.uid}');
    print('FTTI_eng: ${widget.FTTI_eng}');
    print('FTTI_full_eng: ${widget.FTTI_full_eng}');
    print('bestF: ${widget.bestF}');
    print('bestO: ${widget.bestO}');
    print('bestC: ${widget.bestC}');
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

    List<Map<String, dynamic>> newList = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (!list_.any((item) => item['img'] == data['img'])) {
        newList.add({
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

    var currentList = [...list_, ...newList];
    var fList = await _getDataByRatio('f', f, currentList);
    currentList.addAll(fList);
    var oList = await _getDataByRatio('o', o, currentList);
    currentList.addAll(oList);
    var cList = await _getDataByRatio('c', c, currentList);
    currentList.addAll(cList);

    print('Best f: $f, Best o: $o, Best c: $c');
    print('f 추가된 개수: ${fList.length}');
    print('o 추가된 개수: ${oList.length}');
    print('c 추가된 개수: ${cList.length}');

    newList.addAll(fList);
    newList.addAll(oList);
    newList.addAll(cList);

    // 리스트를 섞음
    newList.shuffle(_random);

    if (mounted) {
      setState(() {
        list_.addAll(newList); // 중복 제거 후 리스트 병합
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        isLoading = false;
        initialLoading = false;
        _isLoadingMore = false;
        print('현재 list_ 총 개수 : ${list_.length}');
      });

      // 이미지 URL들을 provider에 추가
      List<String> urls = newList.map((item) => item['img'] as String).toList();
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
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: Center(
          child: Text(
            'FTTI',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
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
      itemCount: list_.length, // 로딩 중이면 추가 아이템 표시
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            String shoppingMallUrl = list_[index]['link'];
            await launchUrl(Uri.parse(shoppingMallUrl));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: list_[index]['img'],
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
