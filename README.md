# FTTI(Fashion Tendency Types Indicator)

## Team&Members

> 팀명: 버스태워조

  | 역할 |  성명  |
  | :---: | :---: |
  | FE&팀장 | **이보성** |
  | BE | **장주리** |
  | ML&PM | **김민재** |

## 프로젝트 소개

> 모바일 앱을 통해 사람들에게 선호 스타일을 통해 패션 코드(FTTI)를 부여한다.  
> FTTI를 바탕으로 옷 스타일에 대한 큐레이션과 추천을 해준다.

## 구현결과

### 1. 로그인 화면  

<img src="Doc/imgs/최종보고서_img/1.로그인.png" alt="로그인 화면" height=400>  

### 2. 스타일 선택 화면  

<img src="Doc/imgs/최종보고서_img/2-1.스타일선택.png" alt="스타일 선택화면1" height=400> <img src="Doc/imgs/최종보고서_img/2-2.스타일선택.png" alt="스타일 선택화면2" height=400>

### 3. FTTI 조회 화면  

<img src="Doc/imgs/최종보고서_img/3.FTTI설명.png" alt="FTTI 설명화면" height=400>

### 4. 스타일추천 화면  

<img src="Doc/imgs/최종보고서_img/4-1.추천스타일조회.png" alt="스타일추천화면" height=400>

### 4.1. 찜&찜목록 화면

<img src="Doc/imgs/최종보고서_img/4-2.추천스타일찜.png" alt="스타일찜" height=400> <img src="Doc/imgs/최종보고서_img/4-3.찜목록.png" alt="찜목록" height=400>

### 5. 랜덤 스타일 추천 화면  

<img src="Doc/imgs/최종보고서_img/5.랜덤스타일추천.png" alt="랜덤스타일추천" height=400>

### 6. 아이템 구매 화면

<img src="Doc/imgs/최종보고서_img/4-3.쇼핑몰 이동화면.png" alt="쇼핑몰이동" height=400>
 
### 7. 로그아웃 팝업창

<img src="Doc/imgs/최종보고서_img/6.로그아웃.png" alt="쇼핑몰이동" height=400>  

## 개발 환경

### OS

![mac]( https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=apple&logoColor=white)
![windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)

### Code Editor

![vsCode](https://img.shields.io/badge/Visual_Studio_Code-0078D4?style=for-the-badge&logo=visual%20studio%20code&logoColor=white)
![android Studio](https://img.shields.io/badge/Android_Studio-3DDC84?style=for-the-badge&logo=android-studio&logoColor=white)

### Collaboration Tool

![notion](https://img.shields.io/badge/Notion-000000?style=for-the-badge&logo=notion&logoColor=white)
![slack](https://img.shields.io/badge/Slack-4A154B?style=for-the-badge&logo=slack&logoColor=white)
![github](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)
![figma](https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)
![google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)

## Tech Stack

### FE

![flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![html5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![js](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=JavaScript&logoColor=white)

### ML

![python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

### BE(Server&DB)

![firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)

## 시스템 구성도

![SystemDiagram](./Doc/Diagrams/시스템구성도_20240607수정.png)

이 시스템 구성도는 FTTI 프로젝트의 전체 아키텍처를 나타낸다. 시스템은 크게 Mobile Client와 Google Cloud Platform으로 구성된다.

- **_Mobile Client_**

  - **로그인 및 회원가입:** 사용자는 모바일 클라이언트를 통해 Google 소셜 로그인 기능을 사용하여 쉽게 회원가입 및 로그인을 할 수 있다.
  - **FTTI 및 추천 스타일 조회:** 사용자는 자신의 패션 성향 유형을 확인하고, 이에 맞는 스타일 추천을 받을 수 있다.
  - **선호 스타일 저장 및 저장된 스타일 조회:** 사용자는 선호하는 스타일을 선택하여 저장하고, 저장된 스타일을 조회할 수 있다.
  - **패션 아이템 구매:** 사용자가 추천받은 스타일을 선택하여 직접 구매할 수 있는 기능을 제공한다.

- **_FTTI 앱_**

  - 모바일 클라이언트와 Google Cloud Platform 간의 중개 역할을 하며, 사용자의 요청을 받아 서버와 통신한다.

- **_Google Cloud Platform_**

  - **Cloud Storage:** 이미지 데이터를 저장하는 데 사용된다. 이미지 등록 페이지를 통해 업로드한 이미지 데이터는 이곳에 안전하게 저장된다.
  - **Firestore:** 사용자 데이터와 이미지 데이터의 메타데이터를 저장한다. 사용자의 패션 성향 유형 및 선호 스타일 등의 데이터를 관리한다.
  - **Firebase Authentication:** 사용자의 인증 및 권한 관리를 담당한다. 사용자는 Firebase를 통해 안전하게 로그인하고 자신의 데이터를 관리할 수 있다.

## 기대효과

1. **개인화된 패션 추천 :** 사용자의 패션 관심사와 취향을 고려하여 개인화된 패션 추천을 제공함으로써, 사용자들이 자신에게 맞는 스타일을 더욱 쉽게 발견할 수 있다.
2. **패션 트렌드 이해 증진 :** 앱을 통해 사용자들은 자신의 패션 트렌드 유형을 더 잘 이해하고 인식할 수 있다. 이는 사용자들이 더 나은 패션 선택을 할 수 있도록 돕고, 새로운 트렌드를 발견하는 데 도움이 된다.
3. **고객 만족도 향상 :** 개인화된 추천 시스템을 통해 사용자들은 자신의 취향에 맞는 제품을 더 쉽게 찾을 수 있다. 이는 사용자들의 만족도를 높이고 앱을 계속 이용하도록 유도할 수 있다.
4. **맞춤형 광고 및 마케팅 가능성 :** 개인화된 패션 추천을 통해 사용자의 취향과 관심사를 더 잘 이해할 수 있다. 이는 패션 브랜드 및 이커머스 플랫폼에게 맞춤형 광고 및 마케팅 기회를 제공하고, 광고 효율성을 높일 수 있다.

## 프로젝트 산출물

| 분류 |  산출물  |
| :---: | :---: |
| 수행 | [수행계획서](Doc/1_1_OSSProj_01_버스태워조_수행계획서.md)🔹[수행계획 발표자료](Doc/1_2_OSSProj_01_버스태워조_수행계획발표자료%20.pdf) |
| 중간 | [중간보고서](Doc/2_1_OSSProj_01_버스태워조_중간보고서.md)🔹[중간발표자료](Doc/2_2_OSSProj_01_버스태워조_중간발표자료.pdf)|
| 최종 | [최종보고서](Doc/3_1_OSSProj_01_버스태워조_최종보고서.md)🔹[최종발표자료](Doc/3_2_OSSProj_01_버스태워조_최종발표자료.pdf)|
| 기타 | [제품구성&배포운영자료](Doc/4_3_OSSProj_01_버스태워조_제품구성배포운영자료.md)🔹[Overview](Doc/4_4_OSSProj_01_버스태워조_Overivew.md)🔹[범위&일정&이슈관리](Doc/4_1_OSSProj_01_버스태워조_범위_일정_이슈관리.md)🔹[회의록](Doc/4_2_OSSProj_01_버스태워조_회의록.md) |

[**_📄최신 릴리즈_**](https://github.com/CSID-DGU/2024-1-OSSProj-ComfyRide-01/releases)

## 라이선스

이 프로젝트는 MIT 라이선스에 따라 라이선스가 부여됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.
