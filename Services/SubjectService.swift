import Foundation
import FirebaseFirestore
import Combine

@MainActor
class SubjectService: ObservableObject {
    @Published var subjects = [Subject]()
    
    private let db = Firestore.firestore()
    private var subjectsCollectionRef: CollectionReference {
        return db.collection("subjects")
    }
    
    private var listenerRegistration: ListenerRegistration?

    func fetchSubjects(forUserID userID: String) {
        print("📚 과목 조회 시작")
        print("   ➤ 쿼리에 사용할 사용자 ID: '\(userID)'")
        print("   ➤ 쿼리: subjects.whereField('userId', isEqualTo: '\(userID)')")
        
        // 중복 리스너 방지
        listenerRegistration?.remove()
        
        listenerRegistration = subjectsCollectionRef
            .whereField("userId", isEqualTo: userID)
            // .order(by: "createdAt", descending: true)  // 복합 인덱스 필요해서 임시 제거
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ 과목 조회 오류: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("📭 쿼리 결과: 문서 없음 (사용자 ID: '\(userID)')")
                    self.subjects = []
                    return
                }
                
                print("📄 쿼리 결과: \(documents.count)개 문서 발견")
                
                // 각 문서의 실제 userId 값 확인
                for (index, doc) in documents.enumerated() {
                    let data = doc.data()
                    let docUserId = data["userId"] as? String ?? "없음"
                    print("   문서 \(index + 1): ID=\(doc.documentID), userId='\(docUserId)' (쿼리ID='\(userID)', 일치=\(docUserId == userID ? "✅" : "❌"))")
                }
                
                let subjects = documents.compactMap { document -> Subject? in
                    do {
                        let subject = try document.data(as: Subject.self)
                        print("✅ 과목 파싱 성공: '\(subject.name)' (문서ID: \(subject.id ?? "없음"), userId: '\(subject.userId)')")
                        return subject
                    } catch {
                        print("❌ 과목 파싱 실패 - 문서 ID: \(document.documentID), 오류: \(error)")
                        return nil
                    }
                }
                
                self.subjects = subjects
                print("🎯 최종 결과: \(self.subjects.count)개 과목 로드 완료")
                
                // 각 과목의 상세 정보 출력
                for (index, subject) in self.subjects.enumerated() {
                    print("   \(index + 1). '\(subject.name)' - 카드: \(subject.cardCount)개, userId: '\(subject.userId)'")
                }
            }
    }
    
    func addSubject(name: String, description: String, userID: String) async throws {
        let newSubject = Subject(name: name, description: description, userId: userID)
        _ = try subjectsCollectionRef.addDocument(from: newSubject)
        print("Successfully added subject: \(name)")
    }

    func updateSubject(_ subject: Subject) async throws {
        guard let documentID = subject.id else {
            throw NSError(domain: "SubjectService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Subject ID is nil"])
        }
        try await subjectsCollectionRef.document(documentID).setData(from: subject, merge: true)
        print("Successfully updated subject: \(subject.name)")
    }
    
    /// 과목의 카드 개수 업데이트
    func updateSubjectCardCount(subjectId: String, cardCount: Int) async throws {
        try await subjectsCollectionRef.document(subjectId).updateData([
            "cardCount": cardCount
        ])
        print("✅ 과목 카드 개수 업데이트: \(subjectId) -> \(cardCount)개")
    }

    func deleteSubject(_ subject: Subject) async throws {
        guard let documentID = subject.id else {
            throw NSError(domain: "SubjectService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Subject ID is nil"])
        }
        try await subjectsCollectionRef.document(documentID).delete()
        print("Successfully deleted subject: \(subject.name)")
    }
    
    // 리스너 해제
    deinit {
        listenerRegistration?.remove()
        print("SubjectService deinitialized and listener removed.")
    }
} 