import SwiftUI

// MARK: - Design System
extension Color {
    static let accentPink = Color(red: 1.0, green: 0.4, blue: 0.6)
    static let textGray = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let cardBackground = Color.white
    static let shadowColor = Color.black.opacity(0.1)
}

// MARK: - Typography
extension Font {
    static let largeTitle = Font.system(size: 28, weight: .bold)
    static let title = Font.system(size: 22, weight: .semibold)
    static let headline = Font.system(size: 18, weight: .medium)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 14, weight: .regular)
}

// MARK: - Spacing
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

// MARK: - Shadow
struct AppShadow {
    static let card = Shadow(color: .shadowColor, radius: 8, x: 0, y: 2)
    static let button = Shadow(color: .shadowColor, radius: 4, x: 0, y: 2)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
} 