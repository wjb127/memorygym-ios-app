import SwiftUI

struct QuizResultView: View {
    let flashcard: Flashcard
    let userAnswer: String
    let isCorrect: Bool
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    gradient: Gradient(colors: isCorrect ? 
                        [Color.green.opacity(0.1), Color.green.opacity(0.05)] :
                        [Color.red.opacity(0.1), Color.red.opacity(0.05)]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 결과 섹션
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // 결과 아이콘과 텍스트
                        VStack(spacing: 16) {
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(isCorrect ? .green : .red)
                                .scaleEffect(1.0)
                                .animation(.bouncy(duration: 0.8), value: isCorrect)
                            
                            Text(isCorrect ? "정답입니다!" : "틀렸습니다")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(isCorrect ? .green : .red)
                        }
                        
                        Spacer()
                    }
                    .frame(height: geometry.size.height * 0.4)
                    
                    // 하단 정보 섹션
                    VStack(spacing: 0) {
                        // 정보 카드들
                        VStack(spacing: 16) {
                            // 문제 카드
                            InfoCard(
                                title: "문제",
                                content: flashcard.front,
                                backgroundColor: Color(.systemBlue).opacity(0.1),
                                borderColor: Color.blue
                            )
                            
                            // 정답 카드
                            InfoCard(
                                title: "정답",
                                content: flashcard.back,
                                backgroundColor: Color.green.opacity(0.1),
                                borderColor: Color.green
                            )
                            
                            // 사용자 답안 카드 (틀린 경우만)
                            if !isCorrect {
                                InfoCard(
                                    title: "내 답안",
                                    content: userAnswer.isEmpty ? "(답안 없음)" : userAnswer,
                                    backgroundColor: Color.red.opacity(0.1),
                                    borderColor: Color.red
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        Spacer()
                        
                        // 다음 문제 버튼
                        Button(action: onNext) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                Text("다음 문제")
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
                    .frame(height: geometry.size.height * 0.6)
                    .background(
                        Color(.systemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
                    )
                }
            }
        }
    }
}

// MARK: - Info Card Component
private struct InfoCard: View {
    let title: String
    let content: String
    let backgroundColor: Color
    let borderColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // 제목
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(borderColor)
                Spacer()
            }
            
            // 내용
            HStack {
                Text(content)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                Spacer()
            }
        }
        .padding(20)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(16)
    }
} 