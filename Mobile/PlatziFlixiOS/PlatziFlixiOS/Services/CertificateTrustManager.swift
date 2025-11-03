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
        print("🔒 Certificate Trust Challenge:")
        print("   - Protection Space: \(challenge.protectionSpace.host)")
        print("   - Authentication Method: \(challenge.protectionSpace.authenticationMethod)")
        print("   - Server Trust: \(challenge.protectionSpace.serverTrust != nil ? "Present" : "Missing")")

        // Get the server trust object
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            print("❌ No server trust provided")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Get the hostname
        let hostname = challenge.protectionSpace.host

        // Check if this is a trusted domain or localhost (for development)
        // Also check if any trusted domain is a suffix of the hostname (for subdomains)
        let isTrustedDomain = trustedDomains.contains(hostname) ||
                              trustedDomains.contains { domain in
                                  hostname.hasSuffix("." + domain) || hostname == domain
                              } ||
                              hostname.contains("localhost") ||
                              hostname.contains("127.0.0.1")

        // Evaluate the certificate chain using modern API (iOS 13+)
        var error: CFError?
        let isCertificateValid = SecTrustEvaluateWithError(serverTrust, &error)

        // Debug log: Certificate evaluation result
        if let error = error {
            print("   - Trust Evaluation Error: \(error.localizedDescription)")
        } else {
            print("   - Trust Evaluation: Valid")
        }

        // If certificate is valid, accept it
        if isCertificateValid {
            print("✅ Certificate is valid according to system trust")
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            return
        }

        // If it's a trusted domain (corporate CA) or self-signed certs are allowed
        if isTrustedDomain || allowSelfSignedCertificates {
            print("⚠️  Trusting certificate for domain: \(hostname)")
            print("   - Reason: Trusted domain or self-signed allowed")

            // Get certificate chain for debugging
            if let certificateChain = getCertificateChain(from: serverTrust) {
                printCertificateInfo(certificateChain)
            }

            // Create credential and accept the challenge
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            return
        }

        // Default: Cancel the challenge if certificate is not trusted
        print("❌ Certificate validation failed for: \(hostname)")
        print("   - Certificate is not in system trust store")
        print("   - Domain is not in trusted domains list")
        print("   - Self-signed certificates are not allowed")
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

