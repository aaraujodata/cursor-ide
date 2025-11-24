//
//  GoogleAuthService.swift
//  PlatziFlixiOS
//
//  Google Sign-In service for native iOS authentication
//  Uses GoogleSignIn-iOS SDK with Supabase Auth
//

import Foundation
import UIKit
import Supabase
import GoogleSignIn

/// Service responsible for handling Google Sign-In authentication
/// Integrates with Supabase Auth using signInWithIdToken method
final class GoogleAuthService {
    
    // MARK: - Singleton
    
    /// Shared instance for Google Auth operations
    static let shared = GoogleAuthService()
    
    // MARK: - Properties
    
    /// Supabase client reference
    private var supabaseClient: SupabaseClient?
    
    /// Web Client ID from Google Cloud Console (required for ID token validation)
    private let webClientID = "117833718854-2gbl0coanrlb3ukp9n693b16kdshrmhj.apps.googleusercontent.com"
    
    // MARK: - Initialization
    
    private init() {
        print("🔵 [GoogleAuthService] Initialized")
    }
    
    /// Configure the service with Supabase client
    /// - Parameter client: Configured SupabaseClient instance
    func configure(with client: SupabaseClient) {
        self.supabaseClient = client
        print("🔵 [GoogleAuthService] Configured with Supabase client")
    }
    
    // MARK: - Authentication Methods
    
    /// Performs native Google Sign-In and authenticates with Supabase
    /// - Parameter presentingViewController: The view controller to present the sign-in UI
    /// - Returns: Supabase Session on success
    /// - Throws: GoogleAuthError on failure
    @MainActor
    func signIn(presenting viewController: UIViewController) async throws -> Session {
        print("🔵 [GoogleAuthService] ==================")
        print("🔵 [GoogleAuthService] Starting Google Sign-In flow")
        
        guard let client = supabaseClient else {
            print("❌ [GoogleAuthService] Supabase client not configured")
            throw GoogleAuthError.notConfigured
        }
        
        do {
            // Step 1: Perform Google Sign-In (must be on main thread)
            print("🔵 [GoogleAuthService] Initiating GIDSignIn...")
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            
            // Step 2: Extract tokens
            guard let idToken = result.user.idToken?.tokenString else {
                print("❌ [GoogleAuthService] No ID token received from Google")
                throw GoogleAuthError.noIdToken
            }
            
            let accessToken = result.user.accessToken.tokenString
            
            print("🔵 [GoogleAuthService] ✓ Received tokens from Google")
            print("🔵 [GoogleAuthService] ID Token: \(idToken.prefix(20))...")
            print("🔵 [GoogleAuthService] Access Token: \(accessToken.prefix(20))...")
            
            // Step 3: Sign in with Supabase using ID token
            print("🔵 [GoogleAuthService] Authenticating with Supabase...")
            
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )
            
            print("✅ [GoogleAuthService] Successfully authenticated with Supabase")
            print("🔵 [GoogleAuthService] User ID: \(session.user.id)")
            print("🔵 [GoogleAuthService] Email: \(session.user.email ?? "N/A")")
            print("🔵 [GoogleAuthService] ==================")
            
            return session
            
        } catch let error as NSError {
            print("❌ [GoogleAuthService] Google Sign-In error: \(error.localizedDescription)")
            print("❌ [GoogleAuthService] Error code: \(error.code)")
            print("❌ [GoogleAuthService] ==================")
            throw mapGoogleError(error)
        }
    }
    
    /// Signs out from Google
    func signOut() {
        print("🔵 [GoogleAuthService] Signing out from Google")
        GIDSignIn.sharedInstance.signOut()
        print("🔵 [GoogleAuthService] Signed out from Google")
    }
    
    /// Restores previous sign-in state if available
    @MainActor
    func restorePreviousSignIn() async throws -> Session? {
        print("🔵 [GoogleAuthService] Attempting to restore previous sign-in")
        
        guard let client = supabaseClient else {
            return nil
        }
        
        do {
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            
            guard let idToken = user.idToken?.tokenString else {
                return nil
            }
            
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
            )
            
            print("✅ [GoogleAuthService] Restored previous sign-in")
            return session
            
        } catch {
            print("⚠️ [GoogleAuthService] Could not restore previous sign-in: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Handle URL callback from Google Sign-In
    /// - Parameter url: The callback URL
    /// - Returns: True if the URL was handled
    func handle(_ url: URL) -> Bool {
        print("🔵 [GoogleAuthService] Handling URL: \(url)")
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: - Error Mapping
    
    /// Maps Google Sign-In errors to our custom error type
    private func mapGoogleError(_ error: NSError) -> GoogleAuthError {
        // Google Sign-In error codes
        // -5: User cancelled
        // -4: EMM (Enterprise Mobility Management) error
        // -3: Unknown error
        // -2: Keychain error
        // -1: Has no auth in keychain
        
        switch error.code {
        case -5:
            return .userCancelled
        case -4:
            return .emmError
        case -2:
            return .keychainError
        case -1:
            return .noAuthInKeychain
        default:
            return .unknown(error)
        }
    }
}

// MARK: - Google Auth Errors

/// Custom error types for Google authentication
enum GoogleAuthError: LocalizedError {
    case notConfigured
    case noIdToken
    case userCancelled
    case emmError
    case keychainError
    case noAuthInKeychain
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Google Sign-In is not properly configured. Please check your setup."
        case .noIdToken:
            return "Could not obtain ID token from Google. Please try again."
        case .userCancelled:
            return "Sign-in was cancelled."
        case .emmError:
            return "Enterprise Mobility Management error occurred."
        case .keychainError:
            return "Could not access keychain. Please check your device settings."
        case .noAuthInKeychain:
            return "No previous authentication found."
        case .unknown(let error):
            return "Google Sign-In failed: \(error.localizedDescription)"
        }
    }
}
