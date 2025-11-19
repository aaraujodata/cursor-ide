//
//  PasswordEntryView.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import SwiftUI

/// Password entry view for email/password authentication
/// Allows users to enter their password and complete authentication
struct PasswordEntryView: View {

    // MARK: - Properties

    /// Auth ViewModel for authentication operations
    @ObservedObject var viewModel: AuthViewModel

    /// User's email (from previous screen)
    let email: String

    /// Whether this is sign up flow
    @State private var isSignUp: Bool

    /// Password input field value
    @State private var password: String = ""

    /// Confirm password (for sign up)
    @State private var confirmPassword: String = ""

    /// Whether password is visible
    @State private var isPasswordVisible: Bool = false

    /// Whether confirm password is visible
    @State private var isConfirmPasswordVisible: Bool = false

    /// Whether password is valid
    @State private var isPasswordValid: Bool = false

    /// Whether passwords match (for sign up)
    @State private var passwordsMatch: Bool = true

    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization

    /// Initializes the view with authentication context
    /// - Parameters:
    ///   - viewModel: Authentication view model
    ///   - email: User's email address
    ///   - isSignUp: Whether this is a sign-up flow (default: false)
    init(viewModel: AuthViewModel, email: String, isSignUp: Bool = false) {
        self.viewModel = viewModel
        self.email = email
        self._isSignUp = State(initialValue: isSignUp)
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.spacing8) {
                        // Logo
                        logoSection

                        // Title
                        titleSection

                        // Email display (read-only)
                        emailDisplay

                        // Password input field
                        passwordInputField

                        // Confirm password (for sign up)
                        if isSignUp {
                            confirmPasswordInputField
                        }

                        // Password requirements (for sign up)
                        if isSignUp {
                            passwordRequirements
                        }

                        // Continue button
                        continueButton

                        // Forgot password (for sign in)
                        if !isSignUp {
                            forgotPasswordButton
                        }

                        // Mode toggle (sign in / sign up)
                        modeToggle

                        Spacer()
                    }
                    .padding(.horizontal, Spacing.spacing6)
                    .padding(.top, Spacing.spacing12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
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

    /// Logo section
    private var logoSection: some View {
        VStack(spacing: Spacing.spacing4) {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.primaryGreen)

            Text("Platzi")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryGreen)
        }
        .padding(.bottom, Spacing.spacing4)
    }

    /// Title section
    private var titleSection: some View {
        VStack(spacing: Spacing.spacing2) {
            Text(isSignUp ? "Create your password" : "Welcome back!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            if !isSignUp {
                Text("Enter your password to continue")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
            } else {
                Text("Choose a secure password")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.bottom, Spacing.spacing2)
        .accessibilityElement(children: .combine)
    }

    /// Email display (read-only)
    private var emailDisplay: some View {
        HStack {
            Text(email)
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)

            Spacer()
        }
        .padding(.horizontal, Spacing.spacing4)
        .padding(.vertical, Spacing.spacing3)
        .background(Color.neutralGray800)
        .cornerRadius(Radius.radiusMedium)
        .padding(.top, Spacing.spacing4)
    }

    /// Password input field
    private var passwordInputField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } else {
                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                }

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.textSecondary)
                }
            }
            .textFieldStyle(PasswordTextFieldStyle())
            .onChange(of: password) { oldValue, newValue in
                validatePassword(newValue)
                if isSignUp {
                    checkPasswordsMatch()
                }
            }

            // Password validation feedback
            if !password.isEmpty && !isPasswordValid {
                Text("Password must be at least 6 characters")
                    .font(.captionRegular)
                    .foregroundColor(.errorRed)
                    .padding(.leading, Spacing.spacing2)
            }
        }
        .padding(.top, Spacing.spacing6)
    }

    /// Confirm password input field (for sign up)
    private var confirmPasswordInputField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            HStack {
                if isConfirmPasswordVisible {
                    TextField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } else {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }

                Button {
                    isConfirmPasswordVisible.toggle()
                } label: {
                    Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.textSecondary)
                }
            }
            .textFieldStyle(PasswordTextFieldStyle())
            .onChange(of: confirmPassword) { oldValue, newValue in
                checkPasswordsMatch()
            }

            // Password match feedback
            if !confirmPassword.isEmpty && !passwordsMatch {
                Text("Passwords do not match")
                    .font(.captionRegular)
                    .foregroundColor(.errorRed)
                    .padding(.leading, Spacing.spacing2)
            }
        }
    }

    /// Password requirements (for sign up)
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            Text("Password requirements:")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)

            RequirementRow(
                text: "At least 6 characters",
                isMet: password.count >= 6
            )

            RequirementRow(
                text: "Passwords match",
                isMet: passwordsMatch || confirmPassword.isEmpty
            )
        }
        .padding(.vertical, Spacing.spacing2)
    }

    /// Continue button
    private var continueButton: some View {
        Button {
            if canContinue {
                Task {
                    if isSignUp {
                        await viewModel.signUpWithEmail(email: email, password: password)
                    } else {
                        await viewModel.signInWithEmail(email: email, password: password)
                    }

                    // Dismiss on success
                    if viewModel.isAuthenticated {
                        dismiss()
                    }
                }
            }
        } label: {
            HStack {
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .font(.buttonMedium)
                    .foregroundColor(canContinue ? .neutralBlack : .neutralGray600)

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .neutralBlack))
                } else {
                    Image(systemName: "arrow.right")
                        .font(.body)
                        .foregroundColor(canContinue ? .neutralBlack : .neutralGray600)
                }
            }
            .padding(.horizontal, Spacing.spacing6)
            .padding(.vertical, Spacing.spacing4)
            .background(canContinue ? Color.neutralWhite : Color.neutralGray800)
            .cornerRadius(Radius.radiusMedium)
        }
        .disabled(!canContinue || viewModel.isLoading)
        .padding(.top, Spacing.spacing4)
    }

    /// Forgot password button (for sign in)
    private var forgotPasswordButton: some View {
        Button {
            Task {
                await viewModel.resetPassword(email: email)
            }
        } label: {
            Text("Forgot password?")
                .font(.buttonSmall)
                .foregroundColor(.primaryGreen)
        }
        .padding(.top, Spacing.spacing4)
    }

    /// Mode toggle button (switch between sign in and sign up)
    private var modeToggle: some View {
        HStack(spacing: Spacing.spacing2) {
            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Clear fields when switching modes
                    password = ""
                    confirmPassword = ""
                    isPasswordValid = false
                    passwordsMatch = true

                    // Toggle mode
                    isSignUp.toggle()
                }
            } label: {
                Text(isSignUp ? "Sign In" : "Sign Up")
                    .font(.bodyEmphasized)
                    .foregroundColor(.primaryGreen)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.vertical, Spacing.spacing6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isSignUp ? "Already have an account? Sign in" : "Don't have an account? Sign up")
        .accessibilityHint(isSignUp ? "Switches to sign in mode" : "Switches to sign up mode")
    }

    // MARK: - Computed Properties

    /// Whether the form can be submitted
    private var canContinue: Bool {
        guard isPasswordValid else { return false }

        if isSignUp {
            return passwordsMatch && !confirmPassword.isEmpty
        }

        return !password.isEmpty
    }

    // MARK: - Private Methods

    /// Validates password strength
    private func validatePassword(_ password: String) {
        isPasswordValid = password.count >= 6
    }

    /// Checks if passwords match (for sign up)
    private func checkPasswordsMatch() {
        if isSignUp {
            passwordsMatch = password == confirmPassword || confirmPassword.isEmpty
        }
    }
}

// MARK: - Password Text Field Style

/// Custom text field style for password input
struct PasswordTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, Spacing.spacing4)
            .padding(.vertical, Spacing.spacing4)
            .background(Color.backgroundSecondary)
            .cornerRadius(Radius.radiusMedium)
            .foregroundColor(.neutralWhite)
    }
}

// MARK: - Requirement Row Component

/// Component for displaying password requirements
struct RequirementRow: View {
    let text: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: Spacing.spacing2) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.caption2)
                .foregroundColor(isMet ? .successGreen : .neutralGray600)

            Text(text)
                .font(.captionRegular)
                .foregroundColor(isMet ? .neutralGray600 : .errorRed)
        }
    }
}

// MARK: - Preview

#Preview {
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

    return PasswordEntryView(
        viewModel: AuthViewModel(authRepository: MockAuthRepository()),
        email: "user@example.com",
        isSignUp: true
    )
    .preferredColorScheme(.dark)
}

