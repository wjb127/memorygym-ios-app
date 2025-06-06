import Foundation
import FirebaseFirestore
import FirebaseAuth

// Users 컬렉션의 사용자 문서 모델
struct AppUserDocument: Codable {
    @DocumentID var id: String?
    var email: String?
    var fullName: String?
    var avatarUrl: String?
    var createdAt: Timestamp
    var updatedAt: Timestamp
    var premium: Bool = false
    var premiumUntil: Timestamp?
    var username: String?
}

@MainActor
class UserService: ObservableObject {
    private let db = Firestore.firestore()
    private var usersCollectionRef: CollectionReference {
        return db.collection("users")
    }
    
    /// 로그인 시 사용자 정보를 users 컬렉션에 생성 또는 업데이트
    func createOrUpdateUser(authUser: User) async throws {
        let userDocRef = usersCollectionRef.document(authUser.uid)
        
        // 기존 사용자 문서가 있는지 확인
        let userDoc = try await userDocRef.getDocument()
        
        if userDoc.exists {
            // 기존 사용자 업데이트 (마지막 로그인 시간 등)
            try await userDocRef.updateData([
                "updatedAt": Timestamp(date: Date()),
                "email": authUser.email ?? ""
            ])
            print("✅ 기존 사용자 정보 업데이트: \(authUser.uid)")
        } else {
            // 새 사용자 생성
            let newUserDoc = AppUserDocument(
                id: authUser.uid,
                email: authUser.email,
                fullName: authUser.displayName,
                avatarUrl: authUser.photoURL?.absoluteString,
                createdAt: Timestamp(date: Date()),
                updatedAt: Timestamp(date: Date())
            )
            
            try userDocRef.setData(from: newUserDoc)
            print("✅ 새 사용자 생성: \(authUser.uid)")
            
            // 새 사용자를 위한 초기 데이터 생성
            try await createInitialDataForUser(userId: authUser.uid)
        }
    }
    
    /// 새 사용자를 위한 초기 데이터 생성 (중급 영단어 과목 + 50개 플래시카드)
    private func createInitialDataForUser(userId: String) async throws {
        print("🎯 새 사용자를 위한 초기 데이터 생성 시작")
        print("   ➤ 전달받은 userId: \(userId)")
        print("   ➤ 이 userId로 Subject와 Flashcard를 생성합니다")
        
        // 1. "중급 영단어" 과목 생성
        let initialSubject = Subject(
            name: "중급 영단어",
            description: "영어 학습을 위한 기본 중급 단어 모음",
            userId: userId,
            cardCount: VocabularyData.intermediateEnglishWords.count
        )
        
        print("   ➤ 생성할 Subject.userId: \(initialSubject.userId)")
        
        let subjectRef = try db.collection("subjects").addDocument(from: initialSubject)
        let subjectId = subjectRef.documentID
        print("✅ 초기 과목 생성 완료: \(initialSubject.name) (ID: \(subjectId))")
        
        // 2. 50개 플래시카드 생성
        let flashcards = VocabularyData.intermediateEnglishWords.map { vocabulary in
            Flashcard(
                userId: userId,
                subjectId: subjectId,
                front: vocabulary.korean,   // 앞면: 한국어
                back: vocabulary.english    // 뒷면: 영어
            )
        }
        
        print("   ➤ 생성할 Flashcard들의 userId: \(userId)")
        print("   ➤ 생성할 Flashcard들의 subjectId: \(subjectId)")
        
        // 플래시카드 일괄 생성
        let flashcardService = FlashcardService()
        try await flashcardService.createFlashcards(flashcards)
        
        print("🎉 새 사용자 초기 데이터 생성 완료: 과목 1개, 플래시카드 \(flashcards.count)개")
    }
    
    /// 사용자 정보 조회
    func getUser(userId: String) async throws -> AppUserDocument? {
        let userDoc = try await usersCollectionRef.document(userId).getDocument()
        return try userDoc.data(as: AppUserDocument.self)
    }
} 