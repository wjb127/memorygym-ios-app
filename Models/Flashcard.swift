import Foundation
import FirebaseFirestore

struct Flashcard: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var userId: String
    var subjectId: String
    var front: String  // 앞면 (예: 한국어)
    var back: String   // 뒷면 (예: 영어)
    var createdAt: Timestamp = Timestamp(date: Date())
    var lastStudied: Timestamp?
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var difficulty: Int = 1 // 1: 쉬움, 2: 보통, 3: 어려움
} 