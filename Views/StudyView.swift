import SwiftUI

struct StudyView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentCardIndex = 0
    @State private var showAnswer = false
    @State private var reviewCards: [Flashcard] = []
    @State private var studyCompleted = false
    
    var body: some View {
        NavigationView {
            VStack {
                if studyCompleted {
                    // 학습 완료 화면
                    StudyCompletedView {
                        resetStudy()
                    }
                } else if reviewCards.isEmpty {
                    // 복습할 카드가 없는 경우
                    NoCardsView()
                } else {
                    // 플래시카드 학습 화면
                    VStack(spacing: 24) {
                        // 진행률 표시
                        ProgressView(value: Double(currentCardIndex), total: Double(reviewCards.count))
                            .progressViewStyle(LinearProgressViewStyle(tint: .accentPink))
                            .padding(.horizontal)
                        
                        Text("\(currentCardIndex + 1) / \(reviewCards.count)")
                            .font(.caption)
                            .foregroundColor(.textGray)
                        
                        Spacer()
                        
                        // 플래시카드
                        FlashcardView(
                            card: reviewCards[currentCardIndex],
                            showAnswer: showAnswer
                        ) {
                            withAnimation(.spring()) {
                                showAnswer.toggle()
                            }
                        }
                        
                        Spacer()
                        
                        // 답변 버튼들
                        if showAnswer {
                            HStack(spacing: 16) {
                                Button("틀렸음") {
                                    answerCard(correct: false)
                                }
                                .buttonStyle(AnswerButtonStyle(isCorrect: false))
                                
                                Button("맞았음") {
                                    answerCard(correct: true)
                                }
                                .buttonStyle(AnswerButtonStyle(isCorrect: true))
                            }
                        } else {
                            Button("답 보기") {
                                withAnimation(.spring()) {
                                    showAnswer = true
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("암기훈련")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadReviewCards()
            }
        }
    }
    
    private func loadReviewCards() {
        guard let currentSubject = dataManager.currentSubject else { return }
        reviewCards = dataManager.getFlashcardsForReview(subjectId: currentSubject.id)
        currentCardIndex = 0
        showAnswer = false
        studyCompleted = false
    }
    
    private func answerCard(correct: Bool) {
        var card = reviewCards[currentCardIndex]
        card.updateNextReview(correct: correct)
        dataManager.updateFlashcard(card)
        
        withAnimation(.easeInOut) {
            if currentCardIndex < reviewCards.count - 1 {
                currentCardIndex += 1
                showAnswer = false
            } else {
                studyCompleted = true
            }
        }
    }
    
    private func resetStudy() {
        loadReviewCards()
    }
}

// MARK: - Supporting Views
struct NoCardsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("복습할 카드가 없습니다!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("모든 카드를 완료했거나\n새로운 카드를 추가해보세요.")
                .font(.body)
                .foregroundColor(.textGray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct StudyCompletedView: View {
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentPink)
            
            Text("학습 완료!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("오늘의 복습을 모두 완료했습니다.\n내일 다시 만나요!")
                .font(.body)
                .foregroundColor(.textGray)
                .multilineTextAlignment(.center)
            
            Button("다시 시작") {
                onRestart()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentPink)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct AnswerButtonStyle: ButtonStyle {
    let isCorrect: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isCorrect ? Color.green : Color.red)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    StudyView()
        .environmentObject(DataManager())
} 