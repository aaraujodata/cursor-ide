//
//  User.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import Foundation

/// Domain model representing an authenticated user
struct User: Identifiable, Codable {
    /// Unique identifier for the user
    let id: String
    
    /// User's email address
    let email: String?
    
    /// User's full name
    let fullName: String?
    
    /// User's first name
    let givenName: String?
    
    /// User's last name
    let familyName: String?
    
    /// URL to user's avatar image
    let avatarURL: String?
    
    /// Authentication provider used (e.g., "apple", "google", "facebook", "email")
    let provider: String?
    
    /// Timestamp when the user was created
    let createdAt: Date?
    
    /// Timestamp when the user was last updated
    let updatedAt: Date?
    
    /// Initializes a User with all properties
    init(
        id: String,
        email: String? = nil,
        fullName: String? = nil,
        givenName: String? = nil,
        familyName: String? = nil,
        avatarURL: String? = nil,
        provider: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.givenName = givenName
        self.familyName = familyName
        self.avatarURL = avatarURL
        self.provider = provider
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Authentication session information
struct AuthSession: Codable {
    /// Access token for API requests
    let accessToken: String
    
    /// Refresh token for obtaining new access tokens
    let refreshToken: String
    
    /// Token expiration date
    let expiresAt: Date?
    
    /// User associated with this session
    let user: User
}

/// Authentication error types
enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError(String)
    case userNotFound
    case emailAlreadyExists
    case weakPassword
    case invalidEmail
    case providerError(String)
    case sessionExpired
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError(let message):
            return "Network error: \(message)"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password is too weak"
        case .invalidEmail:
            return "Invalid email address"
        case .providerError(let message):
            return "Authentication provider error: \(message)"
        case .sessionExpired:
            return "Session has expired. Please sign in again"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

/// Social authentication provider types
enum AuthProvider: String, CaseIterable {
    case google = "google"
    case apple = "apple"
    case facebook = "facebook"
    case email = "email"
    
    var displayName: String {
        switch self {
        case .google:
            return "Google"
        case .apple:
            return "Apple"
        case .facebook:
            return "Facebook"
        case .email:
            return "Email"
        }
    }
}

