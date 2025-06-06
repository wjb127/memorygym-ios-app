import SwiftUI
import Combine
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

struct AppUser {
    let id: String
    let displayName: String?
    let email: String?
    let photoURL: String?
}

@MainActor
class AuthenticationManager: NSObject, ObservableObject {
    @Published var user: AppUser?
    @Published var isSignedIn = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var currentNonce: String?
    
    override init() {
        super.init()
        // Firebase Auth 상태 모니터링
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            Task { @MainActor in
                if let user = user {
                    self?.user = AppUser(
                        id: user.uid,
                        displayName: user.displayName,
                        email: user.email,
                        photoURL: user.photoURL?.absoluteString
                    )
                    self?.isSignedIn = true
                } else {
                    self?.user = nil
                    self?.isSignedIn = false
                }
            }
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() {
        isLoading = true
        errorMessage = ""
        print("🔄 Google Sign-In 시작...")
        
        guard let clientID = getGoogleClientID() else {
            isLoading = false
            errorMessage = "Google 설정이 올바르지 않습니다."
            return
        }
        
        guard let presentingViewController = getRootViewController() else {
            isLoading = false
            errorMessage = "화면 설정 오류가 발생했습니다."
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            Task { @MainActor in
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Google Sign-In 오류: \(error.localizedDescription)")
                    self?.errorMessage = "Google 로그인에 실패했습니다: \(error.localizedDescription)"
                    return
                }
                
                guard let result = result,
                      let idToken = result.user.idToken?.tokenString else {
                    self?.errorMessage = "Google 인증 토큰을 받아올 수 없습니다."
                    return
                }
                
                let accessToken = result.user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                do {
                    let authResult = try await Auth.auth().signIn(with: credential)
                    print("✅ Google Sign-In 성공: \(authResult.user.email ?? "No email")")
                } catch {
                    print("❌ Firebase 인증 오류: \(error.localizedDescription)")
                    self?.errorMessage = "Firebase 인증에 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Apple Sign In
    func signInWithApple() {
        isLoading = true
        errorMessage = ""
        print("🔄 Apple Sign-In 시작...")
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            user = nil
            isSignedIn = false
            errorMessage = ""
            print("✅ 로그아웃 완료")
        } catch {
            errorMessage = "로그아웃 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper Methods
    private func getGoogleClientID() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["CLIENT_ID"] as? String else {
            return nil
        }
        return clientID
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
    
    // Apple Sign In을 위한 nonce 생성
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // SHA256 해시 생성
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("❌ Apple Sign-In: Invalid state - A login callback was received, but no login request was sent.")
                isLoading = false
                errorMessage = "Apple 로그인 상태 오류가 발생했습니다."
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("❌ Apple Sign-In: Unable to fetch identity token")
                isLoading = false
                errorMessage = "Apple 인증 토큰을 받아올 수 없습니다."
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("❌ Apple Sign-In: Unable to serialize token string from data")
                isLoading = false
                errorMessage = "Apple 토큰 처리 중 오류가 발생했습니다."
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            Task {
                do {
                    let authResult = try await Auth.auth().signIn(with: credential)
                    print("✅ Apple Sign-In 성공: \(authResult.user.email ?? "No email")")
                    isLoading = false
                } catch {
                    print("❌ Firebase Apple 인증 오류: \(error.localizedDescription)")
                    isLoading = false
                    errorMessage = "Firebase Apple 인증에 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Apple Sign-In 오류: \(error.localizedDescription)")
        isLoading = false
        
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                errorMessage = "Apple 로그인이 취소되었습니다."
            case .failed:
                errorMessage = "Apple 로그인에 실패했습니다."
            case .invalidResponse:
                errorMessage = "Apple 로그인 응답이 올바르지 않습니다."
            case .notHandled:
                errorMessage = "Apple 로그인 요청을 처리할 수 없습니다."
            case .unknown:
                errorMessage = "알 수 없는 Apple 로그인 오류가 발생했습니다."
            default:
                errorMessage = "Apple 로그인 취소 또는 실패: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Apple 로그인 취소 또는 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
} 