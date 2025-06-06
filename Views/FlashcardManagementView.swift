import SwiftUI

struct FlashcardManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddCard = false
    @State private var searchText = ""
    
    var filteredFlashcards: [Flashcard] {
        guard let currentSubject = dataManager.currentSubject else { return [] }
        let subjectCards = dataManager.getFlashcards(for: currentSubject.id)
        
        if searchText.isEmpty {
            return subjectCards
        } else {
            return subjectCards.filter { card in
                card.front.localizedCaseInsensitiveContains(searchText) ||
                card.back.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.currentSubject == nil {
                    // 선택된 과목이 없는 경우
                    VStack(spacing: 16) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("과목을 선택해주세요")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("과목관리 탭에서 과목을 생성하거나\n선택해주세요.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    // 플래시카드 목록
                    List {
                        ForEach(filteredFlashcards) { card in
                            FlashcardRowView(card: card) {
                                dataManager.deleteFlashcard(card)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "플래시카드 검색")
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("퀴즈관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCard = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(dataManager.currentSubject == nil)
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddFlashcardView()
            }
        }
    }
}

struct FlashcardRowView: View {
    let card: Flashcard
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.front)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(card.back)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Box \(card.boxNumber)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentPink)
                        .cornerRadius(4)
                    
                    Text(card.nextReview, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("삭제", role: .destructive) {
                onDelete()
            }
        }
    }
}

struct AddFlashcardView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var front = ""
    @State private var back = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("문제") {
                    TextField("문제를 입력하세요", text: $front, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("답") {
                    TextField("답을 입력하세요", text: $back, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("새 플래시카드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveFlashcard()
                    }
                    .disabled(front.isEmpty || back.isEmpty)
                }
            }
        }
    }
    
    private func saveFlashcard() {
        guard let currentSubject = dataManager.currentSubject else { return }
        
        let newCard = Flashcard(
            userId: currentSubject.userId,
            subjectId: currentSubject.id,
            front: front.trimmingCharacters(in: .whitespacesAndNewlines),
            back: back.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.addFlashcard(newCard)
        dismiss()
    }
}

#Preview {
    FlashcardManagementView()
        .environmentObject(DataManager())
} 