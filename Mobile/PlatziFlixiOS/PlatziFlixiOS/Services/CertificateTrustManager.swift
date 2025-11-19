import Foundation
import Security

/// Manages certificate trust validation for corporate CA certificates
/// Handles certificate validation challenges from URLSession
final class CertificateTrustManager: NSObject, URLSessionDelegate {

    // MARK: - Configuration

    /// Domains that should trust corporate certificates
    /// Add your corporate domains here if needed
    private let trustedDomains: Set<String>

    /// Whether to allow self-signed certificates (for development/testing)
    /// Set to false in production
    private let allowSelfSignedCertificates: Bool

    // MARK: - Initialization

    /// Initialize the certificate trust manager
    /// - Parameters:
    ///   - trustedDomains: Set of domains that should trust corporate CAs (optional)
    ///   - allowSelfSignedCertificates: Whether to allow self-signed certificates (default: false)
    init(
        trustedDomains: Set<String> = [],
        allowSelfSignedCertificates: Bool = false
    ) {
        self.trustedDomains = trustedDomains
        self.allowSelfSignedCertificates = allowSelfSignedCertificates
        super.init()
    }

    // MARK: - URLSessionDelegate

    /// Handles certificate validation challenges
    /// This method is called when URLSession encounters a certificate that doesn't match system trust
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Debug log: Log the challenge details
        print("🔒 [CertificateTrust] ==================")
        print("🔒 [CertificateTrust] Certificate Trust Challenge Received")
        print("🔒 [CertificateTrust] Protection Space:")
        print("🔒 [CertificateTrust]   - Host: \(challenge.protectionSpace.host)")
        print("🔒 [CertificateTrust]   - Port: \(challenge.protectionSpace.port)")
        print("🔒 [CertificateTrust]   - Protocol: \(challenge.protectionSpace.protocol ?? "unknown")")
        print("🔒 [CertificateTrust]   - Auth Method: \(challenge.protectionSpace.authenticationMethod)")
        print("🔒 [CertificateTrust]   - Server Trust: \(challenge.protectionSpace.serverTrust != nil ? "Present" : "Missing")")

        // Get the server trust object
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            print("❌ [CertificateTrust] No server trust provided - rejecting")
            print("🔒 [CertificateTrust] ==================")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Get the hostname
        let hostname = challenge.protectionSpace.host
        print("🔒 [CertificateTrust] Evaluating certificate for: \(hostname)")
        print("🔒 [CertificateTrust] Trusted domains list: \(trustedDomains)")

        // Check if this is a trusted domain or localhost (for development)
        // Also check if any trusted domain is a suffix of the hostname (for subdomains)
        let isTrustedDomain = trustedDomains.contains(hostname) ||
                              trustedDomains.contains { domain in
                                  hostname.hasSuffix("." + domain) || hostname == domain
                              } ||
                              hostname.contains("localhost") ||
                              hostname.contains("127.0.0.1")

        print("🔒 [CertificateTrust] Is trusted domain? \(isTrustedDomain)")
        print("🔒 [CertificateTrust] Allow self-signed? \(allowSelfSignedCertificates)")

        // Evaluate the certificate chain using modern API (iOS 13+)
        print("🔒 [CertificateTrust] Evaluating certificate with system trust...")
        var error: CFError?
        let isCertificateValid = SecTrustEvaluateWithError(serverTrust, &error)

        // Debug log: Certificate evaluation result
        if let error = error {
            print("❌ [CertificateTrust] Trust Evaluation Error: \(error.localizedDescription)")
            // Bridge CFError to NSError for accessing code and domain
            let nsError = error as Error as NSError
            print("❌ [CertificateTrust] Error code: \(nsError.code)")
            print("❌ [CertificateTrust] Error domain: \(nsError.domain)")
        } else {
            print("✅ [CertificateTrust] Trust Evaluation: Valid")
        }

        // If certificate is valid, accept it
        if isCertificateValid {
            print("✅ [CertificateTrust] Certificate is valid according to system trust")
            let credential = URLCredential(trust: serverTrust)
            print("✅ [CertificateTrust] Using credential - accepting connection")
            print("🔒 [CertificateTrust] ==================")
            completionHandler(.useCredential, credential)
            return
        }

        // If it's a trusted domain (corporate CA) or self-signed certs are allowed
        if isTrustedDomain || allowSelfSignedCertificates {
            print("⚠️  [CertificateTrust] Trusting certificate for domain: \(hostname)")
            print("⚠️  [CertificateTrust] Reason: \(isTrustedDomain ? "Domain in trusted list" : "Self-signed allowed")")

            // Get certificate chain for debugging
            if let certificateChain = getCertificateChain(from: serverTrust) {
                printCertificateInfo(certificateChain)
            }

            // Create credential and accept the challenge
            let credential = URLCredential(trust: serverTrust)
            print("⚠️  [CertificateTrust] Using credential - accepting connection")
            print("🔒 [CertificateTrust] ==================")
            completionHandler(.useCredential, credential)
            return
        }

        // Default: Cancel the challenge if certificate is not trusted
        print("❌ [CertificateTrust] Certificate validation FAILED for: \(hostname)")
        print("❌ [CertificateTrust] Rejection reasons:")
        print("❌ [CertificateTrust]   - Certificate is not in system trust store")
        print("❌ [CertificateTrust]   - Domain '\(hostname)' is NOT in trusted domains list")
        print("❌ [CertificateTrust]   - Self-signed certificates are NOT allowed")
        print("❌ [CertificateTrust] CANCELING authentication challenge")
        print("🔒 [CertificateTrust] ==================")
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    // MARK: - Private Helpers

    /// Extracts certificate chain from server trust
    /// - Parameter serverTrust: The SecTrust object
    /// - Returns: Array of SecCertificate objects
    private func getCertificateChain(from serverTrust: SecTrust) -> [SecCertificate]? {
        // Use modern API for iOS 15+ (falls back to older API for compatibility)
        if #available(iOS 15.0, *) {
            if let chain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] {
                return chain
            }
        }

        // Fallback for older iOS versions (< 15.0)
        // Note: Using deprecated API for backwards compatibility
        // We suppress the deprecation warning since this code only runs on iOS < 15
        let count = SecTrustGetCertificateCount(serverTrust)
        guard count > 0 else { return nil }

        var certificates: [SecCertificate] = []
        for index in 0..<count {
            // This deprecated API is still valid and necessary for iOS < 15 support
            // The deprecation warning is acceptable since we only use this for older iOS versions
            // Note: We check availability above, so this only executes on iOS < 15
            let certificate: SecCertificate?
            if #available(iOS 15.0, *) {
                // Should not reach here due to check above, but compiler needs this
                certificate = nil
            } else {
                // Intentionally using deprecated API for iOS < 15 compatibility
                certificate = SecTrustGetCertificateAtIndex(serverTrust, index)
            }
            if let cert = certificate {
                certificates.append(cert)
            }
        }
        return certificates
    }

    /// Prints certificate information for debugging
    /// - Parameter certificates: Array of certificates to print
    private func printCertificateInfo(_ certificates: [SecCertificate]) {
        print("📜 Certificate Chain (\(certificates.count) certificate(s)):")
        for (index, cert) in certificates.enumerated() {
            var subject: CFString?

            // Get subject
            SecCertificateCopyCommonName(cert, &subject)

            if let subjectString = subject as String? {
                print("   [\(index)] Subject: \(subjectString)")
            } else {
                print("   [\(index)] Subject: Unknown")
            }
        }
    }
}

