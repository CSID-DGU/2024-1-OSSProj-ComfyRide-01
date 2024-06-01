import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:ossproj_comfyride/Style_Recommendation.dart';
import 'package:ossproj_comfyride/ftti.dart';

class explain_FTTI extends StatefulWidget {
  final String uid;
  const explain_FTTI({required this.uid, super.key});

  @override
  State<explain_FTTI> createState() => _explain_FTTIState();
}

FirebaseFirestore db = FirebaseFirestore.instance;

class _explain_FTTIState extends State<explain_FTTI> {
  String userFTTI = '';
  String FTTI_eng = '';
  String FTTI_kor = '';
  String exp = '';
  String sum = '';
  String tip = '';
  String img = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserFTTI(widget.uid);
  }

  // 사용자 FTTI 불러옴
  Future<void> getUserFTTI(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await db.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        userFTTI = userDoc.data()?['FTTI'] ?? "No FTTI available";
        getExplain(userFTTI);
      });
    } else {
      setState(() {
        FTTI_eng = "User not found";
        isLoading = false;
      });
    }
  }

  // 사용자 FTTI에 맞는 설명 불러옴
  Future<void> getExplain(String FTTI) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
        .collection('explain_FTTI')
        .where('name_eng', isEqualTo: FTTI)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      setState(() {
        img = doc['img'] ?? "No img available";
        FTTI_eng = doc['name_eng'] ?? "No name_eng available";
        FTTI_kor = doc['name_kor'] ?? "No name_kor available";
        exp = doc['exp'] ?? "No explain available";
        sum = doc['sum'] ?? "No sum available";
        tip = doc['tip'] ?? "No tip available";
        isLoading = false;
      });
    } else {
      setState(() {
        FTTI_kor = "No corresponding FTTI found";
        isLoading = false;
      });
    }
  }

  // Navigator를 통해 StyleRecommendation 화면으로 이동하고 데이터 전달
  void navigateToStyleRecommendation(BuildContext context) async {
    FTTI ftti = FTTI(uid: widget.uid);
    Map<String, double> ratios = await ftti.findAndGetBestCode();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StyleRecommendation(
          uid: widget.uid,
          FTTI_eng: FTTI_eng,
          FTTI_kor: FTTI_kor,
          bestF: ratios['bestF']!,
          bestO: ratios['bestO']!,
          bestC: ratios['bestC']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            onPressed: () => navigateToStyleRecommendation(
                context), // 버튼 클릭 시 navigateToStyleRecommendation 호출
            label: Text(
              '내 FTTI에 맞는 옷 추천받기',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 39, 158, 255),
            icon: Icon(
              Icons.add_chart_outlined,
              color: Colors.white,
            ),
          ),
        ),
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
            SizedBox(height: 5),
            Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 10)),
                Text(
                  FTTI_kor,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Container(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Image.network(
                            img,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                  // 이미지가 로드되는 동안 로딩 인디케이터를 표시
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Column(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width *
                                  0.85, //전체 가로의 85%
                              child: Text(
                                " " + exp + "\n\n" + tip,
                                style: TextStyle(fontSize: 16),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
