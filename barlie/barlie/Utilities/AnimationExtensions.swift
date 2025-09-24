import SwiftUI

// MARK: - Animation Extensions
extension Animation {
    static let smoothSpring = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    static let gentleEase = Animation.easeInOut(duration: 0.4)
    static let quickEase = Animation.easeInOut(duration: 0.2)
}

// MARK: - View Extensions
extension View {
    func slideInFromRight() -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }
    
    func slideInFromLeft() -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
    
    func fadeInScale() -> some View {
        self.transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
    
    func cardTransition() -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
}

// MARK: - Haptic Feedback
struct HapticFeedback {
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}
