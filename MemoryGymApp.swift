import SwiftUI

@main
struct MemoryGymApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authManager)
                .onReceive(authManager.$isAuthenticated) { isAuthenticated in
                    if isAuthenticated {
                        appState.loginWithUser(authManager.currentUser)
                    }
                }
        }
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isGuestMode = false
    @Published var currentUser: User?
    @Published var showSplash = true
    
    init() {
        // 앱 시작시 스플래시 화면 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showSplash = false
        }
    }
    
    func loginAsGuest() {
        isGuestMode = true
        isLoggedIn = true
        currentUser = User.guestUser
    }
    
    func loginWithUser(_ user: User?) {
        guard let user = user else { return }
        isGuestMode = false
        isLoggedIn = true
        currentUser = user
    }
    
    func logout() {
        isLoggedIn = false
        isGuestMode = false
        currentUser = nil
    }
} 