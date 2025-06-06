import Foundation

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: String
    let email: String?
    let displayName: String
    let isGuest: Bool
    let createdAt: Date
    
    static let guestUser = User(
        id: "guest",
        email: nil,
        displayName: "게스트",
        isGuest: true,
        createdAt: Date()
    )
} 