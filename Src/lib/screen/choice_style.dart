import 'dart:math';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:ossproj_comfyride/ftti.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ossproj_comfyride/screen/Login_Screen.dart';
import 'package:ossproj_comfyride/screen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Choice_Style extends StatefulWidget {
  final String uid;
  final bool isFirstLogin;
  Choice_Style({required this.uid, required this.isFirstLogin, super.key});

  @override
  State<Choice_Style> createState() => _Choice_Style();
}

class _Choice_Style extends State<Choice_Style> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _imageList = <Map<String, dynamic>>[];
  List<bool> bool_Grid = [];
  bool isLoading = false; // 로딩 상태 추적
  bool isDone = false; // 스타일 선택 완료 여부
  var count = 0;
  List<Map<String, dynamic>> _userSelectCode = <Map<String, dynamic>>[];
  DocumentSnapshot? _lastDocument; // 마지막으로 로드된 문서
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random(); // 랜덤 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _loadData();
    _choiceShoweDialog();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _loadData(); //스크롤 끝에 도달 후 로딩중이 아니면 함수 호출
      }
    });
  }

  Future<void> _loadData() async {
    if (isLoading) return; // 이미 로딩 중이면 중복 실행 방지
    setState(() => isLoading = true);

    QuerySnapshot querySnapshot;
    if (_lastDocument == null) {
      querySnapshot = await db.collection('data_').limit(50).get();
    } else {
      querySnapshot = await db
          .collection('data_')
          .startAfterDocument(_lastDocument!)
          .limit(20)
          .get();
    }

    List<Map<String, dynamic>> _newList = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('img') && data.containsKey('code')) {
        _newList.add({'id': doc.id, 'img': data['img'], 'code': data['code']});
        bool_Grid.add(false);
      } else {
        // 필요한 필드가 없을 경우 처리
        print('문서 ${doc.id}에 img 또는 code 필드가 없습니다.');
      }
    }

    // 새로 추가된 데이터를 랜덤으로 섞음
    _newList.shuffle(_random);

    setState(() {
      _imageList.addAll(_newList);
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }
      isLoading = false;
    });
    print("현재 _imageList 총 개수: ${_imageList.length}");
  }

  void _choiceShoweDialog() {
    Future.delayed(const Duration(milliseconds: 10), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          double screenHeight = MediaQuery.of(context).size.height;
          double screenWidth = MediaQuery.of(context).size.width;

          return GiffyDialog.image(
            Image.network(
              "https://raw.githubusercontent.com/Shashank02051997/FancyGifDialog-Android/master/GIF's/gif15.gif",
              height: screenHeight * 0.3,
              fit: BoxFit.cover,
            ),
            title: Text(
              '나만의 FTTI 찾기',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.055,
              ),
            ),
            content: Text(
              '마음에 드는 옷을 선택하면\n나의 FTTI를 알 수 있습니다!',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: Text(
                  '시작',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: widget.isFirstLogin
          ? AppBar(
              centerTitle: true,
              title: Text(
                'FTTI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.08,
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
                          title: Text(
                            "로그아웃",
                            style: TextStyle(
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "로그아웃 됐습니다.",
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text("확인"),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('isLoggedIn');
                                await prefs.remove('uid');
                                print('로그아웃 완료');
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => Login_Screen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = constraints.maxHeight;
          double screenWidth = constraints.maxWidth;

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
                    '취향에 맞는 옷을 선택해주세요\n ${count.toString()}/10개',
                    style: TextStyle(fontSize: screenWidth * 0.053),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Expanded(
                    child: isLoading && _imageList.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : grid_generator(screenWidth),
                  ),
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: isDone
                      ? SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator())
                      : Container(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget grid_generator(double screenWidth) {
    return MasonryGridView.builder(
      controller: _scrollController,
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: _imageList.length + (isLoading ? 1 : 0),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemBuilder: (context, index) {
        if (index == _imageList.length) {
          return Center(child: CircularProgressIndicator());
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              if (count < 10) {
                if (!bool_Grid[index]) {
                  bool_Grid[index] = true;
                  _userSelectCode.add({
                    'img_id': _imageList[index]['id'],
                    'code': _imageList[index]['code'],
                  });
                  count++;
                } else {
                  bool_Grid[index] = false;
                  _userSelectCode.removeWhere(
                      (item) => item['img_id'] == _imageList[index]['id']);
                  count--;
                }
              }
              if (count == 10) {
                setState(() {
                  isDone = true;
                });
                _saveUserSelection(); //사용자가 선택한 스타일 db에 저장
                Dialog();
                _callFTTI().then((_) {
                  //callFTTI 완료된 후 3.5초 이후 아래 실행
                  Future.delayed(const Duration(milliseconds: 3500), () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            MainScreen(uid: widget.uid, initialIndex: 1),
                      ),
                    );
                  });
                });
              }
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 이미지 선택시 효과
                Opacity(
                  opacity: bool_Grid[index] ? 0.3 : 1,
                  child: CachedNetworkImage(
                    imageUrl: _imageList[index]['img'],
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
                if (bool_Grid[index])
                  Container(
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check,
                      color: Colors.blue,
                      size: 90,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  //사용자 FTTI 정의
  Future<void> _callFTTI() async {
    await FTTI(uid: widget.uid).findAndGetBestCode(widget.uid);
  }

  // Firestore에 user별 선택한 스타일 추가
  Future<void> _saveUserSelection() async {
    List<String> selectedCodes =
        _userSelectCode.map((item) => item['code'] as String).toList();

    // 각 코드별 개수를 계산하기 위한 맵 초기화
    Map<String, int> codeCountMap = {'o': 0, 'c': 0, 'f': 0};

    // selectedCodes 리스트를 순회하며 각 코드의 개수를 증가시킴
    for (String code in selectedCodes) {
      if (codeCountMap.containsKey(code)) {
        codeCountMap[code] = codeCountMap[code]! + 1;
      }
    }

    // 결과를 원하는 형식으로 출력
    Map<String, int> result = {
      'f': codeCountMap['f']!,
      'o': codeCountMap['o']!,
      'c': codeCountMap['c']!
    };
    // DB에 내용 반영
    await db.collection('users').doc(widget.uid).update({
      'selected_codes': selectedCodes,
      'code_count': result,
    });

    print(result);
  }
}
