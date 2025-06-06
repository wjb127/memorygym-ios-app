import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            // 암기훈련 탭
            StudyView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("암기훈련")
                }
                .tag(0)
            
            // 퀴즈관리 탭
            FlashcardManagementView()
                .tabItem {
                    Image(systemName: "rectangle.stack")
                    Text("퀴즈관리")
                }
                .tag(1)
            
            // 과목관리 탭
            SubjectManagementView()
                .tabItem {
                    Image(systemName: "folder")
                    Text("과목관리")
                }
                .tag(2)
        }
        .accentColor(.accentPink)
        .environmentObject(dataManager)
        .onAppear {
            if appState.isGuestMode {
                dataManager.loadGuestData()
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
} 