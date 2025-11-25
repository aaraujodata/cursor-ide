//
//  AuthView.swift
//  PlatziFlixiOS
//
//  Main authentication view - Login or Sign up screen
//  Redesigned following Arimo reference with card-based layout
//  Following: promp_swit_ui_interfaces.md guidelines
//

import SwiftUI

/// Main authentication view with modern card-based design
/// Features a colored header with wave shape and clean form inputs
struct AuthView: View {

    // MARK: - Properties

    /// ViewModel managing authentication state
    @ObservedObject var viewModel: AuthViewModel

    /// Whether to show email entry screen
    @State private var showEmailEntry: Bool = false

    /// Whether this is sign up flow
    @State private var isSignUp: Bool = false

    /// Environment color scheme for dark mode support
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background layer
                backgroundLayer(geometry: geometry)

                // Content layer
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Spacer for header area
                        Spacer()
                            .frame(height: geometry.size.height * 0.18)

                        // Main card content
                        mainCard
                            .padding(.horizontal, Spacing.spacing6)
                    }
                }
            }
        }
        .ignoresSafeArea()
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

    // MARK: - Background Layer

    /// Creates the background with colored header wave
    @ViewBuilder
    private func backgroundLayer(geometry: GeometryProxy) -> some View {
        ZStack {
            // Base background
            Color.backgroundPrimary

            // Green wave header
            VStack {
                WaveShape()
                    .fill(Color.primaryGreen)
                    .frame(height: geometry.size.height * 0.35)
                Spacer()
            }
        }
    }

    // MARK: - Main Card

    /// Main content card with all authentication options
    private var mainCard: some View {
        VStack(spacing: Spacing.spacing6) {
            // Logo section
            logoSection

            // Welcome text
            welcomeText

            // Email button (primary action)
            emailButton

            // Divider
            DividerWithText(text: "Or")
                .padding(.vertical, Spacing.spacing2)

            // Social login buttons
            socialLoginButtons

            // Sign up/Sign in toggle
            authModeToggle
        }
        .padding(.horizontal, Spacing.spacing6)
        .padding(.vertical, Spacing.spacing8)
        .background(Color.cardBackground)
        .cardStyle()
        .padding(.bottom, Spacing.spacing8)
    }

    // MARK: - Logo Section

    /// Logo with app branding
    private var logoSection: some View {
        VStack(spacing: Spacing.spacing3) {
            // App logo icon
            Image(systemName: "play.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.primaryGreen)
                .accessibilityHidden(true)

            // App name
            Text("PlatziFlixiOS")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
        }
        .padding(.bottom, Spacing.spacing2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("PlatziFlixiOS logo")
    }

    // MARK: - Welcome Text

    /// Welcome message and subtitle
    private var welcomeText: some View {
        VStack(spacing: Spacing.spacing2) {
            Text("Welcome!")
                .font(.title1)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Text("Login now to continue learning")
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Email Button

    /// Primary email login button
    private var emailButton: some View {
        Button {
            print("📧 [AuthView] Email button tapped")
            isSignUp = false
            showEmailEntry = true
        } label: {
            Text("Continue with Email")
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: !viewModel.isLoading))
        .disabled(viewModel.isLoading)
        .accessibilityLabel("Continue with email")
        .accessibilityHint("Opens email and password entry")
    }

    // MARK: - Social Login Buttons

    /// Social provider login options
    // MARK: - Feature Flags

    /// Enable Apple Sign-In (requires paid Apple Developer account)
    /// Set to true once you have Sign in with Apple capability enabled
    private let isAppleSignInEnabled = false

    private var socialLoginButtons: some View {
        VStack(spacing: Spacing.spacing3) {
            // Google Sign In
            SocialAuthButton(
                provider: .google,
                isLoading: viewModel.isLoading
            ) {
                print("🔵 [AuthView] Google sign in tapped")
                Task {
                    await viewModel.signInWithProvider(.google)
                }
            }

            // Apple Sign In (requires paid Apple Developer account)
            // TODO: Set isAppleSignInEnabled = true when you have:
            // 1. Paid Apple Developer Program membership ($99/year)
            // 2. Sign in with Apple capability added in Xcode
            // 3. App ID configured in Apple Developer Console
            // 4. Bundle ID added to Supabase Dashboard
            if isAppleSignInEnabled {
                SocialAuthButton(
                    provider: .apple,
                    isLoading: viewModel.isLoading
                ) {
                    print("🍎 [AuthView] Apple sign in tapped")
                    Task {
                        await viewModel.signInWithProvider(.apple)
                    }
                }
            }
        }
    }

    // MARK: - Auth Mode Toggle

    /// Toggle between sign in and sign up
    private var authModeToggle: some View {
        HStack(spacing: Spacing.spacing1) {
            Text("Don't have an account?")
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)

            Button {
                print("📝 [AuthView] Create account tapped")
                isSignUp = true
                showEmailEntry = true
            } label: {
                Text("Create an account")
                    .font(.bodyEmphasized)
                    .foregroundColor(.primaryGreen)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.top, Spacing.spacing4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Don't have an account? Create an account")
        .accessibilityHint("Opens sign up flow")
    }
}

// MARK: - Social Auth Button Component

/// Reusable social login button with outlined style
struct SocialAuthButton: View {
    let provider: AuthProvider
    let isLoading: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing3) {
                // Provider icon
                providerIcon
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)

                // Button text
                Text("Continue with \(provider.displayName)")
                    .font(.buttonMedium)
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.spacing4)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.radiusFull)
                    .stroke(Color.inputBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
        .accessibilityLabel("Continue with \(provider.displayName)")
    }

    /// Provider-specific icon
    @ViewBuilder
    private var providerIcon: some View {
        switch provider {
        case .google:
            // Google "G" using SF Symbol as fallback
            Image(systemName: "g.circle.fill")
        case .apple:
            Image(systemName: "apple.logo")
        case .facebook:
            Image(systemName: "f.circle.fill")
        case .email:
            Image(systemName: "envelope.fill")
        }
    }

    /// Provider-specific icon color
    private var iconColor: Color {
        switch provider {
        case .google:
            return .googleRed
        case .apple:
            return colorScheme == .dark ? .white : .black
        case .facebook:
            return .facebookBlue
        case .email:
            return .primaryGreen
        }
    }
}

