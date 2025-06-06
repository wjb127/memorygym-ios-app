import Foundation
import FirebaseFirestore

struct Flashcard: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var userId: String
    var subjectId: String
    var front: String          // 앞면 (예: 한국어)
    var back: String           // 뒷면 (예: 영어)
    var adminCard: Bool = false // 관리자 카드 여부
    var boxNumber: Int = 1     // 간격 반복 학습 박스 번호 (1-5)
    var difficulty: Int = 1    // 난이도 (1: 쉬움, 2: 보통, 3: 어려움)
    var reviewCount: Int = 0   // 복습 횟수
    var createdAt: Timestamp = Timestamp(date: Date())
    var lastReviewed: Timestamp = Timestamp(date: Date())
    var nextReview: Timestamp = Timestamp(date: Date())
} 