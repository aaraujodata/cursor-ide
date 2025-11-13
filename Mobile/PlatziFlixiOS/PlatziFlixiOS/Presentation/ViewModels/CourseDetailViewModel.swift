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

        // Always load full course details to get classes and complete information
        // The list endpoint doesn't include classes, so we need to fetch the detail
        if let course = course {
            print("🔄 [CourseDetailViewModel] Initializing with course, will load full details")
            print("   - Course slug: \(course.slug)")
            print("   - Current classes count: \(course.classes?.count ?? 0)")

            // Always fetch full details to get classes and complete metadata
            Task {
                await performLoadCourseDetail(slug: course.slug)
            }
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

        // Fetch full details from API (teachers, classes, complete rating info, etc.)
        Task {
            await performLoadCourseDetail(slug: course.slug)
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
        print("📥 [CourseDetailViewModel] Loading course detail for slug: \(slug)")
        isLoading = true
        errorMessage = nil

        do {
            let fetchedCourse = try await courseRepository.getCourseBySlug(slug)
            print("✅ [CourseDetailViewModel] Course loaded successfully:")
            print("   - Course ID: \(fetchedCourse.id)")
            print("   - Course Name: \(fetchedCourse.name)")
            print("   - Classes count: \(fetchedCourse.classes?.count ?? 0)")
            print("   - Has classes: \(fetchedCourse.hasClasses)")
            if let classes = fetchedCourse.classes {
                print("   - Classes: \(classes.map { "\($0.id): \($0.name)" })")
            }
            course = fetchedCourse
        } catch {
            print("❌ [CourseDetailViewModel] Error loading course: \(error)")
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

