import Foundation

protocol NetworkService {
    func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws -> Data
}

// MARK: - Default implementation
extension NetworkService {
    func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let data = try await request(endpoint)

        // DEBUG: Log raw JSON for CourseDTO to verify teacher_id is present
        if T.self == [CourseDTO].self {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔍 [Network] RAW JSON for CourseDTO array:")
                print(jsonString.prefix(500)) // First 500 chars
            }
        }

        do {
            let decoder = JSONDecoder()
            // Configure decoder if needed (e.g., date formatting)
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(T.self, from: data)

            // DEBUG: After decode, check if teacher_id was parsed
            if let courses = result as? [CourseDTO] {
                print("✅ [Network] Decoded \(courses.count) courses")
                if let first = courses.first {
                    print("🔍 [Network] First course teacherId: \(first.teacherId ?? [])")
                }
            }

            return result
        } catch {
            print("❌ [Network] Decoding error for \(T.self): \(error)")
            throw NetworkError.decodingError(error)
        }
    }
} 