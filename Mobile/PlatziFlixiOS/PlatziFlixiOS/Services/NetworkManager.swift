import Foundation

// MARK: - Network Manager
final class NetworkManager: NetworkService {
    /// Shared singleton instance
    /// Configure this in your app's initialization if you need certificate trust handling
    static let shared: NetworkManager = {
        // Print API configuration for debugging
        APIConfiguration.printConfiguration()

        // Configure trusted domains for corporate CA certificates
        // Includes: CDN domains and production API domain
        var trustedDomains: Set<String> = [
            "cdn.mdstrm.com",
            "thumbs.cdn.mdstrm.com"
        ]

        // Add production API domain if using HTTPS
        if APIConfiguration.isSecure {
            // Extract domain from production URL
            if let url = URL(string: APIConfiguration.baseURL),
               let host = url.host {
                trustedDomains.insert(host)
                print("🔒 [Network] Added API domain to trusted list: \(host)")
            }
        }

        return NetworkManager(
            trustedDomains: trustedDomains
        )
    }()

    /// Shared URLSession with certificate trust handling
    /// Use this for image loading and other network requests that need certificate trust
    /// This uses CertificateTrustSession.shared which properly retains the trust manager
    static var sharedURLSession: URLSession {
        return CertificateTrustSession.shared.urlSession
    }

    private let urlSession: URLSession
    private let certificateTrustManager: CertificateTrustManager?

    /// Initialize NetworkManager with optional certificate trust configuration
    /// - Parameters:
    ///   - urlSession: Custom URLSession (default: creates one with certificate trust manager)
    ///   - trustedDomains: Set of domains that should trust corporate CAs (e.g., ["api.company.com"])
    ///   - allowSelfSignedCertificates: Whether to allow self-signed certificates (default: false, set to true for development)
    init(
        urlSession: URLSession? = nil,
        trustedDomains: Set<String> = [],
        allowSelfSignedCertificates: Bool = false
    ) {
        // Create URLSession with certificate trust manager if not provided
        if let providedSession = urlSession {
            self.urlSession = providedSession
            self.certificateTrustManager = nil
        } else {
            // Configure certificate trust manager
            // Store it to prevent deallocation (URLSession only holds a weak reference)
            let trustManager = CertificateTrustManager(
                trustedDomains: trustedDomains,
                allowSelfSignedCertificates: allowSelfSignedCertificates
            )
            self.certificateTrustManager = trustManager

            // Create URLSessionConfiguration with certificate trust handling
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60

            // Create URLSession with delegate for certificate handling
            self.urlSession = URLSession(
                configuration: configuration,
                delegate: trustManager,
                delegateQueue: nil
            )
        }
    }

    func request(_ endpoint: APIEndpoint) async throws -> Data {
        guard let urlRequest = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
            }

            return data

        } catch {
            if error is NetworkError {
                throw error
            }

            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    throw NetworkError.networkUnavailable
                case .timedOut:
                    throw NetworkError.timeout
                case .serverCertificateUntrusted, .clientCertificateRejected, .clientCertificateRequired:
                    // Certificate validation errors
                    print("🔒 Certificate error: \(urlError.localizedDescription)")
                    throw NetworkError.certificateValidationFailed
                case .secureConnectionFailed:
                    // SSL/TLS errors
                    print("🔒 SSL/TLS error: \(urlError.localizedDescription)")
                    throw NetworkError.sslError(error)
                default:
                    // Log other URL errors for debugging
                    print("⚠️  URL Error: \(urlError.code.rawValue) - \(urlError.localizedDescription)")
                    throw NetworkError.unknown(error)
                }
            }

            throw NetworkError.unknown(error)
        }
    }
}

// MARK: - Convenience methods
extension NetworkManager {
    func get<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        return try await request(endpoint, responseType: responseType)
    }

    func post<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        return try await request(endpoint, responseType: responseType)
    }

    func put<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        return try await request(endpoint, responseType: responseType)
    }

    func delete<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        return try await request(endpoint, responseType: responseType)
    }

    func patch<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        return try await request(endpoint, responseType: responseType)
    }
}

// MARK: - Request with body encoding
extension NetworkManager {
    func request<T: Codable, U: Codable>(_ endpoint: APIEndpoint, body: U, responseType: T.Type) async throws -> T {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let bodyData = try encoder.encode(body)

            // Create a modified endpoint with the encoded body
            let endpointWithBody = APIEndpointWithBody(
                baseURL: endpoint.baseURL,
                path: endpoint.path,
                method: endpoint.method,
                headers: endpoint.headers,
                parameters: endpoint.parameters,
                body: bodyData
            )

            return try await request(endpointWithBody, responseType: responseType)

        } catch {
            throw NetworkError.encodingError(error)
        }
    }
}

// MARK: - Helper struct for endpoints with body
private struct APIEndpointWithBody: APIEndpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let parameters: [String: Any]?
    let body: Data?
}
