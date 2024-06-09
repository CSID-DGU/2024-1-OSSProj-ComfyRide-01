import 'package:flutter/material.dart';

/*
 File Name: ImageProviderNotifier.dart
 Description: 해당 프로젝트의 상태관리를 위한 파일입니다.
 Author: 장주리
 Date Created: 2024-06-03
 Last Modified by: 장주리
 Last Modified on: 2024-06-09
 Copyright (c) 2024, ComfyRide. All rights reserved.
*/

class ImageProviderNotifier extends ChangeNotifier {
  final List<String> _urls = [];
  final Map<String, bool> _loadedUrls = {};
  List<String> _likedUrls = [];
  List<String> get likedUrls => _likedUrls;

  // 현재 로드된 이미지 URL 리스트 반환
  List<String> get urls => _urls;

  // 해당 URL이 로드되었는지 여부 확인
  bool isLoaded(String url) => _loadedUrls[url] ?? false;

  // 새로운 URL들을 추가하고 이미지 미리 로드 시작
  Future<void> addUrls(List<String> urls, BuildContext context) async {
    for (var url in urls) {
      if (!_urls.contains(url)) {
        // 중복 방지
        _urls.add(url);
        _loadedUrls[url] = false;
        await _loadImage(url, context);
      }
    }
  }

  // 이미지를 비동기로 미리 로드
  Future<void> _loadImage(String url, BuildContext context) async {
    try {
      await precacheImage(NetworkImage(url), context); // context 사용
      _loadedUrls[url] = true; // 로드 완료 표시
      notifyListeners(); // 상태 변경 알림
    } catch (e) {
      _loadedUrls[url] = false; // 로드 실패 표시
    }
  }

  // 좋아요 URL 추가
  void addUrl(String url) {
    if (!_likedUrls.contains(url)) {
      _likedUrls.add(url);
      notifyListeners();
    }
  }

  // 좋아요 URL 제거
  void removeUrl(String url) {
    if (_likedUrls.contains(url)) {
      _likedUrls.remove(url);
      notifyListeners();
    }
  }
}
