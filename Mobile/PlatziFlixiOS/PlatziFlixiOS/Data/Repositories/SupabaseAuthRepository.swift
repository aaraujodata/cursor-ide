//
//  SupabaseAuthRepository.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import Foundation
import Supabase
import UIKit
import AuthenticationServices

/// Supabase implementation of AuthRepository protocol
/// Handles all authentication operations using Supabase Auth
final class SupabaseAuthRepository: AuthRepository {

    // MARK: - Properties

    /// Supabase client instance
    private let supabase: SupabaseClient

    // MARK: - Initialization

    /// Initializes the repository with Supabase client
    /// - Parameter supabaseClient: Configured Supabase client instance
    init(supabaseClient: SupabaseClient) {
        self.supabase = supabaseClient
        print("🔐 [SupabaseAuthRepository] Initialized")
    }

    // MARK: - Session Management

    func getCurrentSession() async throws -> AuthSession? {
        print("🔐 [Auth] Getting current session...")

        do {
            let session = try await supabase.auth.session
            return mapToAuthSession(session: session)
        } catch {
            // If no session exists, return nil (not an error)
            if let authError = error as? AuthError, case .sessionExpired = authError {
                return nil
            }
            // For other errors, return nil (user is not authenticated)
            print("⚠️ [Auth] No active session: \(error.localizedDescription)")
            return nil
        }
    }

