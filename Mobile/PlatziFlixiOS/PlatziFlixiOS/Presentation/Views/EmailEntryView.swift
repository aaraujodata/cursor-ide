//
//  EmailEntryView.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import SwiftUI

/// Email entry view for email/password authentication
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
    @State private var isShowingPasswordEntry: Bool = false

    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()

                VStack(spacing: Spacing.spacing8) {
                    // Logo
                    logoSection

                    // Title
                    titleSection

                    // Email input field
                    emailInputField

                    // Continue button
                    continueButton

                    // Alternative options
                    alternativeOptions

                    Spacer()
                }
                .padding(.horizontal, Spacing.spacing6)
                .padding(.top, Spacing.spacing12)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
        .sheet(isPresented: $isShowingPasswordEntry) {
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
        Text("Log in or sign up")
            .font(.title2)
            .foregroundColor(.textPrimary)
            .padding(.bottom, Spacing.spacing2)
    }

    /// Email input field
    private var emailInputField: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            TextField("Email", text: $email)
                .textFieldStyle(EmailTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .onChange(of: email) { oldValue, newValue in
                    validateEmail(newValue)
                }

            // Email validation feedback
            if !email.isEmpty && !isEmailValid {
                Text("Please enter a valid email address")
                    .font(.captionRegular)
                    .foregroundColor(.errorRed)
                    .padding(.leading, Spacing.spacing2)
            }
        }
        .padding(.top, Spacing.spacing6)
    }

    /// Continue button
    private var continueButton: some View {
        Button {
            if isEmailValid {
                // Navigate to password entry
                // This will be handled by showing password entry view
                showPasswordEntry()
            }
        } label: {
            HStack {
                Text("Continue")
                    .font(.buttonMedium)
                    .foregroundColor(isEmailValid ? .textPrimary : .textSecondary)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.body)
                    .foregroundColor(isEmailValid ? .textPrimary : .textSecondary)
            }
            .padding(.horizontal, Spacing.spacing6)
            .padding(.vertical, Spacing.spacing4)
            .background(isEmailValid ? Color.primaryGreen : Color.backgroundSecondary)
            .cornerRadius(Radius.radiusMedium)
        }
        .disabled(!isEmailValid || viewModel.isLoading)
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .neutralBlack))
                }
            }
        )
    }

    /// Alternative login options
    private var alternativeOptions: some View {
        Button {
            dismiss()
        } label: {
            Text("Log in with Google, Apple, or Facebook")
                .font(.buttonMedium)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.spacing6)
                .padding(.vertical, Spacing.spacing4)
                .background(Color.backgroundSecondary)
                .cornerRadius(Radius.radiusMedium)
        }
        .padding(.top, Spacing.spacing4)
    }

    // MARK: - Private Methods

    /// Validates email format
    private func validateEmail(_ email: String) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailValid = emailPredicate.evaluate(with: email)
    }

    /// Shows password entry view
    private func showPasswordEntry() {
        isShowingPasswordEntry = true
    }
}

// MARK: - Email Text Field Style

/// Custom text field style for email input
struct EmailTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, Spacing.spacing4)
            .padding(.vertical, Spacing.spacing4)
            .background(Color.neutralGray800)
            .cornerRadius(Radius.radiusMedium)
            .foregroundColor(.textPrimary)
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

    return EmailEntryView(
        viewModel: AuthViewModel(authRepository: MockAuthRepository()),
        isSignUp: false
    )
    .preferredColorScheme(.dark)
}

