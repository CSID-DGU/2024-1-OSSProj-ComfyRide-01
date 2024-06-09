# A4.3 OSS 프로젝트 제품 구성, 배포 및 운영 자료

## 1. 프로젝트 제품 구성

[제품 Overview 보러가기](4_4_OSSProj_01_버스태워조_Overivew.md)

## 2. 프로젝트 제품 배포 방법

### Github Releases&Tags 활용

1. 개발을 마친 최종 app 결과물을 Android Studio를 통해 apk로 빌드.
2. 팀 repo의 Releases에서 **Draft a new release** 클릭.
3. **Choose a tag**를 클릭한 후 내가 배포하려는 app의 버전명을 입력 eg. v1.0.0
4. Release title과 Release 노트를 작성한 후 1.에서 빌드한 apk 파일을 첨부.
5. **Publish release**클릭.

## 3. 프로젝트 제품 운영 방법

### PC(Windows)

1. [블루스택 설치 페이지](https://www.bluestacks.com/download.html) 에서 BlueStacks 5 섹션에 Pie 64-bit 버전을 다운로드 합니다. 블루스택 5 설치 프로그램 다운로드가 시작됩니다. 다운로드가 완료되면 설치 프로그램 파일을 클릭하여 계속 진행하세요.
2. "지금 설치" 버튼을 클릭하세요. 여기에서 설치 중인 블루스택 5 버전도 확인할 수 있습니다.
3. [링크](https://support.bluestacks.com/hc/ko/articles/360058371832-PC%EC%97%90%EC%84%9C-%EB%B8%94%EB%A3%A8%EC%8A%A4%ED%83%9D5%EC%9A%A9-%EA%B0%80%EC%83%81%ED%99%94%EA%B0%80-%EC%A7%80%EC%9B%90-%EB%98%90%EB%8A%94-%ED%99%9C%EC%84%B1%ED%99%94%EB%90%98%EC%97%88%EB%8A%94%EC%A7%80-%ED%99%95%EC%9D%B8%ED%95%98%EB%8A%94-%EB%B0%A9%EB%B2%95)의 내용을 통해 가상화가 활성화되었는지 확인하고, 되었다면 BlueStacks 5를 관리자 권한으로 실행합니다.
4. [apk다운로드](https://github.com/CSID-DGU/2024-1-OSSProj-ComfyRide-01/releases/tag/v1.0.4)에 접속하여 apk 파일을 다운로드 받습니다.
5. 실행한 후, BlueStacks App Player의 우측 중앙에 "APK 설치" 버튼을 클릭합니다.(Ctr+Shift+B)
6. **_4_** 에서 다운받은 파일의 경로로 가서, 다운로드 한 파일을 더블클릭 한다.
7. 설치가 완료 되면 앱을 사용합니다.

### 모바일(Android)

1. 내 휴대폰의 [설정] - [보안 및 개인정보 보호] - [기타보안] - [출처를 알 수 없는 앱 설치] 또는 [설정]에서 '출처를 알 수 없는 앱 설치' 검색합니다.
2. apk 다운로드 받을 앱의 설치를 허용합니다.(오른쪽 막대바 클릭)
3. [apk다운로드](https://github.com/CSID-DGU/2024-1-OSSProj-ComfyRide-01/releases/tag/v1.0.4)에 접속하여 apk 파일을 다운로드 받습니다.
4. '유해한 파일일 수도 있음' 등의 팝업이 뜨면 '무시하고 다운로드'를 선택합니다.
5. 설치가 완료 되면 앱을 사용합니다.

### 시연 시나리오

1. 회원가입 및 소셜 로그인
2. FTTI 검사 -> 조회 -> 추천 스타일 조회 -> 아이템 구매
3. 선호 스타일 찜 -> 찜목록 조회 -> 찜목록 삭제 -> 아이템 구매
4. 랜덤 스타일 조회 -> 아이템 구매

[참고: 시퀀스 다이어그램](./3_1_OSSProj_01_버스태워조_최종보고서.md#시퀀스-다이어그램)

[👉***README로 돌아가기***](https://github.com/CSID-DGU/2024-1-OSSProj-ComfyRide-01)