    func signInWithEmail(email: String, password: String) async throws -> AuthSession {
        print("🔐 [Auth] ==================")
        print("🔐 [Auth] Signing in with email: \(email)")

        // Validate email format
        print("🔐 [Auth] Validating email format...")
        guard isValidEmail(email) else {
            print("❌ [Auth] Invalid email format")
            throw AuthError.invalidEmail
        }
        print("🔐 [Auth] ✓ Email format valid")

        // Validate password strength
        print("🔐 [Auth] Validating password strength...")
        guard password.count >= 6 else {
            print("❌ [Auth] Password too weak (< 6 characters)")
            throw AuthError.weakPassword
        }
        print("🔐 [Auth] ✓ Password strength valid")

        print("🔐 [Auth] Attempting Supabase sign in...")
        print("🔐 [Auth] Target: \(SupabaseConfiguration.supabaseURL)/auth/v1/token")

        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            print("✅ [Auth] Sign in successful")
            print("🔐 [Auth] Session access token: \(session.accessToken.prefix(20))...")
            print("🔐 [Auth] User ID: \(session.user.id)")
            print("🔐 [Auth] ==================")
            return mapToAuthSession(session: session)
        } catch {
            print("❌ [Auth] Sign in error: \(error.localizedDescription)")
            print("❌ [Auth] Error type: \(type(of: error))")
            print("❌ [Auth] Error details: \(error)")

            // Check if it's a network error
            if let urlError = error as? URLError {
                print("❌ [Auth] URLError code: \(urlError.code.rawValue)")
                print("❌ [Auth] URLError description: \(urlError.localizedDescription)")
                // Get underlying error from userInfo dictionary
                if let underlyingError = urlError.errorUserInfo[NSUnderlyingErrorKey] {
                    print("❌ [Auth] Underlying error: \(underlyingError)")
                }
            }

            print("🔐 [Auth] ==================")
            throw mapSupabaseError(error)
        }
    }

    func signUpWithEmail(email: String, password: String) async throws -> AuthSession {
        print("🔐 [Auth] ==================")
        print("🔐 [Auth] Signing up with email: \(email)")

        // Validate email format
        print("🔐 [Auth] Validating email format...")
        guard isValidEmail(email) else {
            print("❌ [Auth] Invalid email format")
            throw AuthError.invalidEmail
        }
        print("🔐 [Auth] ✓ Email format valid")

        // Validate password strength
        print("🔐 [Auth] Validating password strength...")
        guard password.count >= 6 else {
            print("❌ [Auth] Password too weak (< 6 characters)")
            throw AuthError.weakPassword
        }
        print("🔐 [Auth] ✓ Password strength valid")

        print("🔐 [Auth] Attempting Supabase sign up...")
        print("🔐 [Auth] Target: \(SupabaseConfiguration.supabaseURL)/auth/v1/signup")

        do {
            let response = try await supabase.auth.signUp(email: email, password: password)
            guard let session = response.session else {
                // If email confirmation is required, session might be nil
                print("⚠️ [Auth] Email confirmation required")
                print("🔐 [Auth] ==================")
                throw AuthError.providerError("Email confirmation required. Please check your email.")
            }
            print("✅ [Auth] Sign up successful")
            print("🔐 [Auth] Session access token: \(session.accessToken.prefix(20))...")
            print("🔐 [Auth] User ID: \(session.user.id)")
            print("🔐 [Auth] User email: \(session.user.email ?? "unknown")")
            print("🔐 [Auth] ==================")
            return mapToAuthSession(session: session)
        } catch {
            print("❌ [Auth] Sign up error: \(error.localizedDescription)")
            print("❌ [Auth] Error type: \(type(of: error))")
            print("❌ [Auth] Error details: \(error)")

            // Check if it's a network error
            if let urlError = error as? URLError {
                print("❌ [Auth] URLError code: \(urlError.code.rawValue)")
                print("❌ [Auth] URLError description: \(urlError.localizedDescription)")
                if let underlyingError = urlError.errorUserInfo[NSUnderlyingErrorKey] {
                    print("❌ [Auth] Underlying error: \(underlyingError)")
                }
            }

            print("🔐 [Auth] ==================")
            throw mapSupabaseError(error)
        }
    }

    func signInWithProvider(_ provider: AuthProvider) async throws -> AuthSession {
        print("🔐 [Auth] Signing in with provider: \(provider.displayName)")

        // TODO: Implement with Supabase Swift SDK
        // For native iOS, we'll use Apple's AuthenticationServices framework
        // For OAuth providers, we'll use Supabase's OAuth flow

        switch provider {
        case .apple:
            // Use native Sign in with Apple
            return try await signInWithAppleNative()
        case .google, .facebook:
            // Use OAuth flow
            return try await signInWithOAuth(provider: provider)
        case .email:
            throw AuthError.providerError("Email provider requires email and password")
        }
    }

    func signOut() async throws {
        print("🔐 [Auth] Signing out...")

        do {
            try await supabase.auth.signOut()
            print("✅ [Auth] Sign out successful")
        } catch {
            print("❌ [Auth] Sign out error: \(error.localizedDescription)")
            throw mapSupabaseError(error)
        }
    }

    func refreshSession() async throws -> AuthSession {
        print("🔐 [Auth] Refreshing session...")

        do {
            let session = try await supabase.auth.refreshSession()
            return mapToAuthSession(session: session)
        } catch {
            print("❌ [Auth] Refresh session error: \(error.localizedDescription)")
            throw mapSupabaseError(error)
        }
    }

    // MARK: - User Management

    func updateUserProfile(
        fullName: String?,
        givenName: String?,
        familyName: String?,
        avatarURL: String?
    ) async throws -> User {
        print("🔐 [Auth] Updating user profile...")

        // Build update data dictionary
        var updateData: [String: AnyJSON] = [:]
        if let fullName = fullName {
            updateData["full_name"] = .string(fullName)
        }
        if let givenName = givenName {
            updateData["given_name"] = .string(givenName)
        }
        if let familyName = familyName {
            updateData["family_name"] = .string(familyName)
        }
        if let avatarURL = avatarURL {
            updateData["avatar_url"] = .string(avatarURL)
        }

        do {
            let user = try await supabase.auth.update(user: UserAttributes(data: updateData))
            return mapToUser(user: user)
        } catch {
            print("❌ [Auth] Update profile error: \(error.localizedDescription)")
            throw mapSupabaseError(error)
        }
    }

    func resetPassword(email: String) async throws {
        print("🔐 [Auth] Resetting password for email: \(email)")

        // Validate email format
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        do {
            try await supabase.auth.resetPasswordForEmail(email)
            print("✅ [Auth] Password reset email sent")
        } catch {
            print("❌ [Auth] Reset password error: \(error.localizedDescription)")
            throw mapSupabaseError(error)
        }
    }

    // MARK: - Result-based Methods

    func getCurrentSessionResult() async -> Result<AuthSession?, Error> {
        do {
            let session = try await getCurrentSession()
            return .success(session)
        } catch {
            return .failure(error)
        }
    }

    func signInWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error> {
        do {
            let session = try await signInWithEmail(email: email, password: password)
            return .success(session)
        } catch {
            return .failure(error)
        }
    }

    func signUpWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error> {
        do {
            let session = try await signUpWithEmail(email: email, password: password)
            return .success(session)
        } catch {
            return .failure(error)
        }
    }

    func signInWithProviderResult(_ provider: AuthProvider) async -> Result<AuthSession, Error> {
        do {
            let session = try await signInWithProvider(provider)
            return .success(session)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Private Helpers

    /// Validates email format using basic regex
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// Signs in with Apple using native AuthenticationServices
    private func signInWithAppleNative() async throws -> AuthSession {
        // This will be implemented in a separate service
        // See AppleAuthService.swift
        throw AuthError.unknown(NSError(domain: "NotImplemented", code: -1))
    }

    /// Signs in with OAuth provider (Google, Facebook)
    /// Uses ASWebAuthenticationSession for web-based OAuth flow
    private func signInWithOAuth(provider: AuthProvider) async throws -> AuthSession {
        print("🔐 [Auth] ==================")
        print("🔐 [Auth] Starting OAuth flow for provider: \(provider.displayName)")

        // For Google, use the native GoogleSignIn SDK via GoogleAuthService
        if provider == .google {
            return try await signInWithGoogleNative()
        }

        // For other providers, use web-based OAuth with ASWebAuthenticationSession
        print("🔐 [Auth] Using web-based OAuth flow")

        do {
            // Use Supabase's signInWithOAuth with ASWebAuthenticationSession
            let session = try await supabase.auth.signInWithOAuth(
                provider: mapToSupabaseProvider(provider)
            ) { (session: ASWebAuthenticationSession) in
                // Configure the ASWebAuthenticationSession
                session.prefersEphemeralWebBrowserSession = false
            }

            print("✅ [Auth] OAuth sign in successful")
            print("🔐 [Auth] ==================")
            return mapToAuthSession(session: session)

        } catch {
            print("❌ [Auth] OAuth error: \(error.localizedDescription)")
            print("🔐 [Auth] ==================")
            throw mapSupabaseError(error)
        }
    }

    /// Native Google Sign-In using GoogleSignIn SDK
    @MainActor
    private func signInWithGoogleNative() async throws -> AuthSession {
        print("🔵 [Auth] Using native Google Sign-In")

        // Get the presenting view controller (must be on main thread)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.rootViewController else {
            print("❌ [Auth] Could not get presenting view controller")
            throw AuthError.providerError("Could not present Google Sign-In")
        }

        // Configure GoogleAuthService with Supabase client
        GoogleAuthService.shared.configure(with: supabase)

        do {
            // signIn is also @MainActor, so this is safe
            let session = try await GoogleAuthService.shared.signIn(presenting: viewController)
            return mapToAuthSession(session: session)
        } catch let error as GoogleAuthError {
            print("❌ [Auth] Google Sign-In error: \(error.localizedDescription)")
            throw AuthError.providerError(error.localizedDescription)
        } catch {
            print("❌ [Auth] Unexpected Google Sign-In error: \(error.localizedDescription)")
            throw mapSupabaseError(error)
        }
    }

    /// Maps our AuthProvider to Supabase Provider
    private func mapToSupabaseProvider(_ provider: AuthProvider) -> Provider {
        switch provider {
        case .google:
            return .google
        case .apple:
            return .apple
        case .facebook:
            return .facebook
        case .email:
            fatalError("Email provider should not use OAuth flow")
        }
    }

    // MARK: - Mapping Functions

    /// Maps Supabase Session to AuthSession domain model
    private func mapToAuthSession(session: Session) -> AuthSession {
        let user = mapToUser(user: session.user)

        // Convert expiresAt from TimeInterval to Date
        let expiresAt = Date(timeIntervalSince1970: session.expiresAt)

        return AuthSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            expiresAt: expiresAt,
            user: user
        )
    }

    /// Maps Supabase User to User domain model
    private func mapToUser(user: Supabase.User) -> User {
        // Extract user metadata (already [String: AnyJSON] type)
        let metadata = user.userMetadata
        let appMetadata = user.appMetadata

        // Helper to extract string from [String: AnyJSON] dictionary
        func extractString(from dict: [String: AnyJSON], key: String) -> String? {
            guard let value = dict[key],
                  case .string(let str) = value else {
                return nil
            }
            return str
        }

        // Get full name from metadata
        let fullName = extractString(from: metadata, key: "full_name") ??
                      extractString(from: appMetadata, key: "full_name")
        let givenName = extractString(from: metadata, key: "given_name") ??
                       extractString(from: appMetadata, key: "given_name")
        let familyName = extractString(from: metadata, key: "family_name") ??
                        extractString(from: appMetadata, key: "family_name")
        let avatarURL = extractString(from: metadata, key: "avatar_url") ??
                       extractString(from: appMetadata, key: "avatar_url")

        // Get provider from identities or metadata
        var provider: String? = user.identities?.first?.provider
        if provider == nil {
            provider = extractString(from: appMetadata, key: "provider")
        }

        return User(
            id: user.id.uuidString,
            email: user.email,
            fullName: fullName,
            givenName: givenName,
            familyName: familyName,
            avatarURL: avatarURL,
            provider: provider,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
        )
    }

    /// Maps Supabase errors to AuthError domain errors
    private func mapSupabaseError(_ error: Error) -> AuthError {
        // Check if it's already an AuthError
        if let authError = error as? AuthError {
            return authError
        }

        let errorDescription = error.localizedDescription.lowercased()

        // Map common Supabase auth errors
        if errorDescription.contains("invalid login credentials") ||
           errorDescription.contains("invalid credentials") {
            return .invalidCredentials
        }

        if errorDescription.contains("user not found") {
            return .userNotFound
        }

        if errorDescription.contains("email already registered") ||
           errorDescription.contains("user already registered") {
            return .emailAlreadyExists
        }

        if errorDescription.contains("password") && errorDescription.contains("weak") {
            return .weakPassword
        }

        if errorDescription.contains("invalid email") {
            return .invalidEmail
        }

        if errorDescription.contains("session") && errorDescription.contains("expired") {
            return .sessionExpired
        }

        // Check for network errors
        if let urlError = error as? URLError {
            return .networkError(urlError.localizedDescription)
        }

        // Default to unknown error
        return .unknown(error)
    }
}

