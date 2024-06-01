import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:ossproj_comfyride/explain_FTTI.dart';
import 'package:ossproj_comfyride/ftti.dart';

class Choice_Style extends StatefulWidget {
  final String uid;
  Choice_Style({required this.uid, super.key});

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

  @override
  void initState() {
    super.initState();
    _loadData();
    _choiceShoweDialog();
  }

  Future<void> _loadData() async {
    if (isLoading) return; // 이미 로딩 중이면 중복 실행 방지
    setState(() => isLoading = true);
    var querySnapshot = await db.collection('data_').get();
    List<Map<String, dynamic>> _newList = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      if (data.containsKey('img') && data.containsKey('code')) {
        _newList.add({'id': doc.id, 'img': data['img'], 'code': data['code']});
        bool_Grid.add(false);
      } else {
        // 필요한 필드가 없을 경우 처리
        print('문서 ${doc.id}에 img 또는 code 필드가 없습니다.');
      }
    }
    setState(() {
      _imageList = _newList;
      isLoading = false;
    });
  }

  void _choiceShoweDialog() {
    Future.delayed(const Duration(milliseconds: 10), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.network(
              "https://raw.githubusercontent.com/Shashank02051997/FancyGifDialog-Android/master/GIF's/gif15.gif",
              height: 400,
              fit: BoxFit.cover,
            ),
            title: const Text(
              '나만의 FTTI 찾기',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              '마음에 드는 옷을 선택하면\n나의 FTTI를 알 수 있습니다!',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text(
                  '시작',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _explainShowDialog() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GiffyDialog.image(
            Image.network(
              "https://raw.githubusercontent.com/Shashank02051997/FancyGifDialog-Android/master/GIF's/gif16.gif",
              height: 300,
              fit: BoxFit.cover,
            ),
            title: Text(
              '나만의 FTTI 생성이\n완료 됐습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '보러가기',
                  textAlign: TextAlign.center,
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
            SizedBox(
              height: 5,
            ),
            Column(
              children: [
                SizedBox(height: 10),
                Text(
                  '취향에 맞는 옷을 선택해주세요\n ${count.toString()}/10개',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Expanded(child: grid_generator()),
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
        ),
      ),
    );
  }

  Widget grid_generator() {
    if (_imageList.isEmpty || isLoading) {
      // list_가 비어 있는지 확인
      return Center(child: CircularProgressIndicator()); // 로딩 인디케이터 표시
    }
    return MasonryGridView.builder(
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: 30,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemBuilder: (context, index) {
        final item = _imageList[index];

        return GestureDetector(
            onTap: () {
              setState(() {
                if (count < 10) {
                  if (bool_Grid[index] == false) {
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
                  _saveUserSelection();
                  _explainShowDialog();
                  _callFTTI().then((_) {
                    setState(() {
                      isDone = false;
                    });
                    Future.delayed(const Duration(milliseconds: 3500), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  explain_FTTI(uid: widget.uid)));
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
                      child: Image.network(_imageList[index]['img']),
                    ),
                    if (bool_Grid[index])
                      Container(
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.check,
                            color: Colors.blue,
                            size: 90,
                          )),
                  ],
                )));
      },
    );
  }

  Future<void> _callFTTI() async {
    await FTTI(uid: widget.uid).findAndGetBestCode();
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
