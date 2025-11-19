//
//  AppleAuthService.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import Foundation
import AuthenticationServices

/// Service for handling native Sign in with Apple
/// Uses Apple's AuthenticationServices framework for iOS
@MainActor
class AppleAuthService: NSObject {

    // MARK: - Properties

    /// Completion handler for sign-in result
    private var signInCompletion: ((Result<AppleSignInResult, Error>) -> Void)?

    // MARK: - Sign In Methods

    /// Initiates Sign in with Apple flow
    /// - Parameter completion: Completion handler with result or error
    func signIn(completion: @escaping (Result<AppleSignInResult, Error>) -> Void) {
        print("🍎 [AppleAuth] Starting Sign in with Apple...")

        // Store completion handler
        signInCompletion = completion

        // Create authorization request
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        // Create authorization controller
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self

        // Perform authorization request
        authorizationController.performRequests()
    }

    /// Checks the current authorization state
    /// - Parameter userID: Apple user identifier
    /// - Returns: Current authorization state
    func checkAuthorizationState(userID: String) async throws -> ASAuthorizationAppleIDProvider.CredentialState {
        let provider = ASAuthorizationAppleIDProvider()
        return try await provider.credentialState(forUserID: userID)
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthService: ASAuthorizationControllerDelegate {

    /// Called when authorization succeeds
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        print("🍎 [AppleAuth] Authorization successful")

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            let error = NSError(
                domain: "AppleAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid credential type"]
            )
            signInCompletion?(.failure(error))
            signInCompletion = nil
            return
        }

        // Extract user information
        let userID = appleIDCredential.user
        let email = appleIDCredential.email
        let fullName = appleIDCredential.fullName
        let identityToken = appleIDCredential.identityToken
        let authorizationCode = appleIDCredential.authorizationCode

        // Create result object
        let result = AppleSignInResult(
            userID: userID,
            email: email,
            fullName: fullName,
            identityToken: identityToken,
            authorizationCode: authorizationCode
        )

        print("🍎 [AppleAuth] User ID: \(userID)")
        print("🍎 [AppleAuth] Email: \(email ?? "not provided")")
        print("🍎 [AppleAuth] Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")

        signInCompletion?(.success(result))
        signInCompletion = nil
    }

    /// Called when authorization fails
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("❌ [AppleAuth] Authorization failed: \(error.localizedDescription)")
        signInCompletion?(.failure(error))
        signInCompletion = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {

    /// Provides the presentation context for authorization UI
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the main window
        // In SwiftUI, we can get this from the environment or use a different approach
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for Apple Sign In presentation")
        }
        return window
    }
}

// MARK: - Apple Sign-In Result Model

/// Result model for Sign in with Apple
struct AppleSignInResult {
    /// Apple user identifier (stable across app installations)
    let userID: String

    /// User's email address (only provided on first sign-in)
    let email: String?

    /// User's full name (only provided on first sign-in)
    let fullName: PersonNameComponents?

    /// Identity token (JWT) for verifying with Supabase
    let identityToken: Data?

    /// Authorization code for exchanging with Supabase
    let authorizationCode: Data?

    /// Convenience property to get full name as string
    var fullNameString: String? {
        guard let fullName = fullName else { return nil }
        let components = [fullName.givenName, fullName.middleName, fullName.familyName]
            .compactMap { $0 }
        return components.isEmpty ? nil : components.joined(separator: " ")
    }

    /// Convenience property to get given name
    var givenName: String? {
        return fullName?.givenName
    }

    /// Convenience property to get family name
    var familyName: String? {
        return fullName?.familyName
    }
}

