import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct MemoryGymApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @State private var showSplash = true
    
    init() {
        // Firebase 초기화
        FirebaseApp.configure()
        
        // Google Sign-In 설정
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let clientID = plist["CLIENT_ID"] as? String {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                } else {
                    ContentView()
                        .environmentObject(authManager)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSplash = false
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("암기훈련소")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - App State (사용하지 않음 - 호환성을 위해 유지)
@MainActor
class AppState: ObservableObject {
    @Published var showSplash = true
    @Published var isLoggedIn = false
    @Published var isGuestMode = false
    
    init() {
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