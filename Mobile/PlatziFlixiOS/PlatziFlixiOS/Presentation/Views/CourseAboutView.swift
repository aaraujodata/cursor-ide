//
//  CourseAboutView.swift
//
//  Created by AI Assistant
//

import SwiftUI

/// View displaying course metadata and information (About tab)
struct CourseAboutView: View {
    let course: Course

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.spacing6) {
                // Teachers section
                if course.hasTeacherInfo {
                    teachersSection
                }

                // Course dates section
                if course.createdAt != nil {
                    courseDatesSection
                }

                // Course statistics (if available)
                if course.hasRatings {
                    courseStatisticsSection
                }
            }
            .padding(.vertical, Spacing.spacing4)
        }
        .onAppear {
            print("ℹ️ [CourseAboutView] View appeared")
            print("   - Has teacher info: \(course.hasTeacherInfo)")
            print("   - Has createdAt: \(course.createdAt != nil)")
            print("   - Has ratings: \(course.hasRatings)")
        }
    }

    // MARK: - Teachers Section

    /// Teachers/instructors information section
    @ViewBuilder
    private var teachersSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing3) {
            Text("Instructores")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)

            if let teachers = course.teachers, !teachers.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.spacing3) {
                    ForEach(teachers) { teacher in
                        HStack(spacing: Spacing.spacing3) {
                            // Teacher avatar/initials
                            Circle()
                                .fill(Color.primaryBlue.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(teacher.initials)
                                        .font(.bodyEmphasized)
                                        .foregroundColor(.primaryBlue)
                                )

                            VStack(alignment: .leading, spacing: Spacing.spacing1) {
                                Text(teacher.name)
                                    .font(.bodyEmphasized)
                                    .foregroundColor(.primary)
                                Text(teacher.email)
                                    .font(.captionRegular)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Instructor: \(teacher.name)")
                    }
                }
            } else if !course.teacherIds.isEmpty {
                // Fallback when we only have IDs
                HStack(spacing: Spacing.spacing2) {
                    Image(systemName: "person.2.fill")
                        .font(.title3)
                        .foregroundColor(.primaryBlue)
                    Text("\(course.teacherIds.count) instructor\(course.teacherIds.count == 1 ? "" : "es")")
                        .font(.bodyRegular)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, Spacing.spacing4)
    }

    // MARK: - Course Dates Section

    /// Course creation and update dates section
    @ViewBuilder
    private var courseDatesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing3) {
            Text("Información del curso")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: Spacing.spacing2) {
                if let createdAt = course.createdAt {
                    Label {
                        Text("Creado: \(formatDate(createdAt))")
                            .font(.bodyRegular)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.primaryBlue)
                    }
                }

                if let updatedAt = course.updatedAt {
                    Label {
                        Text("Actualizado: \(formatDate(updatedAt))")
                            .font(.bodyRegular)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.spacing4)
    }

    // MARK: - Course Statistics Section

    /// Course ratings and statistics section
    @ViewBuilder
    private var courseStatisticsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing3) {
            Text("Estadísticas")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)

            if let rating = course.averageRating, let totalRatings = course.totalRatings {
                VStack(alignment: .leading, spacing: Spacing.spacing2) {
                    HStack(spacing: Spacing.spacing3) {
                        // Rating display
                        HStack(spacing: Spacing.spacing1) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }

                        Text("\(String(format: "%.1f", rating))")
                            .font(.bodyEmphasized)
                            .foregroundColor(.primary)

                        Text("(\(totalRatings) \(totalRatings == 1 ? "valoración" : "valoraciones"))")
                            .font(.captionRegular)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Calificación \(String(format: "%.1f", rating)) de 5 estrellas, basada en \(totalRatings) valoraciones")
                }
            }
        }
        .padding(.horizontal, Spacing.spacing4)
    }

    // MARK: - Helper Methods

    /// Formats a date to a readable string
    /// - Parameter date: The date to format
    /// - Returns: Formatted date string
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    CourseAboutView(course: Course.mockCourses[0])
        .background(Color.groupedBackground)
}

