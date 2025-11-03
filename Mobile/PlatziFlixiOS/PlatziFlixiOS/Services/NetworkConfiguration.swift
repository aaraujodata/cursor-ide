import Foundation

/// Network configuration helper
/// Use this to configure certificate trust settings for your app
enum NetworkConfiguration {

    /// Configure the shared NetworkManager with certificate trust settings
    /// Call this in your app's initialization (e.g., PlatziFlixiOSApp)
    static func configureCertificateTrust() {
        // Example configurations:

        // Option 1: Trust specific corporate domains
        // Uncomment and modify with your domains:
        /*
        _ = NetworkManager(
            trustedDomains: [
                "api.company.com",
                "cdn.company.com",
                "snowflakecomputing.com"
            ]
        )
        */

        // Option 2: Allow self-signed certificates (DEVELOPMENT ONLY!)
        // ⚠️ WARNING: Never use this in production!
        // Uncomment only for local development:
        /*
        _ = NetworkManager(
            allowSelfSignedCertificates: true
        )
        */

        // Option 3: Both (recommended for corporate environments)
        // Uncomment and modify:
        /*
        _ = NetworkManager(
            trustedDomains: ["api.company.com"],
            allowSelfSignedCertificates: false  // Set to true only for dev
        )
        */
    }
}

