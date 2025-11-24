import SwiftUI

/// Main view that displays the list of courses
/// Used as the Home tab in MainTabView
struct CourseListView: View {
    @StateObject private var viewModel = CourseListViewModel()
    @State private var showSearchBar = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background color - using system background for better dark mode
                Color.groupedBackground
                    .ignoresSafeArea()

                if viewModel.isLoadingCourses {
                    // Initial loading state - show skeleton cards
                    loadingView
                } else if viewModel.isEmpty {
                    // Empty state
                    emptyView
                } else {
                    // Course list content with refresh skeleton overlay
                    ZStack {
                        courseListContent

                        // Show skeleton cards during pull-to-refresh
                        if viewModel.isRefreshing {
                            refreshSkeletonOverlay
                        }
                    }
                }
            }
            .navigationTitle("Últimos cursos lanzados")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Search button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSearchBar.toggle()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primaryBlue)
                    }
                    .accessibilityLabel("Buscar cursos")
                }
            }
            .searchable(
                text: $viewModel.searchText,
                isPresented: $showSearchBar,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar cursos..."
            )
            .refreshable {
                await MainActor.run {
                    viewModel.refreshCourses()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - View Components

    /// Skeleton loading view that displays placeholder cards matching the course card layout
    /// Used during initial load - follows modern iOS skeleton loading pattern (2025)
    private var loadingView: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.spacing4) {
                // Display 5 skeleton cards during initial loading
                // This provides immediate visual feedback and matches the expected content structure
                ForEach(0..<5, id: \.self) { _ in
                    CourseCardSkeletonView()
                }
            }
            .padding(.horizontal, Spacing.spacing4)
            .padding(.top, Spacing.spacing2)
            .padding(.bottom, Spacing.spacing6)
        }
        .accessibilityLabel("Cargando cursos")
        .accessibilityHint("Los cursos se están cargando. Por favor espera")
    }

    /// Skeleton overlay shown during pull-to-refresh
    /// Replaces content temporarily to show loading state
    private var refreshSkeletonOverlay: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.spacing4) {
                // Display skeleton cards - show same number as existing courses (max 5)
                // If no courses exist, show 3 skeleton cards for visual feedback
                let skeletonCount = viewModel.filteredCourses.isEmpty
                    ? 3
                    : min(viewModel.filteredCourses.count, 5)

                ForEach(0..<skeletonCount, id: \.self) { _ in
                    CourseCardSkeletonView()
                }
            }
            .padding(.horizontal, Spacing.spacing4)
            .padding(.top, Spacing.spacing2)
            .padding(.bottom, Spacing.spacing6)
        }
        .background(Color.groupedBackground)
        .accessibilityLabel("Actualizando cursos")
        .accessibilityHint("Los cursos se están actualizando. Por favor espera")
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.spacing6) {
            Image(systemName: "book.closed")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: Spacing.spacing3) {
                Text("No hay cursos disponibles")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("Intenta recargar o vuelve más tarde")
                    .font(.bodyRegular)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Recargar") {
                viewModel.refreshCourses()
            }
            .font(.buttonMedium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.spacing6)
            .padding(.vertical, Spacing.spacing3)
            .background(Color.primaryBlue)
            .cornerRadius(Radius.radiusMedium)
        }
        .padding(Spacing.spacing6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No hay cursos disponibles. Intenta recargar o vuelve más tarde")
    }

    private var courseListContent: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.spacing4) {
                // Header section
                if !viewModel.searchText.isEmpty {
                    HStack {
                        Text("Resultados para '\(viewModel.searchText)'")
                            .font(.bodyEmphasized)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.spacing4)
                    .padding(.top, Spacing.spacing2)
                }

                // Course list - Changed from grid to vertical stack
                LazyVStack(spacing: Spacing.spacing4) {
                    ForEach(viewModel.filteredCourses) { course in
                        // Navigation link to course detail view
                        NavigationLink(destination: CourseDetailView(course: course)) {
                            CourseCardView(course: course)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("Curso: \(course.name)")
                        .accessibilityHint("Doble toque para ver los detalles del curso")
                    }
                }
                .padding(.horizontal, Spacing.spacing4)
                .padding(.bottom, Spacing.spacing6)
            }
        }
        .accessibilityLabel("Lista de cursos")
    }
}

// MARK: - Previews
#Preview("Normal State") {
    CourseListView()
}

#Preview("Dark Mode") {
    CourseListView()
        .preferredColorScheme(.dark)
}

#Preview("iPhone SE") {
    CourseListView()
        .previewDevice("iPhone SE (3rd generation)")
}

#Preview("iPad") {
    CourseListView()
        .previewDevice("iPad Pro (11-inch) (4th generation)")
}