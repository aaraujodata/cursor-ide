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
        print("🔒 [CertificateTrustSession] ==================")
        print("🔒 [CertificateTrustSession] Initializing URLSession...")

        // Configure trusted domains for corporate CA certificates
        var trustedDomains: Set<String> = [
            "cdn.mdstrm.com",
            "thumbs.cdn.mdstrm.com"
        ]
        print("🔒 [CertificateTrustSession] Base trusted domains: \(trustedDomains)")

        // Add production API domain if using HTTPS
        if APIConfiguration.isSecure {
            // Extract domain from production URL
            if let url = URL(string: APIConfiguration.baseURL),
               let host = url.host {
                trustedDomains.insert(host)
                print("🔒 [CertificateTrustSession] Added API domain: \(host)")
            }
        } else {
            print("🔒 [CertificateTrustSession] API is not secure (HTTP), skipping API domain")
        }

        // Add Supabase domain to trusted domains
        print("🔒 [CertificateTrustSession] Processing Supabase URL: \(SupabaseConfiguration.supabaseURL)")
        if let supabaseURL = URL(string: SupabaseConfiguration.supabaseURL),
           let host = supabaseURL.host {
            trustedDomains.insert(host)
            print("🔒 [CertificateTrustSession] ✓ Added Supabase domain: \(host)")
            print("🔒 [CertificateTrustSession] Supabase scheme: \(supabaseURL.scheme ?? "unknown")")
            print("🔒 [CertificateTrustSession] Supabase port: \(supabaseURL.port?.description ?? "default")")
        } else {
            print("❌ [CertificateTrustSession] Failed to parse Supabase URL!")
        }

        print("🔒 [CertificateTrustSession] Final trusted domains: \(trustedDomains)")

        // Configure certificate trust manager with all trusted domains
        trustManager = CertificateTrustManager(
            trustedDomains: trustedDomains
        )
        print("🔒 [CertificateTrustSession] Trust manager created")

        // Create URLSessionConfiguration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        print("🔒 [CertificateTrustSession] URLSession configuration:")
        print("🔒 [CertificateTrustSession]   - Request timeout: \(configuration.timeoutIntervalForRequest)s")
        print("🔒 [CertificateTrustSession]   - Resource timeout: \(configuration.timeoutIntervalForResource)s")

        // Create URLSession with delegate for certificate handling
        // The trustManager is retained by this class instance
        urlSession = URLSession(
            configuration: configuration,
            delegate: trustManager,
            delegateQueue: nil
        )
        print("🔒 [CertificateTrustSession] URLSession created with trust manager delegate")
        print("🔒 [CertificateTrustSession] ==================")
    }
}

