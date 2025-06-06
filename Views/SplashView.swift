import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    var body: some View {
        ZStack {
            Color.accentPink
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                // 앱 로고 (임시로 텍스트 사용)
                Text("🧠")
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("MemoryGym")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("암기훈련소")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
} 