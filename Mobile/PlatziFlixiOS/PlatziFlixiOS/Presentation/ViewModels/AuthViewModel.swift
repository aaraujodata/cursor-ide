//
//  AuthViewModel.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for authentication flow
/// Manages authentication state and user interactions
@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Current authentication session
    @Published var session: AuthSession?

    /// Current authenticated user
    @Published var currentUser: User?

    /// Loading state for async operations
    @Published var isLoading: Bool = false

    /// Error message to display to user
    @Published var errorMessage: String?

    /// Whether user is authenticated
    @Published var isAuthenticated: Bool = false

    // MARK: - Private Properties

    /// Authentication repository (injected dependency)
    private let authRepository: AuthRepository

    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Initializes the ViewModel with an auth repository
    /// - Parameter authRepository: Repository implementing AuthRepository protocol
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
        print("🔐 [AuthViewModel] Initialized")

        // Check for existing session on initialization
        Task {
            await checkCurrentSession()
        }
    }

    // MARK: - Public Methods

    /// Checks if there's an existing authenticated session
    func checkCurrentSession() async {
        print("🔐 [AuthViewModel] Checking current session...")
        isLoading = true
        errorMessage = nil

        let result = await authRepository.getCurrentSessionResult()

        switch result {
        case .success(let session):
            if let session = session {
                self.session = session
                self.currentUser = session.user
                self.isAuthenticated = true
                print("🔐 [AuthViewModel] Session found for user: \(session.user.email ?? "unknown")")
            } else {
                self.isAuthenticated = false
                print("🔐 [AuthViewModel] No active session")
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
            print("❌ [AuthViewModel] Error checking session: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Signs in with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    func signInWithEmail(email: String, password: String) async {
        print("🔐 [AuthViewModel] ==================")
        print("🔐 [AuthViewModel] Sign in with email initiated")
        print("🔐 [AuthViewModel] Email: \(email)")
        isLoading = true
        errorMessage = nil

        print("🔐 [AuthViewModel] Calling auth repository...")
        let result = await authRepository.signInWithEmailResult(email: email, password: password)

        switch result {
        case .success(let session):
            print("🔐 [AuthViewModel] ✓ Auth repository returned session")
            self.session = session
            self.currentUser = session.user
            self.isAuthenticated = true
            print("✅ [AuthViewModel] Sign in successful")
            print("🔐 [AuthViewModel] User: \(session.user.email ?? "unknown")")
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
            print("❌ [AuthViewModel] Sign in failed: \(error.localizedDescription)")
            print("❌ [AuthViewModel] Error type: \(type(of: error))")
        }

        isLoading = false
        print("🔐 [AuthViewModel] ==================")
    }

    /// Signs up with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    func signUpWithEmail(email: String, password: String) async {
        print("🔐 [AuthViewModel] ==================")
        print("🔐 [AuthViewModel] Sign up with email initiated")
        print("🔐 [AuthViewModel] Email: \(email)")
        isLoading = true
        errorMessage = nil

        print("🔐 [AuthViewModel] Calling auth repository...")
        let result = await authRepository.signUpWithEmailResult(email: email, password: password)

        switch result {
        case .success(let session):
            print("🔐 [AuthViewModel] ✓ Auth repository returned session")
            self.session = session
            self.currentUser = session.user
            self.isAuthenticated = true
            print("✅ [AuthViewModel] Sign up successful")
            print("🔐 [AuthViewModel] User: \(session.user.email ?? "unknown")")
            print("🔐 [AuthViewModel] User ID: \(session.user.id)")
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
            print("❌ [AuthViewModel] Sign up failed: \(error.localizedDescription)")
            print("❌ [AuthViewModel] Error type: \(type(of: error))")
        }

        isLoading = false
        print("🔐 [AuthViewModel] ==================")
    }

    /// Signs in with a social provider
    /// - Parameter provider: The authentication provider to use
    func signInWithProvider(_ provider: AuthProvider) async {
        print("🔐 [AuthViewModel] Signing in with provider: \(provider.displayName)...")
        isLoading = true
        errorMessage = nil

        let result = await authRepository.signInWithProviderResult(provider)

        switch result {
        case .success(let session):
            self.session = session
            self.currentUser = session.user
            self.isAuthenticated = true

            // If Apple sign-in provided name info, update user profile
            if provider == .apple {
                await updateUserProfileIfNeeded(user: session.user)
            }

            print("✅ [AuthViewModel] Sign in with \(provider.displayName) successful")
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
            print("❌ [AuthViewModel] Sign in with \(provider.displayName) failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Signs out the current user
    func signOut() async {
        print("🔐 [AuthViewModel] Signing out...")
        isLoading = true
        errorMessage = nil

        do {
            try await authRepository.signOut()
            self.session = nil
            self.currentUser = nil
            self.isAuthenticated = false
            print("✅ [AuthViewModel] Sign out successful")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ [AuthViewModel] Sign out failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Sends a password reset email
    /// - Parameter email: User's email address
    func resetPassword(email: String) async {
        print("🔐 [AuthViewModel] Resetting password...")
        isLoading = true
        errorMessage = nil

        do {
            try await authRepository.resetPassword(email: email)
            print("✅ [AuthViewModel] Password reset email sent")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ [AuthViewModel] Password reset failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Clears the current error message
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Helpers

    /// Updates user profile if name information is available (for Apple sign-in)
    private func updateUserProfileIfNeeded(user: User) async {
        // Apple only provides name on first sign-in
        // If we have name info, save it to user metadata
        guard let givenName = user.givenName,
              let familyName = user.familyName else {
            return
        }

        do {
            _ = try await authRepository.updateUserProfile(
                fullName: user.fullName,
                givenName: givenName,
                familyName: familyName,
                avatarURL: user.avatarURL
            )
            print("✅ [AuthViewModel] User profile updated with name information")
        } catch {
            print("⚠️ [AuthViewModel] Failed to update user profile: \(error.localizedDescription)")
        }
    }
}

