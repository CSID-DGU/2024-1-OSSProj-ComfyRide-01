import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class FTTI {
  final String? uid;
  double bestF = 0;
  double bestO = 0;
  double bestC = 0;

  FTTI({required this.uid});

  FirebaseFirestore db = FirebaseFirestore.instance;

  // 1. 사용자 DB로부터 "선택 결과" 필드를 불러옴
  Future<Map<String, int>> getUserSelectedResult() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await db.collection('users').doc(uid).get();
    return Map<String, int>.from(userDoc.data()!['code_count']);
  }

  // 2. f, o, c 각각의 값을 비율로 변환
  Map<String, double> calculateRatios(Map<String, int> selectedResult) {
    int total = selectedResult.values.reduce((a, b) => a + b);
    return {
      'f': selectedResult['f']! / total,
      'o': selectedResult['o']! / total,
      'c': selectedResult['c']! / total,
    };
  }

  // 3. ftti.csv 파일에서 데이터를 읽어들임
  Future<List<List<dynamic>>> readCSV(String assetPath) async {
    try {
      final data = await rootBundle.loadString(assetPath);
      return CsvToListConverter().convert(data);
    } catch (e) {
      print('Failed to read CSV file: $e');
      return [];
    }
  }

  // 4. 각 행과 비교하여 가장 작은 제곱합을 가지는 행의 코드를 찾음
  String findBestCode(List<List<dynamic>> fields, Map<String, double> ratios) {
    double minDifference = double.infinity;
    String bestCode = '';

    // Skip the header and process data rows
    for (var row in fields.skip(1)) {
      try {
        double f = parseDouble(row[0]);
        double o = parseDouble(row[1]);
        double c = parseDouble(row[2]);
        String code = row[3].toString().trim();

        double difference = (ratios['f']! - f) * (ratios['f']! - f) +
            (ratios['o']! - o) * (ratios['o']! - o) +
            (ratios['c']! - c) * (ratios['c']! - c);

        if (difference < minDifference) {
          minDifference = difference;
          bestCode = code;
          bestF = f;
          bestO = o;
          bestC = c;
        }
      } catch (e) {
        print('Error parsing row: $row. Error: $e');
        continue;
      }
    }

    print('Best f: $bestF, Best o: $bestO, Best c: $bestC');
    return bestCode;
  }

  double parseDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        throw FormatException('Invalid double: $value');
      }
    } else {
      throw FormatException('Invalid type for double conversion: $value');
    }
  }

  // 5. 가장 작은 제곱합을 가지는 행의 코드를 출력
  Future<Map<String, double>> findAndGetBestCode() async {
    Map<String, int> selectedResult = await getUserSelectedResult();
    Map<String, double> ratios = calculateRatios(selectedResult);
    List<List<dynamic>> fields = await readCSV('assets/ftti.csv');
    String bestCode = findBestCode(fields, ratios);

    // 유저별 FTTI DB에 추가
    await db.collection('users').doc(uid).update({
      'FTTI': bestCode,
    });

    return {
      'bestF': bestF,
      'bestO': bestO,
      'bestC': bestC,
    };
  }
}
