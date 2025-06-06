import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 사용자 정보
            VStack(spacing: 8) {
                // 프로필 이미지 (임시)
                Circle()
                    .fill(Color.accentPink.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(appState.currentUser?.displayName.prefix(1) ?? "?"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.accentPink)
                    )
                
                Text(appState.currentUser?.displayName ?? "사용자")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let email = appState.currentUser?.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 사용자 타입 표시
                HStack {
                    Image(systemName: appState.isGuestMode ? "person.fill" : "checkmark.seal.fill")
                        .foregroundColor(appState.isGuestMode ? .orange : .green)
                    Text(appState.isGuestMode ? "게스트 모드" : "로그인 사용자")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Divider()
            
            // 로그아웃 버튼
            Button(action: {
                showingLogoutAlert = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("로그아웃")
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .alert("로그아웃", isPresented: $showingLogoutAlert) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                logout()
            }
        } message: {
            Text("정말 로그아웃하시겠습니까?")
        }
    }
    
    private func logout() {
        authManager.signOut()
        appState.logout()
    }
}

#Preview {
    UserProfileView()
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager())
} 