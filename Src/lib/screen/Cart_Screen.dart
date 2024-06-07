import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

class Cart extends StatefulWidget {
  final String uid;
  final String FTTI_eng;
  final String FTTI_full_eng;
  final double bestF;
  final double bestO;
  final double bestC;

  Cart({
    required this.uid,
    required this.FTTI_eng,
    required this.FTTI_full_eng,
    required this.bestF,
    required this.bestO,
    required this.bestC,
    super.key,
  });

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> list_ = [];
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
      querySnapshot = await db
          .collection('cart_data')
          .where('uid', isEqualTo: widget.uid)
          .limit(30)
          .get();
    } else {
      querySnapshot = await db
          .collection('cart_data')
          .where('uid', isEqualTo: widget.uid)
          .startAfterDocument(_lastDocument!)
          .limit(20)
          .get();
    }

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      list_.add({
        'img': data['img'],
        'link': data['link'],
        'docId': doc.id, // 문서 ID를 저장하여 삭제 시 사용
      });
    }

    if (mounted) {
      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        isLoading = false;
        initialLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  //좋아요 취소 기능
  Future<void> _removeFromCart(int index) async {
    String docId = list_[index]['docId'];
    await db.collection('cart_data').doc(docId).delete();
    setState(() {
      list_.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('찜 목록에서 제거 됐습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ), // 왼쪽 메뉴버튼
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        flexibleSpace: Container(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0), // 시스템 상태바 공간을 고려한 패딩
            child: Text(
              'FTTI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
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
                "찜 LIST",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        return Stack(
          children: [
            GestureDetector(
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
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () {
                  _removeFromCart(index);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
