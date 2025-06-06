import Foundation

// MARK: - Flashcard Model
struct Flashcard: Identifiable, Codable {
    let id: String
    let userId: String
    let subjectId: String
    let front: String  // 문제
    let back: String   // 답
    var boxNumber: Int // 훈련 단계 (1-5)
    var nextReview: Date
    let createdAt: Date
    
    init(id: String = UUID().uuidString, userId: String, subjectId: String, front: String, back: String, boxNumber: Int = 1) {
        self.id = id
        self.userId = userId
        self.subjectId = subjectId
        self.front = front
        self.back = back
        self.boxNumber = boxNumber
        self.nextReview = Date()
        self.createdAt = Date()
    }
    
    // 간격 반복 학습법에 따른 다음 복습 날짜 계산
    mutating func updateNextReview(correct: Bool) {
        if correct {
            // 정답인 경우 다음 단계로 이동
            boxNumber = min(boxNumber + 1, 5)
            let daysToAdd = [1, 3, 7, 14, 30][boxNumber - 1]
            nextReview = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
        } else {
            // 오답인 경우 첫 번째 단계로 이동
            boxNumber = 1
            nextReview = Date()
        }
    }
} 