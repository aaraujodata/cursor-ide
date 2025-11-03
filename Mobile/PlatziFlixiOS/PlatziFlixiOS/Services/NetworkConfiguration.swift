import Foundation

/// Network configuration helper
/// Use this to configure certificate trust settings and API environment
enum NetworkConfiguration {

    /// Configure the API environment
    /// Change this in APIConfiguration.swift to switch between:
    /// - .development: http://localhost:8000
    /// - .production: https://platziflix-api.alexisaraujo.com
    /// - .custom("your-url"): Custom URL
    static func printCurrentConfiguration() {
        APIConfiguration.printConfiguration()
    }

    /// Quick switch to production environment
    /// This is a helper method - actual configuration is in APIConfiguration.swift
    static func useProduction() {
        print("⚠️  To switch to production, update APIConfiguration.current to .production")
        print("📝 File: PlatziFlixiOS/Services/APIConfiguration.swift")
        print("📝 Change: static let current: Environment = .production")
    }

    /// Quick switch to development environment
    /// This is a helper method - actual configuration is in APIConfiguration.swift
    static func useDevelopment() {
        print("⚠️  To switch to development, update APIConfiguration.current to .development")
        print("📝 File: PlatziFlixiOS/Services/APIConfiguration.swift")
        print("📝 Change: static let current: Environment = .development")
    }
}

// MARK: - Environment Detection Helper
extension NetworkConfiguration {
    /// Automatically detect environment based on build configuration
    static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Recommended environment based on build type
    static var recommendedEnvironment: APIConfiguration.Environment {
        return isDebugBuild ? .development : .production
    }
}

