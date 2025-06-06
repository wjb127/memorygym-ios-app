import SwiftUI

struct TrainingResultView: View {
    let subject: Subject
    let difficulty: Int
    let totalQuestions: Int
    let correctAnswers: Int
    let onClose: () -> Void
    
    private var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    private var grade: String {
        switch accuracy {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B+"
        case 60..<70: return "B"
        case 50..<60: return "C"
        default: return "F"
        }
    }
    
    private var gradeColor: Color {
        switch accuracy {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .cyan
        case 60..<70: return .orange
        case 50..<60: return .yellow
        default: return .red
        }
    }
    
    private var encouragement: String {
        switch accuracy {
        case 90...100: return "완벽해요! 🎉"
        case 80..<90: return "훌륭합니다! 👏"
        case 70..<80: return "잘했어요! 💪"
        case 60..<70: return "좋은 시작이에요! 📚"
        case 50..<60: return "조금 더 화이팅! 🔥"
        default: return "다시 도전해보세요! 💪"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 완료 아이콘
                Image(systemName: "flag.checkered")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                // 제목
                VStack(spacing: 8) {
                    Text("훈련 완료!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text(subject.name)
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Lv\(difficulty) 훈련소")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 결과 카드
                VStack(spacing: 20) {
                    // 정답률
                    VStack(spacing: 12) {
                        Text("정답률")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f%%", accuracy))
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(gradeColor)
                        
                        Text(grade)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(gradeColor)
                    }
                    
                    // 상세 결과
                    VStack(spacing: 8) {
                        HStack {
                            Text("총 문제 수")
                            Spacer()
                            Text("\(totalQuestions)문제")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("정답 수")
                            Spacer()
                            Text("\(correctAnswers)문제")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("오답 수")
                            Spacer()
                            Text("\(totalQuestions - correctAnswers)문제")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // 격려 메시지
                Text(encouragement)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(gradeColor)
                
                Spacer()
                
                // 완료 버튼
                Button("완료") {
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("훈련 결과")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        onClose()
                    }
                }
            }
        }
    }
} 