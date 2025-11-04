import Foundation
import Combine

/// ViewModel responsible for managing the course list state and business logic
@MainActor
class CourseListViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var courses: [Course] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    // MARK: - Computed Properties

    /// Filtered courses based on search text
    var filteredCourses: [Course] {
        if searchText.isEmpty {
            return courses
        }
        return courses.filter { course in
            course.name.localizedCaseInsensitiveContains(searchText) ||
            course.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    /// Whether there are no courses to display
    var isEmpty: Bool {
        filteredCourses.isEmpty && !isLoading
    }

    /// Loading state for UI feedback
    var isLoadingCourses: Bool {
        isLoading && courses.isEmpty
    }

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let courseRepository: CourseRepository

    // MARK: - Initialization

    /// Initializes the ViewModel with dependency injection
    /// - Parameter courseRepository: Repository for course data operations
    init(courseRepository: CourseRepository = RemoteCourseRepository()) {
        self.courseRepository = courseRepository
        setupBindings()
        loadCourses()
    }

    // MARK: - Public Methods

    /// Loads the courses from the repository
    func loadCourses() {
        Task {
            await performLoadCourses()
        }
    }

    /// Refreshes the course list (pull-to-refresh)
    /// Sets isRefreshing flag to show skeleton loading during refresh
    func refreshCourses() {
        Task {
            await performRefreshCourses()
        }
    }

    /// Handles course selection
    /// Note: Navigation is now handled by NavigationLink in CourseListView
    /// This method is kept for potential future use (analytics, etc.)
    func selectCourse(_ course: Course) {
        // Navigation is handled by NavigationLink in the view
        // This method can be used for analytics or other side effects
        print("Selected course: \(course.name)")
    }

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    /// Performs the actual course loading operation (initial load)
    private func performLoadCourses() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedCourses = try await courseRepository.getAllCourses()
            courses = fetchedCourses
        } catch {
            errorMessage = handleError(error)
            courses = []
        }

        isLoading = false
    }

    /// Performs refresh operation (pull-to-refresh)
    /// Uses isRefreshing flag to show skeleton loading during refresh
    private func performRefreshCourses() async {
        isRefreshing = true
        errorMessage = nil

        do {
            let fetchedCourses = try await courseRepository.getAllCourses()
            courses = fetchedCourses
        } catch {
            errorMessage = handleError(error)
            // Don't clear courses on refresh error - keep existing data
        }

        isRefreshing = false
    }

    /// Handles and formats error messages for user display
    /// - Parameter error: The error to handle
    /// - Returns: User-friendly error message
    private func handleError(_ error: Error) -> String {
        switch error {
        case NetworkError.networkUnavailable:
            return "No hay conexión a internet. Verifica tu conexión e inténtalo de nuevo."
        case NetworkError.timeout:
            return "La solicitud tardó demasiado. Inténtalo de nuevo."
        case NetworkError.requestFailed(let statusCode):
            switch statusCode {
            case 404:
                return "No se encontraron cursos disponibles."
            case 500...599:
                return "Error del servidor. Inténtalo más tarde."
            default:
                return "Error al cargar los cursos (Código: \(statusCode))."
            }
        case NetworkError.decodingError:
            return "Error al procesar los datos del servidor."
        case NetworkError.invalidURL:
            return "Error de configuración de la aplicación."
        case NetworkError.certificateValidationFailed:
            return "Error de certificado de seguridad. Verifica tu conexión."
        case NetworkError.sslError:
            return "Error de conexión segura. Inténtalo de nuevo."
        default:
            return "Error inesperado. Inténtalo de nuevo."
        }
    }

    private func setupBindings() {
        // Debounce search text changes for better performance
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _ in
                // Search filtering is handled by computed property
            }
            .store(in: &cancellables)
    }
}