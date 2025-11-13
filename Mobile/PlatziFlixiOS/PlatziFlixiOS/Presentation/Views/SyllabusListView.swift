//
//  SyllabusListView.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import SwiftUI

/// View displaying the list of classes/lessons (syllabus) for a course
struct SyllabusListView: View {
    let classes: [Class]
    let courseThumbnail: String? // Optional course thumbnail as fallback

    /// Initializer with optional course thumbnail
    init(classes: [Class], courseThumbnail: String? = nil) {
        self.classes = classes
        self.courseThumbnail = courseThumbnail
    }

    var body: some View {
        Group {
            if classes.isEmpty {
                let _ = print("⚠️ [SyllabusListView] No classes to display")
                emptyStateView
            } else {
                let _ = print("✅ [SyllabusListView] Displaying \(classes.count) classes")
                classesList
            }
        }
        .onAppear {
            print("📋 [SyllabusListView] View appeared with \(classes.count) classes")
            classes.forEach { classItem in
                print("   - Class \(classItem.id): \(classItem.name)")
            }
        }
    }

    // MARK: - Classes List

    /// List of classes/lessons
    private var classesList: some View {
        VStack(spacing: 0) {
            ForEach(classes) { classItem in
                ClassRowView(classItem: classItem, courseThumbnail: courseThumbnail)

                // Divider between items (except last)
                if classItem.id != classes.last?.id {
                    Divider()
                        .padding(.leading, Spacing.spacing4 + 80) // Align with content
                }
            }
        }
        .padding(.vertical, Spacing.spacing2)
    }

    // MARK: - Empty State

    /// Empty state when no classes are available
    private var emptyStateView: some View {
        VStack(spacing: Spacing.spacing4) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No hay clases disponibles")
                .font(.bodyEmphasized)
                .foregroundColor(.primary)

            Text("Este curso aún no tiene clases publicadas")
                .font(.captionRegular)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.spacing8)
    }
}

// MARK: - Class Row View

    /// Individual class/lesson row in the syllabus list
struct ClassRowView: View {
    let classItem: Class
    let courseThumbnail: String? // Optional course thumbnail as fallback

    /// Initializer with optional course thumbnail
    init(classItem: Class, courseThumbnail: String? = nil) {
        self.classItem = classItem
        self.courseThumbnail = courseThumbnail
    }

    var body: some View {
        HStack(spacing: Spacing.spacing4) {
            // Thumbnail
            classThumbnail

            // Class info
            VStack(alignment: .leading, spacing: Spacing.spacing2) {
                Text(classItem.name)
                    .font(.bodyEmphasized)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if !classItem.description.isEmpty {
                    Text(classItem.description)
                        .font(.captionRegular)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()

            // Download/Play icon (placeholder for future functionality)
        }
        .padding(.horizontal, Spacing.spacing4)
        .padding(.vertical, Spacing.spacing3)
        .contentShape(Rectangle()) // Make entire row tappable
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Clase: \(classItem.name)")
        .onAppear {
            print("   📹 [ClassRowView] Rendering class: \(classItem.name) (ID: \(classItem.id))")
            if let videoUrl = classItem.videoUrl {
                print("      - Video URL: \(videoUrl)")
                if let thumbnail = classItem.youtubeThumbnailURL {
                    print("      - YouTube thumbnail: \(thumbnail)")
                } else {
                    print("      - No YouTube thumbnail extracted")
                }
            } else {
                print("      - No video URL")
            }
        }
    }

    // MARK: - Thumbnail

    /// Class thumbnail image
    @ViewBuilder
    private var classThumbnail: some View {
        // Priority 1: Try to get YouTube thumbnail if video URL exists
        if let thumbnailURL = classItem.youtubeThumbnailURL {
            SecureAsyncImage(url: URL(string: thumbnailURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                thumbnailPlaceholder
            }
            .frame(width: 80, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: Radius.radiusSmall))
        }
        // Priority 2: Use course thumbnail as fallback
        else if let courseThumbnail = courseThumbnail, let thumbnailURL = URL(string: courseThumbnail) {
            SecureAsyncImage(url: thumbnailURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                thumbnailPlaceholder
            }
            .frame(width: 80, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: Radius.radiusSmall))
        }
        // Priority 3: Show placeholder
        else {
            thumbnailPlaceholder
        }
    }

    /// Placeholder thumbnail when no image is available
    private var thumbnailPlaceholder: some View {
        RoundedRectangle(cornerRadius: Radius.radiusSmall)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color.neutralGray200, Color.neutralGray400]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 80, height: 60)
            .overlay(
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.1))
                        .frame(width: 40, height: 40)

                    // Play icon
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                }
            )
    }
}

// MARK: - Preview
#Preview("With Classes") {
    NavigationView {
        SyllabusListView(
            classes: Class.mockClasses,
            courseThumbnail: "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_6733882e4711f40de0f1325f_6733882e4711f40de0f13270_13s.jpg?w=640&q=50"
        )
        .background(Color.groupedBackground)
    }
}

#Preview("Empty State") {
    NavigationView {
        SyllabusListView(classes: [])
            .background(Color.groupedBackground)
    }
}

