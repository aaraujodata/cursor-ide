import SwiftUI
import Foundation

/// Course card component that displays a course with its thumbnail and information
struct CourseCardView: View {
    let course: Course
    let onTap: (() -> Void)?

    init(course: Course, onTap: (() -> Void)? = nil) {
        self.course = course
        self.onTap = onTap
    }

    @ViewBuilder
    var body: some View {
        // Card content view - extracted for reuse
        let cardContent = cardContentBody

        // Wrap in Button only if onTap is provided (for standalone use)
        // When used inside NavigationLink, onTap will be nil and Button won't be used
        if let onTap = onTap {
            Button(action: onTap) {
                cardContent
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityAction(named: "Ver curso") {
                onTap()
            }
        } else {
            cardContent
        }
    }

    // MARK: - Private View Components

    /// The card content without button wrapper
    private var cardContentBody: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing3) {
            // Course thumbnail
            // Using SecureAsyncImage to handle corporate CA certificates
            SecureAsyncImage(url: URL(string: course.thumbnail)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    )
            }
            .cornerRadius(Radius.radiusMedium)
            .accessibilityLabel("Imagen del curso \(course.name)")

            // Course information
            VStack(alignment: .leading, spacing: Spacing.spacing2) {
                Text(course.name)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .accessibilityAddTraits(.isHeader)

                Text(course.displayDescription)
                    .font(.bodyRegular)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, Spacing.spacing3)
            .padding(.bottom, Spacing.spacing4)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Curso: \(course.name)")
        .accessibilityHint("Doble toque para ver los detalles del curso")
    }
}

// MARK: - Previews
#Preview("Light Mode") {
    CourseCardView(course: Course.mockCourses[0]) {
        print("Course tapped")
    }
    .padding()
}

#Preview("Dark Mode") {
    CourseCardView(course: Course.mockCourses[1]) {
        print("Course tapped")
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Grid Layout") {
    LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: Spacing.spacing4) {
        ForEach(Course.mockCourses.prefix(4), id: \.id) { course in
            CourseCardView(course: course)
        }
    }
    .padding()
}