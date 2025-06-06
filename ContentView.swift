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
    @State private var hasPerformedInitialSync = false

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                VStack(spacing: 0) {
                    // 상단 헤더 (내 과목 + 버튼들)
                    if authManager.isSignedIn {
                        headerView
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    
                    // 메인 콘텐츠
                    if authManager.isSignedIn {
                        if let user = authManager.user {
                            loggedInView
                                .onAppear {
                                    print("🔍 ContentView - 과목 조회 요청")
                                    print("   ➤ AuthManager.user.id: \(user.id)")
                                    print("   ➤ 이 ID로 subjects 쿼리 실행...")
                                    subjectService.fetchSubjects(forUserID: user.id)
                                    
                                    // 한 번만 cardCount 동기화 실행
                                    if !hasPerformedInitialSync {
                                        hasPerformedInitialSync = true
                                        Task {
                                            do {
                                                try await subjectService.syncAllSubjectCardCounts(forUserID: user.id)
                                            } catch {
                                                print("❌ cardCount 동기화 실패: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }
                        }
                    } else {
                        guestView
                    }
                }
                .navigationBarHidden(authManager.isSignedIn) // 로그인 시 네비게이션 바 숨김
                .toolbar {
                    // 게스트 모드일 때만 툴바 표시
                    if !authManager.isSignedIn {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("로그인") {
                                showLoginSheet = true
                            }
                        }
                    }
                }
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
        .onChange(of: authManager.isSignedIn) { isSignedIn in
            // 로그아웃 시 동기화 플래그 리셋
            if !isSignedIn {
                hasPerformedInitialSync = false
                selectedSubject = nil
            }
        }
    }

    // MARK: - Header View (내 과목 + 버튼들)
    @ViewBuilder
    private var headerView: some View {
        HStack {
            Text("내 과목")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            // 과목 추가 버튼
            Button(action: {
                subjectToEdit = nil
                showAddEditSubjectSheet = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // 프로필 메뉴
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
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.bottom, 12)
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
            Spacer()
            
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.7))
            Text("아직 등록된 과목이 없어요")
                .font(.title2)
                .fontWeight(.semibold)
            Text("첫 번째 과목을 추가하고 암기 훈련을 시작해보세요!")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: addAction) {
                Label("첫 과목 추가하기", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top)
            
            Spacer()
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

/// 2. 퀴즈관리 탭
struct QuizManagementView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var subjectService = SubjectService()
    @StateObject private var flashcardService = FlashcardService()
    
    @State private var selectedSubject: Subject?
    @State private var showAddEditFlashcardSheet = false
    @State private var flashcardToEdit: Flashcard?
    @State private var showLoginSheet = false
    @State private var showFlashcardActionSheet = false
    @State private var selectedFlashcard: Flashcard?
    
    var body: some View {
        NavigationView {
            VStack {
                if authManager.isSignedIn {
                    if let user = authManager.user {
                        loggedInContent
                            .onAppear {
                                subjectService.fetchSubjects(forUserID: user.id)
                            }
                    }
                } else {
                    guestContent
                }
            }
            .navigationTitle("퀴즈관리")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if authManager.isSignedIn {
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
                    } else {
                        Button("로그인") {
                            showLoginSheet = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddEditFlashcardSheet) {
                if let subjectID = selectedSubject?.id {
                    AddEditFlashcardView(
                        flashcardToEdit: flashcardToEdit,
                        subjectID: subjectID,
                        flashcardService: flashcardService
                    )
                    .environmentObject(authManager)
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
                    .environmentObject(authManager)
            }
            .confirmationDialog("퀴즈 옵션", isPresented: $showFlashcardActionSheet, presenting: selectedFlashcard) { flashcard in
                Button("수정") {
                    flashcardToEdit = flashcard
                    showAddEditFlashcardSheet = true
                }
                Button("삭제", role: .destructive) {
                    deleteFlashcard(flashcard)
                }
                Button("취소", role: .cancel) { }
            } message: { flashcard in
                Text("'\(flashcard.front)' 퀴즈를 어떻게 하시겠습니까?")
            }
        }
    }
    
    // MARK: - Logged-In Content
    @ViewBuilder
    private var loggedInContent: some View {
        VStack(spacing: 20) {
            // 과목 선택 드롭다운
            subjectSelectionView
            
            if let selectedSubject = selectedSubject {
                // 선택된 과목의 플래시카드 목록
                flashcardListView
            } else {
                // 과목 미선택 상태
                emptySelectionView
            }
        }
        .padding()
    }
    
    // MARK: - 과목 선택 드롭다운
    @ViewBuilder
    private var subjectSelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("과목 선택")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if selectedSubject != nil {
                    Button(action: {
                        flashcardToEdit = nil
                        showAddEditFlashcardSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if subjectService.subjects.isEmpty {
                Text("등록된 과목이 없습니다. 암기훈련 탭에서 과목을 먼저 추가해주세요.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Menu {
                    Button("과목 선택 해제") {
                        selectedSubject = nil
                    }
                    
                    ForEach(subjectService.subjects) { subject in
                        Button(action: {
                            selectedSubject = subject
                            // 선택된 과목의 플래시카드 조회
                            if let user = authManager.user {
                                flashcardService.fetchFlashcards(
                                    forSubjectID: subject.id ?? "",
                                    userID: user.id
                                )
                            }
                        }) {
                            HStack {
                                Text(subject.name)
                                Spacer()
                                Text("\(subject.cardCount)문제")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedSubject?.name ?? "과목을 선택하세요")
                            .foregroundColor(selectedSubject == nil ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - 플래시카드 목록
    @ViewBuilder
    private var flashcardListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(selectedSubject?.name ?? "과목") 퀴즈")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(flashcardService.flashcards.count)문제")
                    .foregroundColor(.secondary)
            }
            
            if flashcardService.flashcards.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("아직 퀴즈가 없습니다")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("첫 번째 퀴즈를 추가해보세요!")
                        .foregroundColor(.secondary)
                    Button(action: {
                        flashcardToEdit = nil
                        showAddEditFlashcardSheet = true
                    }) {
                        Label("퀴즈 추가", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(flashcardService.flashcards) { flashcard in
                        FlashcardRowView(flashcard: flashcard) {
                            selectedFlashcard = flashcard
                            showFlashcardActionSheet = true
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    // MARK: - 과목 미선택 상태
    @ViewBuilder
    private var emptySelectionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.diamond")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("과목을 선택해주세요")
                .font(.title2)
                .fontWeight(.semibold)
            Text("위의 드롭다운에서 관리할 과목을 선택하면\n해당 과목의 퀴즈들을 확인하고 편집할 수 있습니다.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Guest Content
    private var guestContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            Text("로그인 필요")
                .font(.title)
                .fontWeight(.bold)
            Text("퀴즈를 관리하려면 로그인이 필요해요.")
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
    
    // MARK: - Helper Methods
    private func deleteFlashcard(_ flashcard: Flashcard) {
        Task {
            do {
                try await flashcardService.deleteFlashcard(flashcard)
                print("✅ 퀴즈 삭제 완료: \(flashcard.front)")
            } catch {
                print("❌ 퀴즈 삭제 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - FlashcardRowView
private struct FlashcardRowView: View {
    let flashcard: Flashcard
    var editAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 카드 내용
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(flashcard.front)
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                    difficultyBadge
                }
                
                Text(flashcard.back)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Label("\(flashcard.reviewCount)", systemImage: "repeat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("박스 \(flashcard.boxNumber)", systemImage: "archivebox")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 편집 버튼
            Button(action: editAction) {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private var difficultyBadge: some View {
        let (text, color) = difficultyInfo
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(color))
    }
    
    private var difficultyInfo: (String, Color) {
        switch flashcard.difficulty {
        case 1: return ("쉬움", .green)
        case 2: return ("보통", .orange)
        case 3: return ("어려움", .red)
        default: return ("보통", .gray)
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