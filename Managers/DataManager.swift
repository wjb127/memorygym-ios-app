import Foundation
import SwiftUI

// MARK: - Data Manager
@MainActor
class DataManager: ObservableObject {
    @Published var subjects: [Subject] = []
    @Published var flashcards: [Flashcard] = []
    @Published var currentSubject: Subject?
    
    // 게스트 모드 데이터 로드
    func loadGuestData() {
        let guestSubject = GuestData.createGuestSubject()
        subjects = [guestSubject]
        flashcards = GuestData.createGuestFlashcards(subjectId: guestSubject.id)
        currentSubject = guestSubject
    }
    
    // 특정 과목의 플래시카드 가져오기
    func getFlashcards(for subjectId: String) -> [Flashcard] {
        return flashcards.filter { $0.subjectId == subjectId }
    }
    
    // 복습이 필요한 플래시카드 가져오기
    func getFlashcardsForReview(subjectId: String) -> [Flashcard] {
        let subjectFlashcards = getFlashcards(for: subjectId)
        return subjectFlashcards.filter { $0.nextReview <= Date() }
    }
    
    // 플래시카드 업데이트
    func updateFlashcard(_ flashcard: Flashcard) {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index] = flashcard
        }
    }
    
    // 새 과목 추가
    func addSubject(_ subject: Subject) {
        subjects.append(subject)
    }
    
    // 과목 삭제
    func deleteSubject(_ subject: Subject) {
        subjects.removeAll { $0.id == subject.id }
        flashcards.removeAll { $0.subjectId == subject.id }
    }
    
    // 새 플래시카드 추가
    func addFlashcard(_ flashcard: Flashcard) {
        flashcards.append(flashcard)
    }
    
    // 플래시카드 삭제
    func deleteFlashcard(_ flashcard: Flashcard) {
        flashcards.removeAll { $0.id == flashcard.id }
    }
} 