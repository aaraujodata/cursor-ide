import Foundation

/// Singleton that manages a URLSession with certificate trust handling
/// This ensures the CertificateTrustManager is retained and not deallocated
final class CertificateTrustSession {
    static let shared = CertificateTrustSession()

    /// URLSession configured with certificate trust manager
    let urlSession: URLSession

    /// Retains the trust manager to prevent deallocation
    private let trustManager: CertificateTrustManager

    private init() {
        // Configure trusted domains for corporate CA certificates
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
                print("🔒 [CertificateTrustSession] Added API domain: \(host)")
            }
        }

        // Configure certificate trust manager with all trusted domains
        trustManager = CertificateTrustManager(
            trustedDomains: trustedDomains
        )

        // Create URLSessionConfiguration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        // Create URLSession with delegate for certificate handling
        // The trustManager is retained by this class instance
        urlSession = URLSession(
            configuration: configuration,
            delegate: trustManager,
            delegateQueue: nil
        )
    }
}

