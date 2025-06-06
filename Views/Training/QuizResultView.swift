import SwiftUI

struct QuizResultView: View {
    let flashcard: Flashcard
    let userAnswer: String
    let isCorrect: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 결과 아이콘
            VStack(spacing: 16) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "정답입니다!" : "틀렸습니다")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(isCorrect ? .green : .red)
            }
            
            // 문제와 답
            VStack(spacing: 20) {
                // 문제
                VStack(spacing: 8) {
                    Text("문제")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(flashcard.front)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                
                // 정답
                VStack(spacing: 8) {
                    Text("정답")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(flashcard.back)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }
                
                // 사용자 답안 (틀린 경우만)
                if !isCorrect {
                    VStack(spacing: 8) {
                        Text("내 답안")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(userAnswer.isEmpty ? "(답안 없음)" : userAnswer)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 다음 문제 버튼
            Button("다음 문제") {
                onNext()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
} 