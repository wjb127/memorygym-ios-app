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
    private var subjectsCollectionRef: CollectionReference {
        return db.collection("subjects")
    }
    
    private var listenerRegistration: ListenerRegistration?
    
    /// 특정 과목의 플래시카드들을 실시간으로 조회
    func fetchFlashcards(forSubjectID subjectID: String, userID: String) {
        print("🃏 플래시카드 조회 시작")
        print("   ➤ 사용자 ID: '\(userID)'")
        print("   ➤ 과목 ID: '\(subjectID)'")
        
        // 중복 리스너 방지
        listenerRegistration?.remove()
        
        listenerRegistration = flashcardsCollectionRef
            .whereField("userId", isEqualTo: userID)
            .whereField("subjectId", isEqualTo: subjectID)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ 플래시카드 조회 오류: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("📭 쿼리 결과: 플래시카드 없음")
                    self.flashcards = []
                    return
                }
                
                print("🃏 쿼리 결과: \(documents.count)개 플래시카드 발견")
                
                let flashcards = documents.compactMap { document -> Flashcard? in
                    do {
                        let flashcard = try document.data(as: Flashcard.self)
                        return flashcard
                    } catch {
                        print("❌ 플래시카드 파싱 실패 - 문서 ID: \(document.documentID), 오류: \(error)")
                        return nil
                    }
                }
                
                self.flashcards = flashcards
                print("🎯 최종 결과: \(self.flashcards.count)개 플래시카드 로드 완료")
                
                // 과목의 cardCount 업데이트
                Task {
                    await self.updateSubjectCardCount(subjectID: subjectID, cardCount: flashcards.count)
                }
            }
    }
    
    /// 새 플래시카드 추가
    func addFlashcard(front: String, back: String, subjectID: String, userID: String) async throws -> String {
        let newFlashcard = Flashcard(
            userId: userID,
            subjectId: subjectID,
            front: front,
            back: back
        )
        
        let docRef = try flashcardsCollectionRef.addDocument(from: newFlashcard)
        print("✅ 플래시카드 추가 성공: \(front) -> \(back)")
        
        // 과목의 cardCount 업데이트
        await updateSubjectCardCountFromFirestore(subjectID: subjectID, userID: userID)
        
        return docRef.documentID
    }
    
    /// 플래시카드 수정
    func updateFlashcard(_ flashcard: Flashcard) async throws {
        guard let documentID = flashcard.id else {
            throw NSError(domain: "FlashcardService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Flashcard ID is nil"])
        }
        try await flashcardsCollectionRef.document(documentID).setData(from: flashcard, merge: true)
        print("✅ 플래시카드 수정 성공: \(flashcard.front)")
    }
    
    /// 플래시카드 삭제
    func deleteFlashcard(_ flashcard: Flashcard) async throws {
        guard let documentID = flashcard.id else {
            throw NSError(domain: "FlashcardService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Flashcard ID is nil"])
        }
        try await flashcardsCollectionRef.document(documentID).delete()
        print("✅ 플래시카드 삭제 성공: \(flashcard.front)")
        
        // 과목의 cardCount 업데이트
        await updateSubjectCardCountFromFirestore(subjectID: flashcard.subjectId, userID: flashcard.userId)
    }

    /// 플래시카드 일괄 생성 (초기 데이터용)
    func createFlashcards(_ flashcards: [Flashcard]) async throws {
        print("🎯 플래시카드 일괄 생성 시작: \(flashcards.count)개")
        
        let batch = db.batch()
        
        for flashcard in flashcards {
            let docRef = flashcardsCollectionRef.document()
            try batch.setData(from: flashcard, forDocument: docRef)
        }
        
        try await batch.commit()
        print("✅ 플래시카드 일괄 생성 완료: \(flashcards.count)개")
        
        // 일괄 생성 후 각 과목의 cardCount 업데이트
        let subjectGroups = Dictionary(grouping: flashcards) { $0.subjectId }
        for (subjectID, cards) in subjectGroups {
            if let firstCard = cards.first {
                await updateSubjectCardCountFromFirestore(subjectID: subjectID, userID: firstCard.userId)
            }
        }
    }
    
    /// Firestore에서 실제 플래시카드 개수를 세어서 과목의 cardCount 업데이트
    private func updateSubjectCardCountFromFirestore(subjectID: String, userID: String) async {
        do {
            let querySnapshot = try await flashcardsCollectionRef
                .whereField("userId", isEqualTo: userID)
                .whereField("subjectId", isEqualTo: subjectID)
                .getDocuments()
            
            let actualCount = querySnapshot.documents.count
            await updateSubjectCardCount(subjectID: subjectID, cardCount: actualCount)
            
        } catch {
            print("❌ 플래시카드 개수 조회 실패: \(error.localizedDescription)")
        }
    }
    
    /// 과목의 cardCount 업데이트 (SubjectService 기능 복제)
    private func updateSubjectCardCount(subjectID: String, cardCount: Int) async {
        do {
            try await subjectsCollectionRef.document(subjectID).updateData([
                "cardCount": cardCount
            ])
            print("✅ 과목 퀴즈 개수 자동 업데이트: \(subjectID) -> \(cardCount)개")
        } catch {
            print("❌ 과목 퀴즈 개수 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    // 리스너 해제
    deinit {
        listenerRegistration?.remove()
        print("FlashcardService deinitialized and listener removed.")
    }
} 