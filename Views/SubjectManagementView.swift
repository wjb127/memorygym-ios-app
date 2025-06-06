import SwiftUI

struct SubjectManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingAddSubject = false
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.subjects.isEmpty {
                    // 과목이 없는 경우
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("과목이 없습니다")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("새로운 과목을 추가해보세요.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    // 과목 목록
                    List {
                        ForEach(dataManager.subjects) { subject in
                            SubjectRowView(
                                subject: subject,
                                isSelected: subject.id == dataManager.currentSubject?.id,
                                cardCount: dataManager.getFlashcards(for: subject.id).count
                            ) {
                                dataManager.currentSubject = subject
                            } onDelete: {
                                dataManager.deleteSubject(subject)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("과목관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.accentPink.opacity(0.2))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(String(appState.currentUser?.displayName.prefix(1) ?? "?"))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentPink)
                                )
                            
                            if !appState.isGuestMode {
                                Text(appState.currentUser?.displayName ?? "사용자")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSubject = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(appState.isGuestMode) // 게스트 모드에서는 과목 추가 불가
                }
            }
            .sheet(isPresented: $showingAddSubject) {
                AddSubjectView()
            }
            .sheet(isPresented: $showingProfile) {
                NavigationView {
                    UserProfileView()
                        .navigationTitle("프로필")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("완료") {
                                    showingProfile = false
                                }
                            }
                        }
                }
            }
        }
    }
}

struct SubjectRowView: View {
    let subject: Subject
    let isSelected: Bool
    let cardCount: Int
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = subject.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text("\(cardCount)개의 카드")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentPink)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("삭제", role: .destructive) {
                onDelete()
            }
        }
    }
}

struct AddSubjectView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("과목 정보") {
                    TextField("과목명", text: $name)
                    TextField("설명 (선택사항)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("새 과목")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveSubject()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveSubject() {
        guard let currentUser = appState.currentUser else { return }
        
        let newSubject = Subject(
            userId: currentUser.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.addSubject(newSubject)
        dismiss()
    }
}

#Preview {
    SubjectManagementView()
        .environmentObject(DataManager())
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager())
} 