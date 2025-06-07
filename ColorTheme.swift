import SwiftUI

extension Color {
    // MARK: - MemoryGym Theme Colors
    
    /// 메인 브랜드 컬러 - 밝은 핑크/산고색 (스크린샷의 덤벨 컬러)
    static let memoryGymPrimary = Color("PrimaryColor")
    
    /// 액센트 컬러 - 조금 더 진한 핑크
    static let memoryGymAccent = Color("AccentColor")
    
    /// 보조 컬러 - 연한 핑크
    static let memoryGymSecondary = Color("SecondaryColor")
    
    /// 그라데이션용 컬러들
    static let memoryGymGradientStart = Color("PrimaryColor")
    static let memoryGymGradientEnd = Color("SecondaryColor")
    
    /// 배경 컬러
    static let memoryGymBackground = Color.white
    static let memoryGymCardBackground = Color.gray.opacity(0.1)
    
    /// 텍스트 컬러
    static let memoryGymText = Color.black
    static let memoryGymSecondaryText = Color.gray
    
    /// 성공/경고 컬러
    static let memoryGymSuccess = Color.green
    static let memoryGymWarning = Color.orange
    static let memoryGymError = Color.red
}

// MARK: - Theme Gradients
extension LinearGradient {
    /// 메인 테마 그라데이션
    static let memoryGymGradient = LinearGradient(
        gradient: Gradient(colors: [Color.memoryGymGradientStart, Color.memoryGymGradientEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 버튼용 그라데이션
    static let memoryGymButtonGradient = LinearGradient(
        gradient: Gradient(colors: [Color.memoryGymPrimary, Color.memoryGymAccent]),
        startPoint: .leading,
        endPoint: .trailing
    )
} 