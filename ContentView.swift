import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        TabView {
            MemoryTrainingView()
                .tabItem {
                    Label("암기훈련", systemImage: "brain.head.profile")
                }
            
            QuizManagementView()
                .tabItem {
                    Label("퀴즈관리", systemImage: "questionmark.diamond")
                }

            StatisticsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar.xaxis")
                }
        }
    }
}

// MARK: - 탭별 뷰

/// 1. 암기훈련 탭
struct MemoryTrainingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showLoginSheet = false

    var body: some View {
        NavigationView {
            MainContentView(showLoginSheet: $showLoginSheet)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if authManager.isSignedIn {
                            // 로그인된 상태 - 프로필 버튼
                            Menu {
                                if let user = authManager.user {
                                    VStack {
                                        Text(user.displayName ?? "사용자")
                                        if let email = user.email {
                                            Text(email)
                                                .font(.caption)
                                        }
                                    }
                                }
                                
                                Button("로그아웃", role: .destructive) {
                                    authManager.signOut()
                                }
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        } else {
                            // 게스트 모드 - 로그인 버튼
                            Button("로그인") {
                                showLoginSheet = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showLoginSheet) {
                    LoginView()
                        .environmentObject(authManager)
                }
        }
    }
}

/// 2. 퀴즈관리 탭 (플레이스홀더)
struct QuizManagementView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("퀴즈 관리")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("이 곳에서 나만의 퀴즈를 만들고 관리할 수 있습니다.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("퀴즈관리")
        }
    }
}

/// 3. 통계 탭 (플레이스홀더)
struct StatisticsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("학습 통계")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("학습 진행 상황과 성과를 확인할 수 있습니다.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("통계")
        }
    }
}

// 기존 MainView의 이름을 MainContentView로 변경하여 재사용
struct MainContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var showLoginSheet: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 헤더 섹션
                VStack(spacing: 10) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("암기훈련소")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if authManager.isSignedIn {
                        if let user = authManager.user {
                            Text("안녕하세요, \(user.displayName ?? "사용자")님! 👋")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    } else {
                        Text("게스트 모드로 체험해보세요! 📚")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 20)
                
                // 기능 카드들
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    
                    FeatureCard(
                        icon: "brain.head.profile",
                        title: "단어 암기",
                        description: "영어 단어를 효과적으로 암기하세요",
                        color: .blue,
                        isLocked: false
                    )
                    
                    FeatureCard(
                        icon: "book.fill",
                        title: "문장 학습",
                        description: "실제 문장으로 학습하세요",
                        color: .green,
                        isLocked: !authManager.isSignedIn
                    )
                    
                    FeatureCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "학습 통계",
                        description: "학습 진도를 확인하세요",
                        color: .orange,
                        isLocked: !authManager.isSignedIn
                    )
                    
                    FeatureCard(
                        icon: "person.2.fill",
                        title: "친구와 경쟁",
                        description: "친구들과 학습 경쟁하세요",
                        color: .purple,
                        isLocked: !authManager.isSignedIn
                    )
                }
                .padding(.horizontal)
                
                // 게스트 모드 안내
                if !authManager.isSignedIn {
                    VStack(spacing: 15) {
                        Text("🔒 더 많은 기능을 원하시나요?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("로그인하면 모든 기능을 사용하고\n학습 진도를 저장할 수 있어요!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("지금 로그인하기") {
                            showLoginSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("암기훈련")
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isLocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.black.opacity(0.7)).frame(width: 20, height: 20))
                        .offset(x: 15, y: -15)
                }
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isLocked ? .gray : .primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(height: 130)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .opacity(isLocked ? 0.7 : 1.0)
        .onTapGesture {
            if isLocked {
                // 로그인 필요 알림
                print("로그인이 필요한 기능입니다")
            } else {
                // 기능 실행
                print("\(title) 기능 실행")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
} 