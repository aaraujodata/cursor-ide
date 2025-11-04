import SwiftUI

/// Skeleton loading view that mimics the CourseCardView structure
/// Used during initial loading state to provide visual feedback
/// Follows CLEAR architecture: Presentation layer component
struct CourseCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing3) {
            // Skeleton thumbnail - matches CourseCardView image height
            SkeletonView(
                width: nil,
                height: 160,
                cornerRadius: Radius.radiusMedium
            )
            
            // Course information skeleton
            VStack(alignment: .leading, spacing: Spacing.spacing2) {
                // Title skeleton - two lines (matching course name)
                VStack(alignment: .leading, spacing: Spacing.spacing1) {
                    SkeletonView(
                        width: nil,
                        height: 20,
                        cornerRadius: Radius.radiusSmall
                    )
                    SkeletonView(
                        width: 150, // Shorter second line
                        height: 20,
                        cornerRadius: Radius.radiusSmall
                    )
                }
                
                // Description skeleton - three lines (matching course description)
                VStack(alignment: .leading, spacing: Spacing.spacing1) {
                    SkeletonView(
                        width: nil,
                        height: 16,
                        cornerRadius: Radius.radiusSmall
                    )
                    SkeletonView(
                        width: nil,
                        height: 16,
                        cornerRadius: Radius.radiusSmall
                    )
                    SkeletonView(
                        width: 200, // Shorter third line
                        height: 16,
                        cornerRadius: Radius.radiusSmall
                    )
                }
                .padding(.top, Spacing.spacing1)
            }
            .padding(.horizontal, Spacing.spacing3)
            .padding(.bottom, Spacing.spacing4)
        }
        .cardStyle()
        .accessibilityLabel("Cargando curso")
        .accessibilityHint("El contenido del curso se está cargando")
    }
}

// MARK: - Previews

#Preview("Single Skeleton Card") {
    CourseCardSkeletonView()
        .padding()
}

#Preview("Skeleton List") {
    ScrollView {
        LazyVStack(spacing: Spacing.spacing4) {
            ForEach(0..<5, id: \.self) { _ in
                CourseCardSkeletonView()
            }
        }
        .padding(.horizontal, Spacing.spacing4)
    }
    .background(Color.groupedBackground)
}

#Preview("Dark Mode") {
    ScrollView {
        LazyVStack(spacing: Spacing.spacing4) {
            ForEach(0..<3, id: \.self) { _ in
                CourseCardSkeletonView()
            }
        }
        .padding(.horizontal, Spacing.spacing4)
    }
    .background(Color.groupedBackground)
    .preferredColorScheme(.dark)
}

