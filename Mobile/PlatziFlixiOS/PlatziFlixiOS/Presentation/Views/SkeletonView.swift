import SwiftUI

// MARK: - Shimmer Effect Modifier

/// ViewModifier that applies a shimmer animation effect for skeleton loading states
/// Following modern iOS skeleton loading patterns (2025)
struct ShimmerEffect: ViewModifier {
    /// Duration of one shimmer cycle in seconds
    @State private var phase: CGFloat = 0

    /// Animation duration (default: 1.5 seconds for smooth shimmer)
    var duration: Double = 1.5

    /// Gradient colors for the shimmer effect
    /// Adapts automatically to light/dark mode using system colors
    private var shimmerColors: [Color] {
        [
            Color(.systemGray5),     // Base color
            Color(.systemGray4),     // Lighter highlight
            Color(.systemGray5)      // Back to base
        ]
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                // Shimmer gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: shimmerColors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                // Start shimmer animation with smooth infinite loop
                // Reset phase to start position for seamless animation
                phase = -200
                withAnimation(
                    Animation.linear(duration: duration)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 200 // Move gradient across the view
                }
            }
    }
}

// MARK: - View Extension

extension View {
    /// Applies a shimmer effect for skeleton loading states
    /// - Parameter duration: Animation duration in seconds (default: 1.5)
    /// - Returns: View with shimmer effect applied
    func shimmer(duration: Double = 1.5) -> some View {
        self.modifier(ShimmerEffect(duration: duration))
    }
}

// MARK: - Skeleton View Component

/// Reusable skeleton view component for loading states
/// Matches the design system spacing and colors
struct SkeletonView: View {
    /// Width of the skeleton (nil = flexible)
    var width: CGFloat? = nil

    /// Height of the skeleton
    var height: CGFloat

    /// Corner radius (default: small radius from design system)
    var cornerRadius: CGFloat = Radius.radiusSmall

    var body: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .shimmer()
    }
}

// MARK: - Previews

#Preview("Shimmer Effect") {
    VStack(spacing: Spacing.spacing4) {
        SkeletonView(width: 200, height: 20)
        SkeletonView(width: 150, height: 20)
        SkeletonView(width: 180, height: 20)
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.spacing4) {
        SkeletonView(width: 200, height: 20)
        SkeletonView(width: 150, height: 20)
        SkeletonView(width: 180, height: 20)
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

