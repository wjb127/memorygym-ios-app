import SwiftUI

@MainActor
struct AddEditSubjectView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Using a dedicated ViewModel for the view's logic
    @StateObject private var viewModel: AddEditSubjectViewModel
    
    private var navigationTitle: String {
        viewModel.isEditing ? "과목 수정" : "새 과목 추가"
    }
    
    init(subjectToEdit: Subject? = nil, subjectService: SubjectService) {
        _viewModel = StateObject(wrappedValue: AddEditSubjectViewModel(subjectToEdit: subjectToEdit, subjectService: subjectService))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("과목 정보")) {
                    TextField("과목 이름", text: $viewModel.name)
                    TextField("과목 설명 (선택)", text: $viewModel.description)
                }
                
                Section {
                    Button(action: save) {
                        Text("저장")
                    }
                    .disabled(viewModel.isSaveButtonDisabled)
                }
                
                if viewModel.isEditing {
                    Section {
                        Button("과목 삭제", role: .destructive, action: {
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
            .alert("이 과목을 삭제하시겠습니까?", isPresented: $viewModel.showDeleteConfirm) {
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


// ViewModel for AddEditSubjectView
@MainActor
class AddEditSubjectViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var showDeleteConfirm = false
    @Published var showError = false
    @Published var errorMessage: String?

    let isEditing: Bool
    private var subjectToEdit: Subject?
    private let subjectService: SubjectService
    
    var isSaveButtonDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(subjectToEdit: Subject?, subjectService: SubjectService) {
        self.subjectToEdit = subjectToEdit
        self.subjectService = subjectService
        self.isEditing = subjectToEdit != nil
        
        if let subject = subjectToEdit {
            self.name = subject.name
            self.description = subject.description
        }
    }
    
    func save(userID: String) async -> Bool {
        do {
            if var subject = subjectToEdit {
                subject.name = name
                subject.description = description
                try await subjectService.updateSubject(subject)
            } else {
                try await subjectService.addSubject(name: name, description: description, userID: userID)
            }
            return true
        } catch {
            setError("저장에 실패했습니다: \(error.localizedDescription)")
            return false
        }
    }
    
    func delete() async -> Bool {
        guard let subject = subjectToEdit else { return false }
        do {
            try await subjectService.deleteSubject(subject)
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