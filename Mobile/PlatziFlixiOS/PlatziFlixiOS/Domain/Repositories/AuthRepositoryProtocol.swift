//
//  AuthRepositoryProtocol.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import Foundation

/// Protocol defining the contract for authentication operations
/// Follows CLEAR architecture pattern - Domain layer abstraction
protocol AuthRepository {
    
    // MARK: - Session Management
    
    /// Gets the current authenticated user session
    /// - Returns: Current session if authenticated, nil otherwise
    func getCurrentSession() async throws -> AuthSession?
    
    /// Signs in a user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Authentication session on success
    func signInWithEmail(email: String, password: String) async throws -> AuthSession
    
    /// Signs up a new user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Authentication session on success
    func signUpWithEmail(email: String, password: String) async throws -> AuthSession
    
    /// Signs in with a social provider (Google, Apple, Facebook)
    /// - Parameter provider: The social authentication provider
    /// - Returns: Authentication session on success
    func signInWithProvider(_ provider: AuthProvider) async throws -> AuthSession
    
    /// Signs out the current user
    func signOut() async throws
    
    /// Refreshes the current session if expired
    /// - Returns: New authentication session
    func refreshSession() async throws -> AuthSession
    
    // MARK: - User Management
    
    /// Updates the current user's profile information
    /// - Parameters:
    ///   - fullName: User's full name
    ///   - givenName: User's first name
    ///   - familyName: User's last name
    ///   - avatarURL: URL to user's avatar image
    /// - Returns: Updated user
    func updateUserProfile(
        fullName: String?,
        givenName: String?,
        familyName: String?,
        avatarURL: String?
    ) async throws -> User
    
    /// Sends a password reset email
    /// - Parameter email: User's email address
    func resetPassword(email: String) async throws
    
    // MARK: - Result-based Methods (for better error handling)
    
    /// Gets the current authenticated user session with Result wrapper
    /// - Returns: Result containing session or error
    func getCurrentSessionResult() async -> Result<AuthSession?, Error>
    
    /// Signs in a user with email and password with Result wrapper
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Result containing session or error
    func signInWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error>
    
    /// Signs up a new user with email and password with Result wrapper
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Result containing session or error
    func signUpWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error>
    
    /// Signs in with a social provider with Result wrapper
    /// - Parameter provider: The social authentication provider
    /// - Returns: Result containing session or error
    func signInWithProviderResult(_ provider: AuthProvider) async -> Result<AuthSession, Error>
}

