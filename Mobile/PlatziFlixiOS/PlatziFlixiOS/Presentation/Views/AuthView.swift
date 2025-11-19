//
//  AuthView.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import SwiftUI

/// Main authentication view - Login or Sign up screen
/// Displays social login options and email/password option
struct AuthView: View {

    // MARK: - Properties

    /// ViewModel managing authentication state (passed from parent)
    @ObservedObject var viewModel: AuthViewModel

    /// Whether to show email entry screen
    @State private var showEmailEntry: Bool = false

    /// Whether this is sign up flow (true) or sign in flow (false)
    @State private var isSignUp: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background color - adapts to light/dark mode
            Color.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.spacing8) {
                    // Logo and title section
                    logoSection

                    // Main instruction text
                    instructionText

                    // Social login buttons
                    socialLoginButtons

                    // Divider with "or"
                    dividerSection

                    // Email/password option
                    emailPasswordButton

                    // Sign up prompt for new users
                    signUpPrompt

                    // Terms and privacy notice
                    termsNotice
                }
                .padding(.horizontal, Spacing.spacing6)
                .padding(.vertical, Spacing.spacing8)
            }
        }
        .sheet(isPresented: $showEmailEntry) {
            EmailEntryView(
                viewModel: viewModel,
                isSignUp: isSignUp
            )
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - View Components

    /// Logo section with Platzi branding
    private var logoSection: some View {
        VStack(spacing: Spacing.spacing4) {
            // Platzi logo placeholder - replace with actual logo asset
            Image(systemName: "play.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.primaryGreen)

            Text("Platzi")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryGreen)
        }
        .padding(.top, Spacing.spacing12)
        .padding(.bottom, Spacing.spacing4)
    }

    /// Instruction text
    private var instructionText: some View {
        Text("Log in or sign up with:")
            .font(.bodyRegular)
            .foregroundColor(.textPrimary)
            .padding(.bottom, Spacing.spacing2)
    }

    /// Social login buttons (Google, Apple, Facebook)
    private var socialLoginButtons: some View {
        VStack(spacing: Spacing.spacing4) {
            // Google button
            SocialLoginButton(
                provider: .google,
                icon: "globe",
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.signInWithProvider(.google)
                }
            }

            // Apple button
            SocialLoginButton(
                provider: .apple,
                icon: "applelogo",
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.signInWithProvider(.apple)
                }
            }

            // Facebook button
            SocialLoginButton(
                provider: .facebook,
                icon: "f.circle.fill",
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.signInWithProvider(.facebook)
                }
            }
        }
    }

    /// Divider section with "or" text
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.neutralGray600)
                .frame(height: 1)

            Text("or")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, Spacing.spacing4)

            Rectangle()
                .fill(Color.neutralGray600)
                .frame(height: 1)
        }
        .padding(.vertical, Spacing.spacing4)
    }

    /// Email/password button
    private var emailPasswordButton: some View {
        Button {
            isSignUp = false
            showEmailEntry = true
        } label: {
            HStack {
                Text("Continue with email and password")
                    .font(.buttonMedium)
                    .foregroundColor(.textPrimary)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.body)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, Spacing.spacing6)
            .padding(.vertical, Spacing.spacing4)
            .background(Color.backgroundSecondary)
            .cornerRadius(Radius.radiusMedium)
        }
        .disabled(viewModel.isLoading)
    }

    /// Sign up prompt for new users
    private var signUpPrompt: some View {
        HStack(spacing: Spacing.spacing2) {
            Text("Don't have an account?")
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)

            Button {
                isSignUp = true
                showEmailEntry = true
            } label: {
                Text("Sign Up")
                    .font(.bodyEmphasized)
                    .foregroundColor(.primaryGreen)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.vertical, Spacing.spacing4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Don't have an account? Sign up")
        .accessibilityHint("Creates a new Platzi account")
    }

    /// Terms and privacy notice
    private var termsNotice: some View {
        VStack(spacing: Spacing.spacing2) {
            Text("By creating a Platzi account, you accept the")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)

            HStack(spacing: Spacing.spacing2) {
                Button("Terms of Service") {
                    // TODO: Open terms of service
                }
                .font(.captionRegular)
                .foregroundColor(.primaryGreen)

                Text("and")
                    .font(.captionRegular)
                    .foregroundColor(.textSecondary)

                Button("Privacy Policy") {
                    // TODO: Open privacy policy
                }
                .font(.captionRegular)
                .foregroundColor(.primaryGreen)
            }
        }
        .padding(.top, Spacing.spacing4)
    }
}

// MARK: - Social Login Button Component

/// Reusable button for social login providers
struct SocialLoginButton: View {
    let provider: AuthProvider
    let icon: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing4) {
                // Provider icon
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.textPrimary)
                    .frame(width: 24, height: 24)

                // Provider text
                Text("Continue with \(provider.displayName)")
                    .font(.buttonMedium)
                    .foregroundColor(.textPrimary)

                Spacer()
            }
            .padding(.horizontal, Spacing.spacing6)
            .padding(.vertical, Spacing.spacing4)
            .background(buttonBackgroundColor)
            .cornerRadius(Radius.radiusMedium)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .neutralWhite))
                    }
                }
            )
        }
        .disabled(isLoading)
    }

    /// Background color based on provider
    private var buttonBackgroundColor: Color {
        switch provider {
        case .google:
            return Color(hex: "DB4437") // Google red
        case .apple:
            return Color.neutralGray800 // Apple uses dark gray/black
        case .facebook:
            return Color(hex: "1877F2") // Facebook blue
        case .email:
            return Color.neutralGray800
        }
    }
}

// MARK: - Preview

#Preview {
    // Create a mock repository and view model for preview
    struct MockAuthRepository: AuthRepository {
        func getCurrentSession() async throws -> AuthSession? { nil }
        func signInWithEmail(email: String, password: String) async throws -> AuthSession { throw AuthError.unknown(NSError()) }
        func signUpWithEmail(email: String, password: String) async throws -> AuthSession { throw AuthError.unknown(NSError()) }
        func signInWithProvider(_ provider: AuthProvider) async throws -> AuthSession { throw AuthError.unknown(NSError()) }
        func signOut() async throws {}
        func refreshSession() async throws -> AuthSession { throw AuthError.unknown(NSError()) }
        func updateUserProfile(fullName: String?, givenName: String?, familyName: String?, avatarURL: String?) async throws -> User { throw AuthError.unknown(NSError()) }
        func resetPassword(email: String) async throws {}
        func getCurrentSessionResult() async -> Result<AuthSession?, Error> { .success(nil) }
        func signInWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error> { .failure(AuthError.unknown(NSError())) }
        func signUpWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error> { .failure(AuthError.unknown(NSError())) }
        func signInWithProviderResult(_ provider: AuthProvider) async -> Result<AuthSession, Error> { .failure(AuthError.unknown(NSError())) }
    }

    let mockRepo = MockAuthRepository()
    let viewModel = AuthViewModel(authRepository: mockRepo)

    return AuthView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

