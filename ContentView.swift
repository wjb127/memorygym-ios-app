import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var selectedTab = 0
    @State private var showingLogin = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단 네비게이션 바
                HStack {
                    // 좌측 X 아이콘
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 20, height: 2)
                            .rotationEffect(.degrees(45))
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 20, height: 2)
                            .rotationEffect(.degrees(-45))
                    }
                    .frame(width: 20, height: 20)
                    
                    Spacer()
                    
                    // 중앙 타이틀
                    Text("암기훈련소")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // 우측 로그인/로그아웃 버튼
                    Button(action: {
                        if authManager.isSignedIn {
                            authManager.signOut()
                        } else {
                            showingLogin = true
                        }
                    }) {
                        Text(authManager.isSignedIn ? "로그아웃" : "로그인")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 1, x: 0, y: 1)
                
                // 사용자 정보 표시 (로그인된 경우)
                if authManager.isSignedIn, let user = authManager.user {
                    HStack {
                        Text("안녕하세요, \(user.displayName ?? user.email ?? "사용자")님!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                }
                
                // 탭 컨텐츠
                TabView(selection: $selectedTab) {
                    TrainingTabView()
                        .tag(0)
                    
                    QuizManagementTabView()
                        .tag(1)
                    
                    StatisticsTabView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // 하단 탭바
                HStack {
                    TabBarButton(title: "암기훈련", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabBarButton(title: "퀴즈관리", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    
                    TabBarButton(title: "통계", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 1, x: 0, y: -1)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .environmentObject(authManager)
    }
}

struct TabBarButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .blue : .gray)
                .frame(maxWidth: .infinity)
        }
    }
}

struct TrainingTabView: View {
    var body: some View {
        VStack {
            Text("암기훈련")
                .font(.largeTitle)
                .padding()
            
            Text("플래시카드 기반 암기 훈련을 시작하세요")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
    }
}

struct QuizManagementTabView: View {
    var body: some View {
        VStack {
            Text("퀴즈관리")
                .font(.largeTitle)
                .padding()
            
            Text("플래시카드를 생성하고 관리하세요")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
    }
}

struct StatisticsTabView: View {
    var body: some View {
        VStack {
            Text("통계")
                .font(.largeTitle)
                .padding()
            
            Text("학습 진도와 성과를 확인하세요")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 