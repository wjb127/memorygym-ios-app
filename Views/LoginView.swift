import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingAlert = false
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [Color.accentPink.opacity(0.1), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // 로고 섹션
                VStack(spacing: 16) {
                    Text("🧠")
                        .font(.system(size: 80))
                    
                    Text("MemoryGym")
                        .font(.largeTitle)
                        .foregroundColor(.textGray)
                    
                    Text("암기훈련소")
                        .font(.headline)
                        .foregroundColor(.textGray.opacity(0.7))
                }
                
                Spacer()
                
                // 로그인 버튼들
                VStack(spacing: 16) {
                    // 게스트 모드 버튼
                    Button(action: {
                        appState.loginAsGuest()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("게스트로 체험하기")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentPink)
                        .cornerRadius(12)
                    }
                    
                    // Apple 로그인 버튼
                    AppleSignInButton {
                        authManager.signInWithApple()
                    }
                    
                    // Google 로그인 버튼
                    Button(action: {
                        authManager.signInWithGoogle()
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Google로 로그인")
                                .font(.headline)
                        }
                        .foregroundColor(.textGray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.lightGray, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // 개인정보 처리방침 링크
                Text("로그인 시 개인정보 처리방침에 동의하게 됩니다.")
                    .font(.caption)
                    .foregroundColor(.textGray.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .alert("로그인 오류", isPresented: $showingAlert) {
            Button("확인", role: .cancel) {
                authManager.authenticationError = nil
            }
        } message: {
            Text(authManager.authenticationError ?? "알 수 없는 오류가 발생했습니다.")
        }
        .onReceive(authManager.$authenticationError) { error in
            if error != nil {
                showingAlert = true
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager())
} 