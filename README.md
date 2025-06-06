# MemoryGym iOS 앱

## 프로젝트 개요
MemoryGym은 플래시카드 기반 학습 앱으로, 간격 반복 학습법을 사용한 암기 훈련 앱입니다.

## 주요 기능

### 1. 인증 시스템 ✅
- **게스트 모드**: 로그인 없이 체험 가능 (로컬 데이터 사용)
- **Apple 로그인**: iOS 필수 요구사항 완료 🍎
- **Google 로그인**: Firebase Authentication 연동 (추후 구현)

### 2. 핵심 기능
- **암기훈련**: 플래시카드 기반 학습
- **퀴즈관리**: 플래시카드 CRUD 기능
- **과목관리**: 과목별 플래시카드 분류
- **간격 반복 학습법**: 5단계 박스 시스템

### 3. 게스트 모드
- 중급 영단어 50개 제공
- 로그인 없이 모든 기능 체험 가능

### 4. 사용자 관리 🆕
- **프로필 관리**: 사용자 정보 표시
- **로그아웃 기능**: 안전한 세션 종료
- **계정 타입 표시**: 게스트/로그인 사용자 구분

## 기술 스택
- **언어**: Swift 5.9+
- **UI**: SwiftUI
- **아키텍처**: MVVM 패턴
- **상태관리**: @Observable
- **인증**: AuthenticationServices (Apple 로그인)
- **보안**: CryptoKit (SHA256 해싱)
- **최소 지원**: iOS 15.0+

## 프로젝트 구조
```
memorygym-swift-app/
├── Models/
│   ├── User.swift
│   ├── Subject.swift
│   └── Flashcard.swift
├── Views/
│   ├── SplashView.swift
│   ├── LoginView.swift
│   ├── MainTabView.swift
│   ├── StudyView.swift
│   ├── FlashcardManagementView.swift
│   ├── SubjectManagementView.swift
│   └── Components/
│       ├── FlashcardView.swift
│       ├── AppleSignInButton.swift
│       └── UserProfileView.swift
├── Managers/
│   ├── DataManager.swift
│   └── AuthenticationManager.swift
├── Data/
│   └── GuestData.swift
├── Utils/
│   └── DesignSystem.swift
├── Assets.xcassets/
├── Preview Content/
├── MemoryGymApp.swift
├── ContentView.swift
├── Info.plist
├── README.md
└── APPLE_SIGNIN_SETUP.md
```

## 설치 및 실행

### 요구사항
- Xcode 15.0+
- iOS 15.0+
- macOS 14.0+
- Apple Developer Account (Apple 로그인 테스트용)

### 실행 방법
1. Xcode에서 프로젝트 열기
2. Signing & Capabilities에서 "Sign in with Apple" 추가
3. Bundle Identifier 설정
4. 시뮬레이터 또는 실제 기기 선택
5. ⌘+R로 빌드 및 실행

### Apple 로그인 설정
자세한 설정 방법은 [APPLE_SIGNIN_SETUP.md](APPLE_SIGNIN_SETUP.md) 참조

## 개발 현황

### Phase 1: 기본 구조 ✅
- [x] 프로젝트 설정 (SwiftUI)
- [x] 네비게이션 구조
- [x] 게스트 모드 구현 (로컬 데이터)
- [x] 기본 UI 컴포넌트
- [x] 디자인 시스템

### Phase 2: 핵심 기능 ✅
- [x] 플래시카드 학습 로직
- [x] Apple 로그인 구현 🍎
- [x] 사용자 프로필 관리
- [x] 인증 시스템 기반 구조
- [ ] Firebase 연동
- [ ] Google 로그인
- [ ] 데이터 동기화

### Phase 3: 고급 기능 (예정)
- [ ] AdMob 광고
- [ ] 간격 반복 알고리즘 개선
- [ ] 통계 및 진도 추적
- [ ] 앱 스토어 최적화

## 🍎 Apple 로그인 기능

### 구현된 기능
- **보안 인증**: Nonce 기반 보안 + SHA256 해싱
- **사용자 관리**: Apple ID 정보 연동
- **에러 처리**: 사용자 친화적 오류 메시지
- **상태 관리**: 로그인/로그아웃 상태 추적

### App Store 정책 준수
- ✅ Apple 로그인 제공 (필수)
- ✅ 게스트 모드 지원
- ✅ 개인정보 처리방침 설정
- ✅ 사용자 권한 명시

## 테스트 가이드

### 기본 기능 테스트
1. **게스트 모드**: 로그인 없이 모든 기능 사용
2. **Apple 로그인**: Apple ID로 로그인/로그아웃
3. **플래시카드 학습**: 암기훈련 기능
4. **데이터 관리**: 과목/카드 추가/삭제

### Apple 로그인 테스트
1. **성공 시나리오**: 로그인 → 프로필 확인 → 로그아웃
2. **취소 시나리오**: 로그인 취소 → 오류 메시지 확인
3. **재로그인**: 로그아웃 후 재로그인 테스트

## 라이선스
MIT License

## 기여하기
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AppleSignIn`)
3. Commit your Changes (`git commit -m 'Add Apple Sign In'`)
4. Push to the Branch (`git push origin feature/AppleSignIn`)
5. Open a Pull Request

## 연락처
프로젝트 관련 문의: [이메일 주소]

---

## 🎉 최신 업데이트 (Apple 로그인 추가)

### 새로운 기능
- **Apple 로그인**: App Store 정책 준수를 위한 필수 기능
- **사용자 프로필**: 로그인 사용자 정보 관리
- **보안 강화**: 암호화 기반 인증 시스템
- **UX 개선**: 직관적인 로그인/로그아웃 플로우

### 기술적 개선
- **AuthenticationManager**: 통합 인증 관리 시스템
- **보안 토큰**: Nonce + SHA256 해싱
- **상태 관리**: Combine 기반 반응형 UI
- **에러 핸들링**: 사용자 친화적 오류 처리

이제 MemoryGym은 Apple 로그인을 완전히 지원하며, App Store 출시 준비가 완료되었습니다! 🚀 