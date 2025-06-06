import SwiftUI

@main
struct MemoryGymApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var showSplash = true
    @Published var isLoggedIn = false
    @Published var isGuestMode = false
    
    init() {
        // 스플래시 화면을 2초간 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showSplash = false
        }
    }
    
    func loginAsGuest() {
        isGuestMode = true
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
        isGuestMode = false
    }
} 