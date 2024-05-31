import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/Style_Recommendation.dart';
import 'package:ossproj_comfyride/ftti.dart';

void navigateToStyleRecommendation(
    BuildContext context, String uid, String fttiEng, String fttiKor) async {
  FTTI ftti = FTTI(uid: uid);
  Map<String, double> ratios = await ftti.findAndGetBestCode();

  // Navigator를 통해 StyleRecommendation으로 값 전달
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StyleRecommendation(
        uid: uid,
        FTTI_eng: fttiEng,
        FTTI_kor: fttiKor,
        bestF: ratios['bestF']!,
        bestO: ratios['bestO']!,
        bestC: ratios['bestC']!,
      ),
    ),
  );
}
