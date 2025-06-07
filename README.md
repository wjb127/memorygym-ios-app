# 암기훈련소 (MemoryGym) iOS App

스마트한 플래시카드 학습 앱으로 간격 반복 학습법을 활용한 효율적인 암기 훈련을 제공합니다.

## 주요 기능

- 🧠 **스마트 학습 시스템**: 정답/오답에 따른 자동 난이도 조절 (Lv1~Lv5)
- 📚 **과목별 관리**: 과목 생성 및 플래시카드 관리
- 🎯 **단계별 훈련**: 레벨별 맞춤 훈련 모드
- 📊 **학습 통계**: 정답률 및 학습 진행 상황 추적
- 🔐 **Google/Apple 로그인**: 안전한 사용자 인증
- 📱 **모던 UI/UX**: 깔끔하고 직관적인 사용자 인터페이스

## 설정 방법

### 1. 프로젝트 복제
```bash
git clone https://github.com/wjb127/memorygym-ios-app.git
cd memorygym-ios-app
```

### 2. Firebase 설정
1. [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
2. iOS 앱 추가 (Bundle ID: `com.memorygym.app`)
3. `GoogleService-Info.plist` 파일 다운로드
4. 다운로드한 파일을 프로젝트 루트에 복사 (`.gitignore`에 의해 Git 추적되지 않음)

### 3. CocoaPods 설치
```bash
pod install
```

### 4. Xcode에서 실행
```bash
open MemoryGym.xcworkspace
```

## 프로젝트 구조

```
MemoryGym/
├── Models/           # 데이터 모델 (Subject, Flashcard)
├── Services/         # Firebase 서비스 (Auth, Firestore)
├── Views/           # SwiftUI 뷰
│   ├── Training/    # 암기 훈련 관련 뷰
│   ├── Subject/     # 과목 관리 뷰
│   └── Flashcard/   # 플래시카드 관리 뷰
├── Data/            # 초기 데이터 (중급 영단어)
└── Assets.xcassets  # 앱 리소스
```

## 기술 스택

- **프레임워크**: SwiftUI, UIKit
- **백엔드**: Firebase (Auth, Firestore)
- **의존성 관리**: CocoaPods
- **프로젝트 생성**: XcodeGen
- **최소 지원 버전**: iOS 15.0+

## 개발 팀

개발: [Your Name]

## 라이선스

이 프로젝트는 개인 학습 목적으로 개발되었습니다.

---

⚠️ **중요**: `GoogleService-Info.plist` 파일은 보안상 Git에 포함되지 않습니다. 위의 설정 방법을 따라 Firebase에서 직접 다운로드해주세요. 