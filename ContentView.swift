import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            if authManager.isSignedIn {
                // 로그인된 상태
                MainView()
            } else {
                // 로그인 화면
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("암기훈련소")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("환영합니다!")
                .font(.title2)
            
            if let user = authManager.user {
                VStack {
                    Text("안녕하세요, \(user.displayName ?? "사용자")님!")
                    if let email = user.email {
                        Text("이메일: \(email)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button("로그아웃") {
                authManager.signOut()
            }
            .foregroundColor(.red)
        }
        .padding()
        .navigationBarHidden(true)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
} 