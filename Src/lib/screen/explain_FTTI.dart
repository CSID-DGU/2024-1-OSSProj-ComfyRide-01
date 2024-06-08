import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/provider/ImageProviderNotifier.dart';
import 'package:ossproj_comfyride/screen/main_screen.dart';
import 'package:provider/provider.dart';
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
  String FTTI_full_eng = '';
  String exp = '';
  String sum = '';
  String tip = '';
  String img = '';
  bool isLoading = true;
  bool isNextPageLoading = false; // 다음 페이지 로딩 상태

  @override
  void initState() {
    super.initState();
    getUserFTTI(widget.uid);
  }

  // 사용자 FTTI 불러옴
  Future<void> getUserFTTI(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userFTTI = userDoc.data()?['name_eng'] ?? "No FTTI available";
        await getExplain(userFTTI);
      } else {
        if (mounted) {
          setState(() {
            FTTI_eng = "User not found";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          FTTI_eng = "Error fetching data";
          isLoading = false;
        });
      }
    }
  }

  // 사용자 FTTI에 맞는 설명 불러옴
  Future<void> getExplain(String FTTI) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
          .collection('explain_FTTI')
          .where('name_eng', isEqualTo: FTTI)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        if (mounted) {
          setState(() {
            img = doc['img'] ?? "No img available";
            FTTI_eng = doc['name_eng'] ?? "No name_eng available";
            FTTI_full_eng = doc['full_eng'] ?? "No full_name available";
            exp = doc['exp'] ?? "No explain available";
            sum = doc['sum'] ?? "No sum available";
            tip = doc['tip'] ?? "No tip available";
            isLoading = false;
          });
        }
        // 다음 페이지 이미지 미리 로드
        await preloadNextPageImages();
      } else {
        if (mounted) {
          setState(() {
            FTTI_full_eng = "No corresponding FTTI found";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          FTTI_full_eng = "Error fetching data";
          isLoading = false;
        });
      }
    }
  }

  // 다음 페이지에서 사용할 이미지를 미리 로드
  Future<void> preloadNextPageImages() async {
    try {
      FTTI ftti = FTTI(uid: widget.uid);
      Map<String, double> ratios = await ftti.findAndGetBestCode(widget.uid);
      List<String> urls = await getUrlsForPreload(ratios);

      await Provider.of<ImageProviderNotifier>(context, listen: false)
          .addUrls(urls, context);
    } catch (e) {
      print('Error preloading images: $e');
    }
  }

  // 비율에 맞는 이미지 URL들을 가져오는 함수
  Future<List<String>> getUrlsForPreload(Map<String, double> ratios) async {
    List<String> urls = [];
    for (String code in ['f', 'o', 'c']) {
      double ratio = ratios[code] ?? 0.0;
      if (ratio > 0) {
        QuerySnapshot querySnapshot = await db
            .collection('data_real')
            .where('code', isEqualTo: code)
            .limit((30 * ratio).round())
            .get();
        urls.addAll(
            querySnapshot.docs.map((doc) => doc['img'] as String).toList());
      }
    }
    return urls;
  }

  // Navigator를 통해 StyleRecommendation 화면으로 이동하고 데이터 전달
  void navigateToStyleRecommendation(BuildContext context) async {
    setState(() {
      isNextPageLoading = true; // 다음 페이지 로딩 상태 시작
    });

    FTTI ftti = FTTI(uid: widget.uid);
    Map<String, double> ratios = await ftti.findAndGetBestCode(widget.uid);

    // 페이지 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          uid: widget.uid,
          FTTI_eng: FTTI_eng,
          FTTI_full_eng: FTTI_full_eng,
          bestF: ratios['bestF']!,
          bestO: ratios['bestO']!,
          bestC: ratios['bestC']!,
          initialIndex: 2,
        ),
      ),
    );

    setState(() {
      isNextPageLoading = false; // 다음 페이지 로딩 상태 종료
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: screenHeight * 0.01)),
                Text(
                  '당신의 FTTI는? ',
                  style: TextStyle(fontSize: screenWidth * 0.06),
                  textAlign: TextAlign.center,
                ),
                Text(
                  FTTI_full_eng,
                  style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  height: screenHeight * 0.45,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : CachedNetworkImage(
                            imageUrl: img,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) {
                              print('Error loading image: $error');
                              return Icon(Icons.error);
                            },
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.01),
                      child: Column(
                        children: [
                          Container(
                            width: screenWidth * 0.8,
                            child: Text(
                              " " + exp + "\n\n" + tip,
                              style: TextStyle(fontSize: screenWidth * 0.04),
                            ),
                          )
                        ],
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
