import Foundation
import Combine

/// ViewModel responsible for managing the course detail state and business logic
@MainActor
class CourseDetailViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var course: Course?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let courseRepository: CourseRepository

    // MARK: - Initialization

    /// Initializes the ViewModel with dependency injection
    /// - Parameters:
    ///   - course: The course to display (can be nil if loading from API)
    ///   - courseRepository: Repository for course data operations
    init(course: Course? = nil, courseRepository: CourseRepository = RemoteCourseRepository()) {
        self.course = course
        self.courseRepository = courseRepository

        // If course is provided, use it; otherwise load from API if slug is available
        if course == nil {
            // This will be set when navigating with a course
        }
    }

    // MARK: - Public Methods

    /// Loads the course details from the repository using the slug
    /// - Parameter slug: The course slug identifier
    func loadCourseDetail(slug: String) {
        Task {
            await performLoadCourseDetail(slug: slug)
        }
    }

    /// Loads course details using the provided course object
    /// This is useful when we already have basic course info from the list
    /// - Parameter course: The course to display
    func loadCourseDetail(course: Course) {
        // Use the provided course immediately for instant display
        self.course = course

        // Optionally fetch full details from API if needed
        // For now, we'll use the course passed from the list
        // In the future, you might want to fetch additional details
        Task {
            // You can enhance this to fetch full course details with classes, etc.
            // await performLoadCourseDetail(slug: course.slug)
        }
    }

    /// Refreshes the course details
    func refreshCourseDetail() {
        guard let slug = course?.slug else { return }
        Task {
            await performLoadCourseDetail(slug: slug)
        }
    }

    /// Clears error message
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    /// Performs the actual course detail loading operation
    /// - Parameter slug: The course slug to fetch
    private func performLoadCourseDetail(slug: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedCourse = try await courseRepository.getCourseBySlug(slug)
            course = fetchedCourse
        } catch {
            errorMessage = handleError(error)
            // Keep existing course if available
        }

        isLoading = false
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
                return "No se encontró el curso solicitado."
            case 500...599:
                return "Error del servidor. Inténtalo más tarde."
            default:
                return "Error al cargar el curso (Código: \(statusCode))."
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
}

