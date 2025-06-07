import SwiftUI

@MainActor
struct AddEditFlashcardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @StateObject private var viewModel: AddEditFlashcardViewModel
    
    private var navigationTitle: String {
        viewModel.isEditing ? "퀴즈 수정" : "새 퀴즈 추가"
    }
    
    init(flashcardToEdit: Flashcard? = nil, subjectID: String, flashcardService: FlashcardService) {
        _viewModel = StateObject(wrappedValue: AddEditFlashcardViewModel(
            flashcardToEdit: flashcardToEdit,
            subjectID: subjectID,
            flashcardService: flashcardService
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("퀴즈 내용")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("문제")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("예: 집중하다", text: $viewModel.front)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("정답")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("예: concentrate", text: $viewModel.back)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                

                
                Section {
                    Button(action: save) {
                        Text("저장")
                    }
                    .disabled(viewModel.isSaveButtonDisabled)
                }
                
                if viewModel.isEditing {
                    Section {
                        Button("퀴즈 삭제", role: .destructive, action: {
                            viewModel.showDeleteConfirm = true
                        })
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            .alert("이 퀴즈를 삭제하시겠습니까?", isPresented: $viewModel.showDeleteConfirm) {
                Button("삭제", role: .destructive, action: delete)
                Button("취소", role: .cancel) { }
            } message: {
                Text("이 작업은 되돌릴 수 없습니다.")
            }
            .alert("오류", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in
                Button("확인") { }
            } message: { message in
                Text(message)
            }
        }
    }
    
    private func save() {
        guard let userID = authManager.user?.id else {
            viewModel.setError("사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.")
            return
        }
        
        Task {
            if await viewModel.save(userID: userID) {
                dismiss()
            }
        }
    }
    
    private func delete() {
        Task {
            if await viewModel.delete() {
                dismiss()
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
class AddEditFlashcardViewModel: ObservableObject {
    @Published var front = ""
    @Published var back = ""
    @Published var difficulty = 1
    @Published var showDeleteConfirm = false
    @Published var showError = false
    @Published var errorMessage: String?

    let isEditing: Bool
    private var flashcardToEdit: Flashcard?
    private let subjectID: String
    private let flashcardService: FlashcardService
    
    var isSaveButtonDisabled: Bool {
        front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(flashcardToEdit: Flashcard?, subjectID: String, flashcardService: FlashcardService) {
        self.flashcardToEdit = flashcardToEdit
        self.subjectID = subjectID
        self.flashcardService = flashcardService
        self.isEditing = flashcardToEdit != nil
        
        if let flashcard = flashcardToEdit {
            self.front = flashcard.front
            self.back = flashcard.back
            // 난이도는 항상 1로 고정 (학습단계 1)
            self.difficulty = 1
        }
    }
    
    func save(userID: String) async -> Bool {
        do {
            if var flashcard = flashcardToEdit {
                flashcard.front = front
                flashcard.back = back
                // 난이도는 항상 1로 고정 (학습단계 1)
                flashcard.difficulty = 1
                try await flashcardService.updateFlashcard(flashcard)
            } else {
                _ = try await flashcardService.addFlashcard(
                    front: front,
                    back: back,
                    subjectID: subjectID,
                    userID: userID
                )
            }
            return true
        } catch {
            setError("저장에 실패했습니다: \(error.localizedDescription)")
            return false
        }
    }
    
    func delete() async -> Bool {
        guard let flashcard = flashcardToEdit else { return false }
        do {
            try await flashcardService.deleteFlashcard(flashcard)
            return true
        } catch {
            setError("삭제에 실패했습니다: \(error.localizedDescription)")
            return false
        }
    }
    
    func setError(_ message: String) {
        self.errorMessage = message
        self.showError = true
    }
} 