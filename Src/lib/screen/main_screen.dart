import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/screen/Style_Recommendation.dart';
import 'package:ossproj_comfyride/screen/choice_style.dart';
import 'package:ossproj_comfyride/screen/explain_FTTI.dart';
import 'package:ossproj_comfyride/screen/today_recommendation.dart';

class MainScreen extends StatefulWidget {
  final String uid;
  final String? FTTI_full_eng;
  final String? FTTI_eng;
  final double? bestF;
  final double? bestO;
  final double? bestC;
  final int initialIndex;

  const MainScreen({
    required this.uid,
    super.key,
    this.FTTI_full_eng,
    this.FTTI_eng,
    this.bestF,
    this.bestO,
    this.bestC,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _userDataFuture = _fetchUserData(widget.uid); // 사용자 데이터 fetch를 Future로 처리
  }

  Future<Map<String, dynamic>> _fetchUserData(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return {
          'FTTI_eng': doc.data()?['name_eng'] ?? 'Default FTTI Eng',
          'FTTI_full_eng': doc.data()?['FTTI'] ?? 'Default Full FTTI Eng',
          'bestF': (doc.data()?['bestF'] ?? 0.4).toDouble(),
          'bestO': (doc.data()?['bestO'] ?? 0.3).toDouble(),
          'bestC': (doc.data()?['bestC'] ?? 0.3).toDouble(),
        };
      } else {
        return {
          'FTTI_eng': 'Default FTTI Eng',
          'FTTI_full_eng': 'Default Full FTTI Eng',
          'bestF': 0.4,
          'bestO': 0.3,
          'bestC': 0.3,
        };
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
      return {
        'FTTI_eng': 'Default FTTI Eng',
        'FTTI_full_eng': 'Default Full FTTI Eng',
        'bestF': 0.4,
        'bestO': 0.3,
        'bestC': 0.3,
      };
    }
  }

  List<Widget> _widgetOptions(Map<String, dynamic> userData) => <Widget>[
        Choice_Style(uid: widget.uid),
        explain_FTTI(uid: widget.uid),
        StyleRecommendation(
          uid: widget.uid,
          FTTI_eng: userData['FTTI_eng'] ?? 'null',
          FTTI_full_eng: userData['FTTI_full_eng'] ?? 'null',
          bestF: userData['bestF'] ?? 'null',
          bestO: userData['bestO'] ?? 'null',
          bestC: userData['bestC'] ?? 'null',
        ),
        TodayRecommedation()
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture, // FutureBuilder를 사용해 비동기 데이터를 처리
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        } else {
          final userData = snapshot.data!;
          return Scaffold(
            body: _widgetOptions(userData)[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'FTTI 검사하기',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description),
                  label: '내 FTTI',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.recommend),
                  label: '스타일 추천',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.question_mark),
                  label: '오늘 뭐 입지?',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              selectedFontSize: 13,
              unselectedItemColor: Colors.grey,
              unselectedLabelStyle: TextStyle(color: Colors.grey, fontSize: 10),
              onTap: _onItemTapped,
            ),
          );
        }
      },
    );
  }
}
