import Foundation

/// Domain model representing a course in Platziflix
struct Course: Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: String
    let slug: String
    let teacherIds: [Int]
    let teachers: [Teacher]? // Full teacher information when available (from detail endpoint)
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let averageRating: Double?
    let totalRatings: Int?
    let classes: [Class]? // Classes/lessons for this course (from detail endpoint)

    /// Computed property to check if course is active
    var isActive: Bool {
        deletedAt == nil
    }

    /// Computed property for display description (truncated if needed)
    var displayDescription: String {
        if description.count > 100 {
            return String(description.prefix(100)) + "..."
        }
        return description
    }

    /// Computed property to check if course has ratings
    var hasRatings: Bool {
        guard let total = totalRatings else { return false }
        return total > 0
    }

    /// Computed property to check if course has teacher information
    var hasTeacherInfo: Bool {
        if let teachers = teachers, !teachers.isEmpty {
            return true
        }
        return !teacherIds.isEmpty
    }

    /// Computed property to check if course has classes/lessons
    var hasClasses: Bool {
        guard let classes = classes else { return false }
        return !classes.isEmpty
    }
}

// MARK: - Mock Data for Preview
extension Course {
    static let mockCourses: [Course] = [
        Course(
            id: 4,
            name: "Curso de React.js",
            description: "Aprende React.js desde cero hasta avanzado. Domina componentes, hooks, estado, contexto y las mejores prácticas para crear aplicaciones web modernas y escalables.",
            thumbnail: "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_6733882e4711f40de0f1325f_6733882e4711f40de0f13270_13s.jpg?w=640&q=50",
            slug: "curso-de-react",
            teacherIds: [1, 2],
            teachers: [Teacher.mockTeachers[0], Teacher.mockTeachers[1]],
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil,
            averageRating: 4.8,
            totalRatings: 142,
            classes: Class.mockClasses
        ),
        Course(
            id: 5,
            name: "Curso de TypeScript",
            description: "TypeScript para desarrolladores JavaScript. Aprende tipado estático, interfaces, genéricos y cómo mejorar la calidad de tu código con TypeScript.",
            thumbnail: "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_67d87ffbbbb5bef2f6ad3e82_67d87ffbbbb5bef2f6ad3e91_11s.jpg?w=640&q=50",
            slug: "curso-de-typescript",
            teacherIds: [2, 3],
            teachers: nil,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil,
            averageRating: 4.5,
            totalRatings: 89,
            classes: nil
        ),
        Course(
            id: 6,
            name: "Curso de Node.js",
            description: "Backend con Node.js y Express. Construye APIs robustas, maneja bases de datos, autenticación y deploy de aplicaciones del lado del servidor.",
            thumbnail: "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_67f83a7ecf68920dd17d6ee2_67f83a7ecf68920dd17d6ef3_13s.jpg?w=640&q=50",
            slug: "curso-de-nodejs",
            teacherIds: [1, 4],
            teachers: nil,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil,
            averageRating: 4.3,
            totalRatings: 67,
            classes: nil
        ),
        Course(
            id: 7,
            name: "Curso de Vue.js",
            description: "Desarrolla aplicaciones web reactivas con Vue.js. Aprende el framework progresivo más fácil de usar para crear interfaces de usuario interactivas.",
            thumbnail: "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_6733882e4711f40de0f1325f_6733882e4711f40de0f13270_13s.jpg?w=640&q=50",
            slug: "curso-de-vue",
            teacherIds: [2],
            teachers: nil,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil,
            averageRating: 4.6,
            totalRatings: 54,
            classes: nil
        ),
        Course(
            id: 8,
            name: "Curso de Python",
            description: "Python desde cero hasta avanzado. Aprende programación, estructuras de datos, POO y cómo crear aplicaciones web con Django y Flask.",
            thumbnail: "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_67d87ffbbbb5bef2f6ad3e82_67d87ffbbbb5bef2f6ad3e91_11s.jpg?w=640&q=50",
            slug: "curso-de-python",
            teacherIds: [3, 5],
            teachers: nil,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil,
            averageRating: 4.9,
            totalRatings: 201,
            classes: nil
        ),
        Course(
            id: 9,
            name: "Curso de Swift para iOS",
            description: "Desarrolla aplicaciones iOS nativas con Swift y SwiftUI. Aprende desde los fundamentos hasta crear apps profesionales para el App Store.",
            thumbnail: "https://thumbs.cdn.mdstrm.com/thumbs/512e13acaca1ebcd2f000279/thumb_67f83a7ecf68920dd17d6ee2_67f83a7ecf68920dd17d6ef3_13s.jpg?w=640&q=50",
            slug: "curso-de-swift-ios",
            teacherIds: [4, 6],
            teachers: nil,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil,
            averageRating: 4.7,
            totalRatings: 128,
            classes: nil
        )
    ]
}