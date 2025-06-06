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
        // 중복 리스너 방지
        listenerRegistration?.remove()
        
        listenerRegistration = subjectsCollectionRef
            .whereField("userId", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching subjects: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents in 'subjects' collection for user \(userID)")
                    self.subjects = []
                    return
                }
                
                self.subjects = documents.compactMap { document -> Subject? in
                    try? document.data(as: Subject.self)
                }
                print("Fetched \(self.subjects.count) subjects for user \(userID)")
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