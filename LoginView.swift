import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 로고 영역
            VStack(spacing: 16) {
                // 덤벨 아이콘 - 스크린샷과 동일한 모티브
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.95, green: 0.38, blue: 0.42))
                
                Text("암기훈련소")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("MemoryGym")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.95, green: 0.38, blue: 0.42))
                
                Text("효과적인 암기 학습을 시작하세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // 로그인 버튼들
            VStack(spacing: 16) {
                // Google 로그인 버튼
                Button(action: {
                    authManager.signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.white)
                        Text("Google로 로그인")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.98, green: 0.35, blue: 0.45),
                                Color(red: 0.95, green: 0.38, blue: 0.42)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
                .disabled(authManager.isLoading)
                
                // Apple 로그인 버튼
                Button(action: {
                    authManager.signInWithApple()
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .foregroundColor(.white)
                        Text("Apple로 로그인")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.2, blue: 0.2),
                                Color.black
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
                .disabled(authManager.isLoading)
            }
            .padding(.horizontal, 40)
            
            // 오류 메시지
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // 로딩 인디케이터
            if authManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.95, green: 0.38, blue: 0.42)))
                    .scaleEffect(1.2)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
} 