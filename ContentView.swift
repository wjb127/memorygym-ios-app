import SwiftUI
import Foundation

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
            
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
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
    @State private var showTrainingLevelSheet = false

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
                .navigationTitle(authManager.isSignedIn ? "" : "암기훈련소")
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
            if selectedSubject != nil {
                showTrainingLevelSheet = true
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
        .sheet(isPresented: $showTrainingLevelSheet) {
            if let subject = selectedSubject {
                TrainingLevelSelectionView(subject: subject)
                    .environmentObject(authManager)
            }
        }
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
        case 1: return ("Lv1", .red)        // 학습 초기 단계 (많은 반복 필요)
        case 2: return ("Lv2", .orange)     // 학습 진행 중
        case 3: return ("Lv3", .yellow)     // 학습 중간 단계
        case 4: return ("Lv4", .mint)       // 학습 완료 직전
        case 5: return ("Lv5", .green)      // 학습 완료 단계 (장기 기억)
        default: return ("Lv1", .gray)
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

/// 4. 설정 탭
struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showLoginSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if authManager.isSignedIn {
                    loggedInSettingsView
                } else {
                    guestSettingsView
                }
            }
            .navigationTitle("설정")
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
                .environmentObject(authManager)
        }
    }
    
    // MARK: - Logged-In Settings
    @ViewBuilder
    private var loggedInSettingsView: some View {
        List {
            // 프로필 섹션
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authManager.user?.displayName ?? "사용자")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text(authManager.user?.email ?? "이메일 없음")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            // 앱 정보 섹션
            Section("앱 정보") {
                SettingsRowView(icon: "info.circle", title: "버전", detail: "1.0.0")
                SettingsRowView(icon: "envelope", title: "문의하기", detail: nil) {
                    // TODO: 문의하기 기능
                }
                SettingsRowView(icon: "star", title: "앱 평가하기", detail: nil) {
                    // TODO: 앱 평가 기능
                }
            }
            
            // 로그아웃 섹션
            Section {
                Button(action: {
                    authManager.signOut()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("로그아웃")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Guest Settings
    @ViewBuilder
    private var guestSettingsView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("로그인 필요")
                .font(.title)
                .fontWeight(.bold)
            
            Text("모든 기능을 사용하려면 로그인이 필요합니다.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("로그인 하러 가기") {
                showLoginSheet = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Settings Row View
private struct SettingsRowView: View {
    let icon: String
    let title: String
    let detail: String?
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let detail = detail {
                    Text(detail)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .disabled(action == nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}

// MARK: - Training Level Selection View
struct TrainingLevelSelectionView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var flashcardService = FlashcardService()
    
    let subject: Subject
    @State private var selectedLevel: Int = 1
    @State private var showTrainingView = false
    @State private var flashcardCounts = [Int: Int]() // 단계별 플래시카드 개수
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 헤더
                VStack(spacing: 8) {
                    Text("훈련 단계 선택")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(subject.name)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("원하는 단계의 훈련소를 선택하세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                // 단계 선택 리스트
                VStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { level in
                        TrainingLevelRow(
                            level: level,
                            isSelected: selectedLevel == level,
                            cardCount: flashcardCounts[level] ?? 0
                        ) {
                            selectedLevel = level
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 시작 버튼
                Button(action: {
                    startTraining(level: selectedLevel)
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("\(selectedLevel)단계 훈련 시작")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadFlashcardsAndCalculateCounts()
            }
        }
        .fullScreenCover(isPresented: $showTrainingView) {
            TrainingView(subject: subject, difficulty: selectedLevel)
                .environmentObject(authManager)
        }
    }
    
    private func startTraining(level: Int) {
        print("🎯 \(subject.name) - \(level)단계 훈련 시작!")
        print("   ➤ 학습 단계 \(level) 플래시카드로 훈련 진행")
        showTrainingView = true
    }
    
    private func loadFlashcardsAndCalculateCounts() {
        guard let user = authManager.user,
              let subjectId = subject.id else { return }
        
        // 해당 과목의 모든 플래시카드 조회
        flashcardService.fetchFlashcards(forSubjectID: subjectId, userID: user.id)
        
        // 단계별 개수 계산
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var counts = [Int: Int]()
            
            for level in 1...5 {
                let count = flashcardService.flashcards.filter { $0.difficulty == level }.count
                counts[level] = count
            }
            
            flashcardCounts = counts
            print("📊 단계별 플래시카드 개수: \(flashcardCounts)")
        }
    }
}

// MARK: - Training Level Row
private struct TrainingLevelRow: View {
    let level: Int
    let isSelected: Bool
    let cardCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lv\(level) 훈련소")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(levelDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("\(cardCount)문제")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    difficultyBadge
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var levelDescription: String {
        switch level {
        case 1: return "Lv1 문제들 (학습 초기 단계)"
        case 2: return "Lv2 문제들 (학습 진행 중)"
        case 3: return "Lv3 문제들 (학습 중간 단계)"
        case 4: return "Lv4 문제들 (학습 완료 직전)"
        case 5: return "Lv5 문제들 (학습 완료 단계)"
        default: return "일반 문제"
        }
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
        switch level {
        case 1: return ("Lv1", .red)        // 학습 초기 단계 (많은 반복 필요)
        case 2: return ("Lv2", .orange)     // 학습 진행 중
        case 3: return ("Lv3", .yellow)     // 학습 중간 단계
        case 4: return ("Lv4", .mint)       // 학습 완료 직전
        case 5: return ("Lv5", .green)      // 학습 완료 단계 (장기 기억)
        default: return ("Lv1", .gray)
        }
    }
} 