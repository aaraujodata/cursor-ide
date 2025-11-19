//
//  AuthServiceFactory.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import Foundation
import Supabase

/// Factory for creating authentication services
/// Provides a centralized way to create and configure auth repositories
/// Follows dependency injection pattern for better testability
struct AuthServiceFactory {

    /// Creates an authentication repository instance
    /// Currently returns Supabase implementation
    /// Can be extended to support other providers or mock implementations
    /// - Returns: Configured AuthRepository instance
    static func createAuthRepository() -> AuthRepository {
        print("🔐 [AuthServiceFactory] ==================")
        print("🔐 [AuthServiceFactory] Creating auth repository...")

        // Validate configuration
        print("🔐 [AuthServiceFactory] Validating Supabase configuration...")
        guard SupabaseConfiguration.isValid() else {
            print("❌ [AuthServiceFactory] Invalid Supabase configuration")
            print("❌ [AuthServiceFactory] Falling back to mock repository")
            return MockAuthRepository()
        }
        print("🔐 [AuthServiceFactory] ✓ Configuration valid")

        // Initialize Supabase client
        print("🔐 [AuthServiceFactory] Parsing Supabase URL: \(SupabaseConfiguration.supabaseURL)")
        guard let supabaseURL = URL(string: SupabaseConfiguration.supabaseURL) else {
            print("❌ [AuthServiceFactory] Invalid Supabase URL: \(SupabaseConfiguration.supabaseURL)")
            return MockAuthRepository()
        }
        print("🔐 [AuthServiceFactory] ✓ URL parsed successfully")
        print("🔐 [AuthServiceFactory]   - Scheme: \(supabaseURL.scheme ?? "unknown")")
        print("🔐 [AuthServiceFactory]   - Host: \(supabaseURL.host ?? "unknown")")
        print("🔐 [AuthServiceFactory]   - Port: \(supabaseURL.port?.description ?? "default")")

        // Use the shared certificate trust session for proper TLS handling
        print("🔐 [AuthServiceFactory] Getting custom URLSession from CertificateTrustSession...")
        let urlSession = CertificateTrustSession.shared.urlSession
        print("🔐 [AuthServiceFactory] ✓ Got URLSession with certificate trust manager")
        print("🔐 [AuthServiceFactory] URLSession delegate: \(String(describing: urlSession.delegate))")

        // Initialize Supabase client with custom URLSession
        // This ensures proper certificate handling for HTTPS connections
        print("🔐 [AuthServiceFactory] Creating Supabase client with custom URLSession...")
        let supabase = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: SupabaseConfiguration.supabaseAnonKey,
            options: SupabaseClientOptions(
                global: SupabaseClientOptions.GlobalOptions(
                    session: urlSession
                )
            )
        )
        print("🔐 [AuthServiceFactory] ✓ Supabase client created")

        print("✅ [AuthServiceFactory] Creating Supabase auth repository")
        print("🔐 [AuthServiceFactory] URL: \(SupabaseConfiguration.supabaseURL)")
        print("🔐 [AuthServiceFactory] ==================")

        return SupabaseAuthRepository(supabaseClient: supabase)
    }
}

/// Mock implementation for development/testing
/// Remove this once Supabase SDK is integrated
private struct MockAuthRepository: AuthRepository {
    func getCurrentSession() async throws -> AuthSession? { nil }
    func signInWithEmail(email: String, password: String) async throws -> AuthSession {
        throw AuthError.unknown(NSError(domain: "MockAuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not integrated"]))
    }
    func signUpWithEmail(email: String, password: String) async throws -> AuthSession {
        throw AuthError.unknown(NSError(domain: "MockAuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not integrated"]))
    }
    func signInWithProvider(_ provider: AuthProvider) async throws -> AuthSession {
        throw AuthError.unknown(NSError(domain: "MockAuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not integrated"]))
    }
    func signOut() async throws {}
    func refreshSession() async throws -> AuthSession {
        throw AuthError.unknown(NSError(domain: "MockAuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not integrated"]))
    }
    func updateUserProfile(fullName: String?, givenName: String?, familyName: String?, avatarURL: String?) async throws -> User {
        throw AuthError.unknown(NSError(domain: "MockAuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not integrated"]))
    }
    func resetPassword(email: String) async throws {}
    func getCurrentSessionResult() async -> Result<AuthSession?, Error> { .success(nil) }
    func signInWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error> {
        .failure(AuthError.unknown(NSError(domain: "MockAuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not integrated"])))
    }
    func signUpWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error> {
        .failure(AuthError.unknown(NSError(domain: "MockAuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not integrated"])))
    }
    func signInWithProviderResult(_ provider: AuthProvider) async -> Result<AuthSession, Error> {
        .failure(AuthError.unknown(NSError(domain: "MockAuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Supabase SDK not integrated"])))
    }
}

