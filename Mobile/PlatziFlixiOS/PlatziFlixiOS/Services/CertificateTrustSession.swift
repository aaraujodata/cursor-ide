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
        // Configure certificate trust manager with corporate domains
        trustManager = CertificateTrustManager(
            trustedDomains: [
                "cdn.mdstrm.com",
                "thumbs.cdn.mdstrm.com"
            ]
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

