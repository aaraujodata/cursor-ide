import Foundation

/// API Configuration for different environments
struct APIConfiguration {

    /// Current environment
    /// Change this to switch between development and production
    /// - .development: Use for iOS Simulator (connects to localhost on Mac)
    /// - .production: Use for Physical Device (connects to HTTPS via Cloudflare)
    static let current: Environment = .development

    /// Available environments
    enum Environment {
        case development  // Localhost for testing
        case production   // Cloudflare Tunnel HTTPS
        case custom(String) // Custom base URL

        /// Base URL for the API
        var baseURL: String {
            switch self {
            case .development:
                // Local development server
                return "http://localhost:8000"
            case .production:
                // Cloudflare Tunnel HTTPS endpoint
                return "https://platziflix-api.alexisaraujo.com"
            case .custom(let url):
                return url
            }
        }

        /// Whether the environment uses HTTPS
        var isSecure: Bool {
            switch self {
            case .development:
                return false
            case .production:
                return true
            case .custom(let url):
                return url.hasPrefix("https://")
            }
        }

        /// Display name for debugging
        var displayName: String {
            switch self {
            case .development:
                return "Development (localhost)"
            case .production:
                return "Production (Cloudflare HTTPS)"
            case .custom(let url):
                return "Custom (\(url))"
            }
        }
    }

    /// Get the current base URL
    static var baseURL: String {
        let url = current.baseURL
        print("🌐 [API Config] Using environment: \(current.displayName)")
        print("🌐 [API Config] Base URL: \(url)")
        print("🌐 [API Config] Secure (HTTPS): \(current.isSecure)")
        return url
    }

    /// Check if current environment is secure (HTTPS)
    static var isSecure: Bool {
        return current.isSecure
    }

    /// Print current configuration (for debugging)
    static func printConfiguration() {
        print("📋 [API Config] ==================")
        print("📋 [API Config] Environment: \(current.displayName)")
        print("📋 [API Config] Base URL: \(baseURL)")
        print("📋 [API Config] Secure: \(isSecure)")
        print("📋 [API Config] ==================")
    }
}

