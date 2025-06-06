import SwiftUI
import FirebaseFirestore

struct TrainingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    let subject: Subject
    let difficulty: Int
    
    @StateObject private var flashcardService = FlashcardService()
    @State private var trainingFlashcards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var userAnswer = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var isLoading = true
    @State private var correctAnswers = 0
    @State private var showFinalResult = false
    
    var currentFlashcard: Flashcard? {
        guard currentIndex < trainingFlashcards.count else { return nil }
        return trainingFlashcards[currentIndex]
    }
    
    var progress: Double {
        guard !trainingFlashcards.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(trainingFlashcards.count)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    loadingView
                } else if trainingFlashcards.isEmpty {
                    emptyView
                } else if showFinalResult {
                    TrainingResultView(
                        subject: subject,
                        difficulty: difficulty,
                        totalQuestions: trainingFlashcards.count,
                        correctAnswers: correctAnswers
                    ) {
                        dismiss()
                    }
                } else {
                    // 진행 바
                    progressBar
                    
                    if showResult {
                        // 정답 결과 화면
                        QuizResultView(
                            flashcard: currentFlashcard!,
                            userAnswer: userAnswer,
                            isCorrect: isCorrect
                        ) {
                            nextQuestion()
                        }
                    } else {
                        // 문제 화면
                        quizView
                    }
                }
            }
            .navigationTitle("Lv\(difficulty) 훈련소")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("종료") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadFlashcards()
        }
        .sheet(isPresented: $showFinalResult) {
            TrainingResultView(
                subject: subject,
                difficulty: difficulty,
                totalQuestions: trainingFlashcards.count,
                correctAnswers: correctAnswers
            ) {
                dismiss()
            }
        }
    }
    
    // MARK: - 로딩 뷰
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("문제를 불러오는 중...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 문제 없음 뷰
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.diamond")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("훈련할 문제가 없습니다")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Lv\(difficulty) 문제가 없어요.\n다른 레벨을 선택해주세요.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("닫기") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 진행 바
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("문제 \(currentIndex + 1)/\(trainingFlashcards.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("정답률 \(correctAnswers)/\(currentIndex + (showResult ? 1 : 0))")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    // MARK: - 퀴즈 뷰
    private var quizView: some View {
        VStack(spacing: 0) {
            // 문제 영역
            VStack(spacing: 30) {
                Spacer()
                
                // 문제
                VStack(spacing: 16) {
                    Text("문제")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(currentFlashcard?.front ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // 답 입력
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("답안 입력")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("정답을 입력하세요", text: $userAnswer)
                            .textFieldStyle(.roundedBorder)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .submitLabel(.done)
                            .onSubmit {
                                checkAnswer()
                            }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            // 하단 고정 버튼 (QuizResultView와 동일한 위치)
            Button(action: checkAnswer) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    Text("정답 확인")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - 헬퍼 메서드
    private func loadFlashcards() {
        guard let user = authManager.user,
              let subjectID = subject.id else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let flashcards = try await flashcardService.fetchFlashcardsForTraining(
                    subjectID: subjectID,
                    userID: user.id,
                    difficulty: difficulty
                )
                
                await MainActor.run {
                    self.trainingFlashcards = flashcards.shuffled() // 문제 순서 랜덤화
                    self.isLoading = false
                    print("🎯 훈련 시작: \(flashcards.count)개 문제 로드")
                }
            } catch {
                await MainActor.run {
                    print("❌ 플래시카드 로드 실패: \(error)")
                    self.isLoading = false
                }
            }
        }
    }
    
    private func checkAnswer() {
        guard let flashcard = currentFlashcard else { return }
        
        let trimmedUserAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCorrectAnswer = flashcard.back.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 대소문자 구분 없이 비교
        isCorrect = trimmedUserAnswer.lowercased() == trimmedCorrectAnswer.lowercased()
        
        if isCorrect {
            correctAnswers += 1
        }
        
        showResult = true
        
        // 플래시카드 난이도 업데이트
        Task {
            do {
                try await flashcardService.updateFlashcardDifficulty(
                    flashcardID: flashcard.id ?? "",
                    isCorrect: isCorrect
                )
            } catch {
                print("❌ 난이도 업데이트 실패: \(error)")
            }
        }
    }
    
    private func nextQuestion() {
        currentIndex += 1
        userAnswer = ""
        showResult = false
        
        if currentIndex >= trainingFlashcards.count {
            // 모든 문제 완료
            showFinalResult = true
        }
    }
} 