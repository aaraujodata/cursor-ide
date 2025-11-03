import SwiftUI

/// Detail view that displays comprehensive information about a selected course
struct CourseDetailView: View {
    @StateObject private var viewModel: CourseDetailViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization

    /// Initializes the detail view with a course
    /// - Parameter course: The course to display
    init(course: Course) {
        // Initialize ViewModel with the course for immediate display
        _viewModel = StateObject(wrappedValue: CourseDetailViewModel(course: course))
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.course == nil {
                // Loading state when no course data available
                loadingView
            } else if let course = viewModel.course {
                // Course content
                courseContent(course: course)
            } else {
                // Error or empty state
                errorView
            }
        }
        .background(Color.groupedBackground)
        .scrollContentBackground(.hidden) // Hide default background to allow custom background
        .navigationTitle(viewModel.course?.name ?? "Detalle del curso")
        .navigationBarTitleDisplayMode(.inline) // Use inline to save vertical space
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.refreshCourseDetail()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.primaryBlue)
                }
                .accessibilityLabel("Recargar curso")
            }
        }
        .refreshable {
            await MainActor.run {
                viewModel.refreshCourseDetail()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - View Components

    /// Main course content view
    /// - Parameter course: The course to display
    /// - Returns: View displaying course information
    @ViewBuilder
    private func courseContent(course: Course) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing4) {
            // Course thumbnail section
            courseThumbnailSection(course: course)

            // Course information and description in a card-style container
            VStack(alignment: .leading, spacing: Spacing.spacing4) {
                // Course title and status
                courseInfoSection(course: course)

                // Divider
                Divider()
                    .padding(.horizontal, Spacing.spacing4)

                // Description section
                courseDescriptionSection(course: course)

                // Metadata section (only if data exists)
                if hasMetadata(course: course) {
                    Divider()
                        .padding(.horizontal, Spacing.spacing4)

                    courseMetadataSection(course: course)
                }
            }
        }
    }

    /// Checks if course has metadata to display
    /// - Parameter course: The course to check
    /// - Returns: True if there's metadata to display
    private func hasMetadata(course: Course) -> Bool {
        return !course.teacherIds.isEmpty || course.createdAt != nil
    }

    /// Course thumbnail header
    /// - Parameter course: The course to display
    /// - Returns: View with course thumbnail
    @ViewBuilder
    private func courseThumbnailSection(course: Course) -> some View {
        // Using SecureAsyncImage to handle corporate CA certificates
        SecureAsyncImage(url: URL(string: course.thumbnail)) { image in
            image
                .resizable()
                .aspectRatio(16/9, contentMode: .fill)
        } placeholder: {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(.systemGray5))
                .aspectRatio(16/9, contentMode: .fit)
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220) // Reduced height for better proportions
        .clipped()
        .accessibilityLabel("Imagen del curso \(course.name)")
    }

    /// Course information section (title, etc.)
    /// - Parameter course: The course to display
    /// - Returns: View with course info
    @ViewBuilder
    private func courseInfoSection(course: Course) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            Text(course.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
                .fixedSize(horizontal: false, vertical: true) // Allow text wrapping

            // Course status badge
            if course.isActive {
                HStack(spacing: Spacing.spacing2) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.successGreen)
                    Text("Curso disponible")
                        .font(.captionRegular)
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Curso disponible")
            }
        }
        .padding(.horizontal, Spacing.spacing4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Course description section
    /// - Parameter course: The course to display
    /// - Returns: View with course description
    @ViewBuilder
    private func courseDescriptionSection(course: Course) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing3) {
            Text("Descripción")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)

            Text(course.description)
                .font(.bodyRegular)
                .foregroundColor(.primary)
                .lineSpacing(6) // Increased line spacing for better readability
                .fixedSize(horizontal: false, vertical: true) // Allow text wrapping
        }
        .padding(.horizontal, Spacing.spacing4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Course metadata section (teachers, dates, etc.)
    /// - Parameter course: The course to display
    /// - Returns: View with course metadata
    @ViewBuilder
    private func courseMetadataSection(course: Course) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing4) {
            // Teachers section
            if !course.teacherIds.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.spacing2) {
                    Text("Instructores")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .accessibilityAddTraits(.isHeader)

                    HStack(spacing: Spacing.spacing2) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.primaryBlue)
                        Text("\(course.teacherIds.count) instructor\(course.teacherIds.count == 1 ? "" : "es")")
                            .font(.bodyRegular)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Course dates section
            if let createdAt = course.createdAt {
                VStack(alignment: .leading, spacing: Spacing.spacing2) {
                    Text("Información del curso")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .accessibilityAddTraits(.isHeader)

                    VStack(alignment: .leading, spacing: Spacing.spacing2) {
                        Label {
                            Text("Creado: \(formatDate(createdAt))")
                                .font(.bodyRegular)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "calendar")
                                .foregroundColor(.primaryBlue)
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
            }
        }
        .padding(.horizontal, Spacing.spacing4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Loading view
    private var loadingView: some View {
        VStack(spacing: Spacing.spacing6) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))

            Text("Cargando curso...")
                .font(.bodyEmphasized)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.spacing8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cargando curso")
    }

    /// Error view
    private var errorView: some View {
        VStack(spacing: Spacing.spacing6) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(.errorRed)

            VStack(spacing: Spacing.spacing3) {
                Text("Error al cargar el curso")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.bodyRegular)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Button("Intentar de nuevo") {
                viewModel.refreshCourseDetail()
            }
            .font(.buttonMedium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.spacing6)
            .padding(.vertical, Spacing.spacing3)
            .background(Color.primaryBlue)
            .cornerRadius(Radius.radiusMedium)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.spacing8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error al cargar el curso")
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

// MARK: - Previews
#Preview("Normal State") {
    NavigationView {
        CourseDetailView(course: Course.mockCourses[0])
    }
}

#Preview("Dark Mode") {
    NavigationView {
        CourseDetailView(course: Course.mockCourses[1])
    }
    .preferredColorScheme(.dark)
}

#Preview("Long Description") {
    NavigationView {
        CourseDetailView(course: Course.mockCourses[0])
    }
}

