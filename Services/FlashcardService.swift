import Foundation
import FirebaseFirestore
import Combine

@MainActor
class FlashcardService: ObservableObject {
    @Published var flashcards = [Flashcard]()
    
    private let db = Firestore.firestore()
    private var flashcardsCollectionRef: CollectionReference {
        return db.collection("flashcards")
    }
    
    private var listenerRegistration: ListenerRegistration?
    
    /// 특정 과목의 플래시카드 조회
    func fetchFlashcards(forSubjectID subjectID: String) {
        print("🃏 플래시카드 조회 시작 - 과목 ID: \(subjectID)")
        
        listenerRegistration?.remove()
        
        listenerRegistration = flashcardsCollectionRef
            .whereField("subjectId", isEqualTo: subjectID)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ 플래시카드 조회 오류: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("📭 플래시카드 문서 없음 - 과목 ID: \(subjectID)")
                    self.flashcards = []
                    return
                }
                
                print("📄 조회된 플래시카드 문서 개수: \(documents.count)")
                
                let flashcards = documents.compactMap { document -> Flashcard? in
                    do {
                        let flashcard = try document.data(as: Flashcard.self)
                        return flashcard
                    } catch {
                        print("❌ 플래시카드 파싱 실패 - 문서 ID: \(document.documentID)")
                        return nil
                    }
                }
                
                self.flashcards = flashcards
                print("🃏 최종 로드된 플래시카드 수: \(self.flashcards.count)")
            }
    }
    
    /// 플래시카드 생성
    func createFlashcard(_ flashcard: Flashcard) async throws {
        _ = try flashcardsCollectionRef.addDocument(from: flashcard)
        print("✅ 플래시카드 생성 완료: \(flashcard.front) - \(flashcard.back)")
    }
    
    /// 여러 플래시카드 일괄 생성
    func createFlashcards(_ flashcards: [Flashcard]) async throws {
        print("🔄 \(flashcards.count)개 플래시카드 일괄 생성 시작...")
        
        for flashcard in flashcards {
            try await createFlashcard(flashcard)
        }
        
        print("✅ \(flashcards.count)개 플래시카드 일괄 생성 완료")
    }
    
    /// 플래시카드 수정
    func updateFlashcard(_ flashcard: Flashcard) async throws {
        guard let documentID = flashcard.id else {
            throw NSError(domain: "FlashcardService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Flashcard ID is nil"])
        }
        try await flashcardsCollectionRef.document(documentID).setData(from: flashcard, merge: true)
        print("✅ 플래시카드 수정 완료: \(flashcard.front)")
    }
    
    /// 플래시카드 삭제
    func deleteFlashcard(_ flashcard: Flashcard) async throws {
        guard let documentID = flashcard.id else {
            throw NSError(domain: "FlashcardService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Flashcard ID is nil"])
        }
        try await flashcardsCollectionRef.document(documentID).delete()
        print("✅ 플래시카드 삭제 완료: \(flashcard.front)")
    }
    
    deinit {
        listenerRegistration?.remove()
        print("FlashcardService deinitialized and listener removed.")
    }
} 