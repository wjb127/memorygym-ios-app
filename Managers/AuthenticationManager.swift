import Foundation
import SwiftUI
import AuthenticationServices
import CryptoKit

// MARK: - Authentication Manager
@MainActor
class AuthenticationManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authenticationError: String?
    
    private var currentNonce: String?
    
    // MARK: - Apple Sign In
    func signInWithApple() {
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
    
    // MARK: - Google Sign In (추후 구현)
    func signInWithGoogle() {
        // TODO: Firebase Google 로그인 구현
        authenticationError = "Google 로그인은 추후 구현 예정입니다."
    }
    
    // MARK: - Sign Out
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        authenticationError = nil
    }
    
    // MARK: - Helper Methods
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
                authenticationError = "Invalid state: A login callback was received, but no login request was sent."
                return
            }
            
            // Apple ID 토큰 검증
            guard let appleIDToken = appleIDCredential.identityToken else {
                authenticationError = "Unable to fetch identity token"
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                authenticationError = "Unable to serialize token string from data"
                return
            }
            
            // 사용자 정보 생성
            let userID = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            
            let displayName = [fullName?.givenName, fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            let user = User(
                id: userID,
                email: email,
                displayName: displayName.isEmpty ? "Apple 사용자" : displayName,
                isGuest: false,
                createdAt: Date()
            )
            
            // TODO: Firebase Authentication과 연동
            // 현재는 로컬에서만 처리
            self.currentUser = user
            self.isAuthenticated = true
            self.authenticationError = nil
            
            print("Apple 로그인 성공: \(user.displayName)")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                authenticationError = "로그인이 취소되었습니다."
            case .failed:
                authenticationError = "로그인에 실패했습니다."
            case .invalidResponse:
                authenticationError = "잘못된 응답입니다."
            case .notHandled:
                authenticationError = "로그인을 처리할 수 없습니다."
            case .unknown:
                authenticationError = "알 수 없는 오류가 발생했습니다."
            @unknown default:
                authenticationError = "예상치 못한 오류가 발생했습니다."
            }
        } else {
            authenticationError = "로그인 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        print("Apple 로그인 오류: \(authenticationError ?? "Unknown error")")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
} 