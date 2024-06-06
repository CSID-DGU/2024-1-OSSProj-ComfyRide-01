import 'package:flutter/material.dart';
import 'package:ossproj_comfyride/ftti.dart';
import 'package:ossproj_comfyride/screen/Style_Recommendation.dart';

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
