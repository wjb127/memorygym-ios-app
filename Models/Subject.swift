import Foundation

// MARK: - Subject Model
struct Subject: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let description: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, userId: String, name: String, description: String? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.createdAt = Date()
    }
} 