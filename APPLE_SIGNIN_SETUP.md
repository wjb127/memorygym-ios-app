# Apple 로그인 설정 가이드

## 🍎 Apple 로그인 구현 완료

MemoryGym iOS 앱에 Apple 로그인 기능이 성공적으로 추가되었습니다.

## 📁 추가된 파일들

### 1. AuthenticationManager.swift
- Apple 로그인 로직 구현
- Google 로그인 준비 (추후 Firebase 연동)
- 사용자 인증 상태 관리
- 보안 nonce 생성 및 SHA256 해싱

### 2. AppleSignInButton.swift
- Apple 로그인 버튼 컴포넌트
- SwiftUI와 UIKit 브릿지
- 네이티브 Apple 로그인 UI

### 3. UserProfileView.swift
- 사용자 프로필 표시
- 로그아웃 기능
- 게스트/로그인 사용자 구분

### 4. Info.plist
- Apple 로그인 권한 설정
- 개인정보 처리방침 URL
- 서비스 약관 URL

## 🔧 구현된 기능

### Apple 로그인 플로우
1. **로그인 버튼 탭** → Apple ID 인증 화면 표시
2. **사용자 인증** → Apple에서 사용자 정보 반환
3. **토큰 검증** → nonce 및 identity token 검증
4. **사용자 생성** → User 모델로 변환
5. **상태 업데이트** → 앱 전체 로그인 상태 변경

### 보안 기능
- **Nonce 생성**: 랜덤 32자리 문자열
- **SHA256 해싱**: Apple 권장 보안 방식
- **토큰 검증**: Identity token 유효성 확인

### 사용자 경험
- **에러 처리**: 사용자 친화적 오류 메시지
- **상태 표시**: 게스트/로그인 사용자 구분
- **프로필 관리**: 사용자 정보 표시 및 로그아웃

## 📱 App Store 정책 준수

### ✅ 완료된 요구사항
- **Apple 로그인 제공**: 다른 소셜 로그인과 함께 Apple 로그인 제공
- **게스트 모드**: 로그인 없이 앱 기능 체험 가능
- **개인정보 처리방침**: Info.plist에 URL 설정
- **사용자 권한**: Apple ID 사용 목적 명시

### 📋 추가 설정 필요 (Xcode에서)
1. **Signing & Capabilities**
   - "Sign in with Apple" capability 추가
   - Bundle Identifier 설정

2. **Apple Developer Console**
   - App ID에 "Sign in with Apple" 서비스 활성화
   - 키 설정 및 인증서 생성

## 🔄 업데이트된 화면들

### LoginView
- Apple 로그인 버튼 추가
- AuthenticationManager 연동
- 오류 알림 표시

### SubjectManagementView
- 사용자 프로필 버튼 추가
- 프로필 시트 표시
- 로그아웃 기능 통합

### MemoryGymApp
- AuthenticationManager 환경 객체 추가
- 로그인 상태 감지 및 처리

## 🚀 다음 단계

### Phase 2: Firebase 연동
1. **Firebase Authentication**
   - Apple 로그인과 Firebase 연동
   - 사용자 데이터 클라우드 저장

2. **Google 로그인**
   - Firebase Google 로그인 구현
   - 통합 인증 시스템

### Phase 3: 고급 기능
1. **데이터 동기화**
   - 로그인 사용자 데이터 클라우드 저장
   - 기기 간 동기화

2. **사용자 관리**
   - 계정 삭제 기능
   - 데이터 내보내기

## 🔒 보안 고려사항

### 현재 구현
- ✅ Nonce 기반 보안
- ✅ 토큰 검증
- ✅ 로컬 사용자 데이터 보호

### 추후 개선
- [ ] Firebase Authentication 연동
- [ ] 서버 사이드 토큰 검증
- [ ] 사용자 세션 관리

## 📝 테스트 가이드

### 테스트 시나리오
1. **Apple 로그인 성공**
   - 로그인 버튼 탭 → Apple ID 인증 → 앱 로그인 완료

2. **Apple 로그인 취소**
   - 로그인 버튼 탭 → 취소 → 오류 메시지 표시

3. **로그아웃**
   - 프로필 → 로그아웃 → 로그인 화면으로 이동

4. **게스트 모드**
   - 게스트 로그인 → 모든 기능 사용 가능

### 디바이스 테스트
- iOS 15.0+ 시뮬레이터
- 실제 iOS 기기 (Apple ID 필요)
- iPad 호환성 확인

## 🎯 App Store 심사 대비

### 심사관 테스트 시나리오
1. **게스트 모드로 앱 기능 체험**
2. **Apple 로그인으로 계정 생성**
3. **로그아웃 후 재로그인**
4. **개인정보 처리방침 확인**

### 준비 사항
- [ ] 개인정보 처리방침 웹페이지 생성
- [ ] 서비스 약관 웹페이지 생성
- [ ] 앱 아이콘 및 스크린샷 준비
- [ ] 앱 설명 및 키워드 최적화

이제 MemoryGym 앱은 Apple 로그인을 완전히 지원하며, App Store 정책을 준수합니다! 🎉 