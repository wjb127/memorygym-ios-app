import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.showSplash {
                SplashView()
            } else {
                MainAppView()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.showSplash)
    }
}

// MARK: - Splash View
struct SplashView: View {
    var body: some View {
        ZStack {
            Color.accentColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("암기훈련소")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("당신의 두뇌를 위한 최고의 트레이닝")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Main App View
struct MainAppView: View {
    @State private var selectedTab: Tab = .training
    @EnvironmentObject var appState: AppState
    
    enum Tab: CaseIterable {
        case training, quiz, statistics
        
        var title: String {
            switch self {
            case .training: return "암기훈련"
            case .quiz: return "퀴즈관리"
            case .statistics: return "통계"
            }
        }
        
        var icon: String {
            switch self {
            case .training: return "brain.head.profile"
            case .quiz: return "questionmark.circle"
            case .statistics: return "chart.bar"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                // 좌측 아이콘 (X 모양 디자인)
                HStack(spacing: 4) {
                    // X 모양 아이콘을 두 개의 선으로 구현
                    ZStack {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 20, height: 3)
                            .rotationEffect(.degrees(45))
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 20, height: 3)
                            .rotationEffect(.degrees(-45))
                    }
                    .frame(width: 24, height: 24)
                }
                
                Text("암기훈련소")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("로그인") {
                    // 로그인 액션
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .padding()
            .background(Color.white)
            
            // Subtitle
            HStack {
                Text("당신의 두뇌를 위한 최고의 트레이닝")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            // Tab Bar
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Button(action: {
                                selectedTab = tab
                            }) {
                                VStack(spacing: 4) {
                                    Text(tab.title)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(selectedTab == tab ? .red : .gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .background(Color.white)
                    
                    // Tab indicator
                    HStack {
                        if selectedTab == .training {
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 2)
                            Spacer()
                            Spacer()
                        } else if selectedTab == .quiz {
                            Spacer()
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 2)
                            Spacer()
                        } else {
                            Spacer()
                            Spacer()
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 2)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
            }
            .frame(height: 50)
            
            // Content Area
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                // 선택된 탭에 따른 콘텐츠 표시
                switch selectedTab {
                case .training:
                    TrainingTabView()
                case .quiz:
                    QuizManagementTabView()
                case .statistics:
                    StatisticsTabView()
                }
            }
            
            Spacer()
        }
        .background(Color.white)
    }
}

// MARK: - Tab Content Views
struct TrainingTabView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Main Content Card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("두뇌 훈련하기")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("학습할 과목 선택")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    // Subject Selector
                    HStack {
                        Text("중급 영단어 (체험판)")
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red, lineWidth: 1)
                    )
                    
                    // Start Button
                    Button("로그인 후 이용 가능") {
                        // 로그인 액션
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.gray)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}

struct QuizManagementTabView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("퀴즈 관리")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Text("퀴즈 기능은 준비 중입니다.")
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}

struct StatisticsTabView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("학습 통계")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                Text("통계 기능은 준비 중입니다.")
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
} 