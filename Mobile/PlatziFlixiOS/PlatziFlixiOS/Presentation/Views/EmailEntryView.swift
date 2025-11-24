//
//  EmailEntryView.swift
//  PlatziFlixiOS
//
//  Email entry view for authentication flow
//  Redesigned with modern card-based layout and proper dark mode support
//  Following: promp_swit_ui_interfaces.md guidelines
//

import SwiftUI

/// Email entry view with modern design
/// Allows users to enter their email and proceed to password entry
struct EmailEntryView: View {
    
    // MARK: - Properties
    
    /// Auth ViewModel for authentication operations
    @ObservedObject var viewModel: AuthViewModel
    
    /// Whether this is sign up flow
    let isSignUp: Bool
    
    /// Email input field value
    @State private var email: String = ""
    
    /// Whether email is valid
    @State private var isEmailValid: Bool = false
    
    /// Whether to show password entry sheet
    @State private var showPasswordEntry: Bool = false
    
    /// Whether email field is focused
    @FocusState private var isEmailFocused: Bool
    
    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss
    
    /// Environment color scheme
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background layer
                    backgroundLayer(geometry: geometry)
                    
                    // Content layer
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Spacer for header area
                            Spacer()
                                .frame(height: geometry.size.height * 0.12)
                            
                            // Main card content
                            mainCard
                                .padding(.horizontal, Spacing.spacing6)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
        }
        .sheet(isPresented: $showPasswordEntry) {
            PasswordEntryView(
                viewModel: viewModel,
                email: email,
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
            
            // Green wave header (smaller than main auth view)
            VStack {
                WaveShape()
                    .fill(Color.primaryGreen)
                    .frame(height: geometry.size.height * 0.25)
                Spacer()
            }
        }
    }
    
    // MARK: - Back Button
    
    /// Navigation back button
    private var backButton: some View {
        Button {
            print("⬅️ [EmailEntryView] Back button tapped")
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.title3.weight(.semibold))
                .foregroundColor(.neutralBlack)
        }
        .accessibilityLabel("Go back")
    }
    
    // MARK: - Main Card
    
    /// Main content card
    private var mainCard: some View {
        VStack(spacing: Spacing.spacing6) {
            // Title section
            titleSection
            
            // Email input
            emailInputSection
            
            // Continue button
            continueButton
            
            // Alternative options
            alternativeOption
        }
        .padding(.horizontal, Spacing.spacing6)
        .padding(.vertical, Spacing.spacing8)
        .background(Color.cardBackground)
        .cardStyle()
        .padding(.bottom, Spacing.spacing8)
    }
    
    // MARK: - Title Section
    
    /// Title and subtitle
    private var titleSection: some View {
        VStack(spacing: Spacing.spacing2) {
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.title1)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(isSignUp ? "Enter your email to get started" : "Enter your email to continue")
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, Spacing.spacing4)
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Email Input Section
    
    /// Email text field with validation
    private var emailInputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            // Label
            Text("Email")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
            
            // Email text field
            TextField("you@example.com", text: $email)
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .focused($isEmailFocused)
                .padding(.horizontal, Spacing.spacing4)
                .padding(.vertical, Spacing.spacing4)
                .background(Color.inputBackground)
                .cornerRadius(Radius.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.radiusMedium)
                        .stroke(emailBorderColor, lineWidth: 1)
                )
                .onChange(of: email) { _, newValue in
                    validateEmail(newValue)
                }
            
            // Validation message
            if !email.isEmpty && !isEmailValid {
                HStack(spacing: Spacing.spacing1) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text("Please enter a valid email address")
                        .font(.captionRegular)
                }
                .foregroundColor(.errorRed)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isEmailValid)
    }
    
    /// Border color based on validation state
    private var emailBorderColor: Color {
        if email.isEmpty {
            return Color.inputBorder.opacity(0.5)
        } else if isEmailValid {
            return Color.successGreen.opacity(0.5)
        } else {
            return Color.errorRed.opacity(0.5)
        }
    }
    
    // MARK: - Continue Button
    
    /// Primary action button
    private var continueButton: some View {
        Button {
            print("➡️ [EmailEntryView] Continue tapped with email: \(email)")
            if isEmailValid {
                showPasswordEntry = true
            }
        } label: {
            Text("Continue")
                .loadingState(viewModel.isLoading)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isEmailValid && !viewModel.isLoading))
        .disabled(!isEmailValid || viewModel.isLoading)
        .accessibilityLabel("Continue to password entry")
        .accessibilityHint(isEmailValid ? "Opens password entry" : "Enter a valid email first")
    }
    
    // MARK: - Alternative Option
    
    /// Back to social login option
    private var alternativeOption: some View {
        Button {
            print("🔙 [EmailEntryView] Back to social options")
            dismiss()
        } label: {
            Text("Use Google or Apple instead")
                .font(.bodyRegular)
                .foregroundColor(.primaryGreen)
        }
        .padding(.top, Spacing.spacing2)
    }
    
    // MARK: - Validation
    
    /// Validates email format using regex
    private func validateEmail(_ email: String) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
        print("📧 [EmailEntryView] Email validation: \(isEmailValid ? "✓ valid" : "✗ invalid")")
    }
}

// MARK: - Preview

#Preview("Email Entry - Light") {
    EmailEntryViewPreview()
        .preferredColorScheme(.light)
}

#Preview("Email Entry - Dark") {
    EmailEntryViewPreview()
        .preferredColorScheme(.dark)
}

#Preview("Email Entry - Sign Up") {
    EmailEntryViewPreview(isSignUp: true)
}

/// Preview helper
private struct EmailEntryViewPreview: View {
    var isSignUp: Bool = false
    
    var body: some View {
        let mockRepo = MockEmailAuthRepository()
        let viewModel = AuthViewModel(authRepository: mockRepo)
        
        return EmailEntryView(
            viewModel: viewModel,
            isSignUp: isSignUp
        )
    }
}

/// Mock repository for preview
private struct MockEmailAuthRepository: AuthRepository {
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