// MARK: - Preview

#Preview("Auth View - Light") {
    AuthViewPreview()
        .preferredColorScheme(.light)
}

#Preview("Auth View - Dark") {
    AuthViewPreview()
        .preferredColorScheme(.dark)
}

/// Preview helper to create mock environment
private struct AuthViewPreview: View {
    var body: some View {
        // Create a mock repository for preview
        let mockRepo = MockAuthRepository()
        let viewModel = AuthViewModel(authRepository: mockRepo)

        return AuthView(viewModel: viewModel)
    }
}

/// Mock auth repository for previews
private struct MockAuthRepository: AuthRepository {
    func getCurrentSession() async throws -> AuthSession? { nil }
    func signInWithEmail(email: String, password: String) async throws -> AuthSession {
        throw AuthError.unknown(NSError())
    }
    func signUpWithEmail(email: String, password: String) async throws -> AuthSession {
        throw AuthError.unknown(NSError())
    }
    func signInWithProvider(_ provider: AuthProvider) async throws -> AuthSession {
        throw AuthError.unknown(NSError())
    }
    func signOut() async throws {}
    func refreshSession() async throws -> AuthSession {
        throw AuthError.unknown(NSError())
    }
    func updateUserProfile(fullName: String?, givenName: String?, familyName: String?, avatarURL: String?) async throws -> User {
        throw AuthError.unknown(NSError())
    }
    func resetPassword(email: String) async throws {}
    func getCurrentSessionResult() async -> Result<AuthSession?, Error> { .success(nil) }
    func signInWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error> {
        .failure(AuthError.unknown(NSError()))
    }
    func signUpWithEmailResult(email: String, password: String) async -> Result<AuthSession, Error> {
        .failure(AuthError.unknown(NSError()))
    }
    func signInWithProviderResult(_ provider: AuthProvider) async -> Result<AuthSession, Error> {
        .failure(AuthError.unknown(NSError()))
    }
}
