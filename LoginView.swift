import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // 로고 및 제목
            VStack(spacing: 16) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("암기훈련소")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("소셜 계정으로 로그인하세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)
            
            // 로그인 버튼들
            VStack(spacing: 16) {
                // Google 로그인 버튼
                Button(action: {
                    authManager.signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 20))
                        
                        Text("Google로 로그인")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
                .disabled(authManager.isLoading)
                
                // Apple 로그인 버튼
                SignInWithAppleButton(
                    onRequest: { request in
                        // AuthenticationManager에서 처리하므로 여기서는 비워둠
                    },
                    onCompletion: { result in
                        // AuthenticationManager에서 처리하므로 여기서는 비워둠
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)
                .onTapGesture {
                    authManager.signInWithApple()
                }
                .disabled(authManager.isLoading)
            }
            .padding(.horizontal, 40)
            
            // 에러 메시지
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
        .overlay(
            // 닫기 버튼
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .padding(),
            alignment: .topTrailing
        )
        .overlay(
            // 로딩 인디케이터
            Group {
                if authManager.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text("로그인 중...")
                                .foregroundColor(.white)
                                .padding(.top, 8)
                        }
                    }
                }
            }
        )
        .onChange(of: authManager.isSignedIn) { isSignedIn in
            if isSignedIn {
                dismiss()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationManager())
    }
} 