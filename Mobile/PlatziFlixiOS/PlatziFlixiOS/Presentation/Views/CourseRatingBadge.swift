import SwiftUI

/// Rating badge component that displays a course's average rating with a star icon
/// Designed to be overlaid on top of course card thumbnails
struct CourseRatingBadge: View {
    let rating: Double
    let totalRatings: Int?

    var body: some View {
        HStack(spacing: Spacing.spacing1) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundColor(.yellow)

            Text(formattedRating)
                .font(.buttonSmall)
                .foregroundColor(.white)
        }
        .padding(.horizontal, Spacing.spacing2)
        .padding(.vertical, Spacing.spacing1)
        .background(
            RoundedRectangle(cornerRadius: Radius.radiusFull)
                .fill(Color.black.opacity(0.7))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Private Computed Properties

    /// Formats the rating to one decimal place
    private var formattedRating: String {
        String(format: "%.1f", rating)
    }

    /// Accessibility text that includes rating and total count
    private var accessibilityText: String {
        if let total = totalRatings, total > 0 {
            return "Calificación \(formattedRating) de 5 estrellas, basada en \(total) opiniones"
        } else {
            return "Calificación \(formattedRating) de 5 estrellas"
        }
    }
}

// MARK: - Previews
#Preview("Single Rating") {
    ZStack {
        Rectangle()
            .fill(Color.gray)
            .frame(width: 300, height: 200)

        VStack {
            Spacer()
            HStack {
                Spacer()
                CourseRatingBadge(rating: 4.8, totalRatings: 142)
                    .padding(Spacing.spacing3)
            }
        }
    }
    .cornerRadius(Radius.radiusMedium)
}

#Preview("Different Ratings") {
    VStack(spacing: Spacing.spacing4) {
        ForEach([
            (rating: 4.8, total: 142),
            (rating: 4.5, total: 89),
            (rating: 3.2, total: 12),
            (rating: 5.0, total: 201)
        ], id: \.rating) { item in
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 300, height: 200)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        CourseRatingBadge(rating: item.rating, totalRatings: item.total)
                            .padding(Spacing.spacing3)
                    }
                }
            }
            .cornerRadius(Radius.radiusMedium)
        }
    }
    .padding()
}

#Preview("Dark Mode") {
    ZStack {
        Rectangle()
            .fill(Color.gray)
            .frame(width: 300, height: 200)

        VStack {
            Spacer()
            HStack {
                Spacer()
                CourseRatingBadge(rating: 4.8, totalRatings: 142)
                    .padding(Spacing.spacing3)
            }
        }
    }
    .cornerRadius(Radius.radiusMedium)
    .preferredColorScheme(.dark)
}
