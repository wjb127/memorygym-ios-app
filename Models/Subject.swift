import Foundation
import FirebaseFirestore

struct Subject: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var userId: String
    var cardCount: Int = 0
    var createdAt: Timestamp = Timestamp(date: Date())
    var lastStudied: Timestamp?
} 