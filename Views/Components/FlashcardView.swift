import SwiftUI

struct FlashcardView: View {
    let card: Flashcard
    let showAnswer: Bool
    let onTap: () -> Void
    
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 16) {
                // 카드 타입 표시
                HStack {
                    Text(showAnswer ? "답" : "문제")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // 박스 번호 표시
                    Text("Box \(card.boxNumber)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentPink)
                        .cornerRadius(6)
                }
                
                Spacer()
                
                // 카드 내용
                Text(showAnswer ? card.back : card.front)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textGray)
                    .padding()
                
                Spacer()
                
                // 탭 힌트
                if !showAnswer {
                    Text("탭하여 답 보기")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(20)
        }
        .frame(height: 300)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
                onTap()
            }
        }
        .onChange(of: showAnswer) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped = showAnswer
            }
        }
    }
}

#Preview {
    FlashcardView(
        card: Flashcard(
            userId: "test",
            subjectId: "test",
            front: "accomplish",
            back: "성취하다, 완수하다"
        ),
        showAnswer: false
    ) {
        // Preview action
    }
    .padding()
} 