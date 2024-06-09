import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/ftti.dart';
import 'package:ossproj_comfyride/screen/Style_Recommendation.dart';

/*
 File Name: navigator.dart
 Description: 사용자 데이터를 스타일 추천화면으로 네비게이션 하는 코드입니다.
 Author: 장주리
 Date Created: 2024-06-07
 Last Modified by: 장주리
 Last Modified on: 2024-06-09
 Copyright (c) 2024, ComfyRide. All rights reserved.
*/

void navigateToStyleRecommendation(BuildContext context, String uid,
    String fttiEng, String fttiFullEng) async {
  FTTI ftti = FTTI(uid: uid);
  Map<String, double> ratios = await ftti.findAndGetBestCode(uid);

  // Navigator를 통해 StyleRecommendation으로 값 전달
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StyleRecommendation(
        uid: uid,
        FTTI_eng: fttiEng,
        FTTI_full_eng: fttiFullEng,
        bestF: ratios['bestF']!,
        bestO: ratios['bestO']!,
        bestC: ratios['bestC']!,
      ),
    ),
  );
}
