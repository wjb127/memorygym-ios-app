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
    @StateObject private var subjectService = SubjectService()
    
    @State private var selectedSubject: Subject?
    @State private var showAddEditSubjectSheet = false
    @State private var subjectToEdit: Subject?
    @State private var showLoginSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                VStack {
                    if authManager.isSignedIn {
                        if let user = authManager.user {
                            loggedInView
                                .onAppear {
                                    print("🔍 ContentView - 과목 조회 요청")
                                    print("   ➤ AuthManager.user.id: \(user.id)")
                                    print("   ➤ 이 ID로 subjects 쿼리 실행...")
                                    subjectService.fetchSubjects(forUserID: user.id)
                                }
                        }
                    } else {
                        guestView
                    }
                }
                .navigationTitle("내 과목")
                .toolbar { toolbarContent }
            }
            .sheet(isPresented: $showAddEditSubjectSheet) {
                AddEditSubjectView(subjectToEdit: subjectToEdit, subjectService: subjectService)
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
                    .environmentObject(authManager)
            }

            // 하단 '암기훈련 시작' 버튼
            if authManager.isSignedIn {
                startButton
                    .padding(.bottom, 10)
            }
        }
    }

    // MARK: - Logged-In View
    @ViewBuilder
    private var loggedInView: some View {
        if subjectService.subjects.isEmpty {
            EmptySubjectView {
                subjectToEdit = nil
                showAddEditSubjectSheet = true
            }
        } else {
            List {
                ForEach(subjectService.subjects) { subject in
                    SubjectRowView(subject: subject, selectedSubject: $selectedSubject) {
                        subjectToEdit = subject
                        showAddEditSubjectSheet = true
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    // MARK: - Guest View
    private var guestView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            Text("로그인 필요")
                .font(.title)
                .fontWeight(.bold)
            Text("나만의 과목을 만들고 관리하려면 로그인이 필요해요.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("로그인 하러 가기") {
                showLoginSheet = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if authManager.isSignedIn {
                HStack {
                    Button(action: {
                        subjectToEdit = nil
                        showAddEditSubjectSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                    
                    Menu {
                        if let user = authManager.user {
                            Text(user.displayName ?? "사용자").font(.subheadline)
                        }
                        Button("로그아웃", role: .destructive) {
                            authManager.signOut()
                            selectedSubject = nil
                        }
                    } label: {
                        Image(systemName: "person.circle.fill")
                    }
                }
            } else {
                Button("로그인") {
                    showLoginSheet = true
                }
            }
        }
    }
    
    // MARK: - Start Button
    private var startButton: some View {
        Button(action: {
            // TODO: 암기 훈련 시작 로직
            if let subject = selectedSubject {
                print("\(subject.name) 암기훈련을 시작합니다.")
            }
        }) {
            Text(selectedSubject == nil ? "과목을 선택해주세요" : "암기훈련을 시작합니다")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedSubject == nil ? Color.gray.opacity(0.5) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
        .disabled(selectedSubject == nil)
        .padding(.horizontal)
        .shadow(radius: 5)
    }
}

// MARK: - Helper Views for MemoryTrainingView

private struct EmptySubjectView: View {
    var addAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.7))
            Text("아직 등록된 과목이 없어요")
                .font(.title2)
                .fontWeight(.semibold)
            Text("첫 번째 과목을 추가하고 암기 훈련을 시작해보세요!")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button(action: addAction) {
                Label("첫 과목 추가하기", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SubjectRowView: View {
    let subject: Subject
    @Binding var selectedSubject: Subject?
    var editAction: () -> Void
    
    private var isSelected: Bool {
        subject.id == selectedSubject?.id
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(subject.name)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(subject.description.isEmpty ? "설명 없음" : subject.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("\(subject.cardCount) 카드")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.blue.opacity(0.8)))

            Button(action: editAction) {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelected {
                selectedSubject = nil
            } else {
                selectedSubject = subject
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

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
} 