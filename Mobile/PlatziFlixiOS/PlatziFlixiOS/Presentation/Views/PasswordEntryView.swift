//
//  PasswordEntryView.swift
//  PlatziFlixiOS
//
//  Password entry view for authentication flow
//  Redesigned with modern card-based layout and proper dark mode support
//  Following: promp_swit_ui_interfaces.md guidelines
//

import SwiftUI

/// Password entry view with modern design
/// Allows users to enter their password and complete authentication
struct PasswordEntryView: View {
    
    // MARK: - Properties
    
    /// Auth ViewModel for authentication operations
    @ObservedObject var viewModel: AuthViewModel
    
    /// User's email from previous screen
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
    
    /// Whether password meets requirements
    @State private var isPasswordValid: Bool = false
    
    /// Whether passwords match (for sign up)
    @State private var passwordsMatch: Bool = true
    
    /// Whether terms are accepted (for sign up)
    @State private var termsAccepted: Bool = false
    
    /// Focus state for password field
    @FocusState private var isPasswordFocused: Bool
    
    /// Focus state for confirm password field
    @FocusState private var isConfirmFocused: Bool
    
    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss
    
    /// Environment color scheme
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Initialization
    
    init(viewModel: AuthViewModel, email: String, isSignUp: Bool = false) {
        self.viewModel = viewModel
        self.email = email
        self._isSignUp = State(initialValue: isSignUp)
    }
    
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
                                .frame(height: geometry.size.height * 0.10)
                            
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
    
    @ViewBuilder
    private func backgroundLayer(geometry: GeometryProxy) -> some View {
        ZStack {
            Color.backgroundPrimary
            
            VStack {
                WaveShape()
                    .fill(Color.primaryGreen)
                    .frame(height: geometry.size.height * 0.22)
                Spacer()
            }
        }
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button {
            print("⬅️ [PasswordEntryView] Back button tapped")
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.title3.weight(.semibold))
                .foregroundColor(.neutralBlack)
        }
        .accessibilityLabel("Go back")
    }
    
    // MARK: - Main Card
    
    private var mainCard: some View {
        VStack(spacing: Spacing.spacing5) {
            // Title
            titleSection
            
            // Email display
            emailDisplay
            
            // Password fields
            passwordSection
            
            // Sign up specific fields
            if isSignUp {
                confirmPasswordSection
                passwordRequirements
                termsCheckbox
            }
            
            // Action button
            actionButton
            
            // Forgot password (sign in only)
            if !isSignUp {
                forgotPasswordButton
            }
            
            // Mode toggle
            modeToggle
        }
        .padding(.horizontal, Spacing.spacing6)
        .padding(.vertical, Spacing.spacing8)
        .background(Color.cardBackground)
        .cardStyle()
        .padding(.bottom, Spacing.spacing8)
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(spacing: Spacing.spacing2) {
            Text(isSignUp ? "Finish signing up" : "Enter Password")
                .font(.title1)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(isSignUp ? "Create a secure password" : "Welcome back!")
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)
        }
        .padding(.bottom, Spacing.spacing2)
    }
    
    // MARK: - Email Display
    
    private var emailDisplay: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing1) {
            Text("Email")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
            
            HStack {
                Text(email)
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.successGreen)
                    .font(.body)
            }
            .padding(.horizontal, Spacing.spacing4)
            .padding(.vertical, Spacing.spacing3)
            .background(Color.inputBackground)
            .cornerRadius(Radius.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.radiusMedium)
                    .stroke(Color.inputBorder.opacity(0.5), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Password Section
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            Text("Password")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: Spacing.spacing2) {
                Group {
                    if isPasswordVisible {
                        TextField("Enter password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                    } else {
                        SecureField("Enter password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                    }
                }
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isPasswordFocused)
                
                // Visibility toggle
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.textSecondary)
                        .font(.body)
                }
            }
            .padding(.horizontal, Spacing.spacing4)
            .padding(.vertical, Spacing.spacing4)
            .background(Color.inputBackground)
            .cornerRadius(Radius.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.radiusMedium)
                    .stroke(passwordBorderColor, lineWidth: 1)
            )
            .onChange(of: password) { _, newValue in
                validatePassword(newValue)
                checkPasswordsMatch()
            }
        }
    }
    
    // MARK: - Confirm Password Section
    
    private var confirmPasswordSection: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            Text("Confirm Password")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: Spacing.spacing2) {
                Group {
                    if isConfirmPasswordVisible {
                        TextField("Confirm password", text: $confirmPassword)
                            .textContentType(.newPassword)
                    } else {
                        SecureField("Confirm password", text: $confirmPassword)
                            .textContentType(.newPassword)
                    }
                }
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isConfirmFocused)
                
                Button {
                    isConfirmPasswordVisible.toggle()
                } label: {
                    Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.textSecondary)
                        .font(.body)
                }
            }
            .padding(.horizontal, Spacing.spacing4)
            .padding(.vertical, Spacing.spacing4)
            .background(Color.inputBackground)
            .cornerRadius(Radius.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.radiusMedium)
                    .stroke(confirmPasswordBorderColor, lineWidth: 1)
            )
            .onChange(of: confirmPassword) { _, _ in
                checkPasswordsMatch()
            }
            
            // Mismatch error
            if !confirmPassword.isEmpty && !passwordsMatch {
                HStack(spacing: Spacing.spacing1) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text("Passwords do not match")
                        .font(.captionRegular)
                }
                .foregroundColor(.errorRed)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: passwordsMatch)
    }
    
    // MARK: - Border Colors
    
    private var passwordBorderColor: Color {
        if password.isEmpty { return Color.inputBorder.opacity(0.5) }
        return isPasswordValid ? Color.successGreen.opacity(0.5) : Color.inputBorder.opacity(0.5)
    }
    
    private var confirmPasswordBorderColor: Color {
        if confirmPassword.isEmpty { return Color.inputBorder.opacity(0.5) }
        return passwordsMatch ? Color.successGreen.opacity(0.5) : Color.errorRed.opacity(0.5)
    }
    
    // MARK: - Password Requirements
    
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing2) {
            RequirementItem(
                text: "At least 6 characters",
                isMet: password.count >= 6
            )
            RequirementItem(
                text: "Passwords match",
                isMet: passwordsMatch && !confirmPassword.isEmpty
            )
        }
        .padding(.vertical, Spacing.spacing1)
    }
    
    // MARK: - Terms Checkbox
    
    private var termsCheckbox: some View {
        HStack(alignment: .top, spacing: Spacing.spacing3) {
            Button {
                termsAccepted.toggle()
            } label: {
                Image(systemName: termsAccepted ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(termsAccepted ? .primaryGreen : .textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("I read and agreed to ")
                    .font(.captionRegular)
                    .foregroundColor(.textSecondary)
                +
                Text("User Agreement")
                    .font(.captionRegular)
                    .foregroundColor(.primaryGreen)
                
                Text("and ")
                    .font(.captionRegular)
                    .foregroundColor(.textSecondary)
                +
                Text("Privacy Policy")
                    .font(.captionRegular)
                    .foregroundColor(.primaryGreen)
            }
            
            Spacer()
        }
        .padding(.vertical, Spacing.spacing2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Accept terms and privacy policy")
        .accessibilityValue(termsAccepted ? "Accepted" : "Not accepted")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Action Button
    
    private var actionButton: some View {
        Button {
            print("🔐 [PasswordEntryView] \(isSignUp ? "Sign Up" : "Sign In") button tapped")
            performAuthAction()
        } label: {
            Text(isSignUp ? "Sign Up" : "Sign In")
                .loadingState(viewModel.isLoading)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: canContinue && !viewModel.isLoading))
        .disabled(!canContinue || viewModel.isLoading)
        .accessibilityLabel(isSignUp ? "Create account" : "Sign in")
    }
    
    // MARK: - Forgot Password Button
    
    private var forgotPasswordButton: some View {
        Button {
            print("🔑 [PasswordEntryView] Forgot password tapped for: \(email)")
            Task {
                await viewModel.resetPassword(email: email)
            }
        } label: {
            Text("Forgot password?")
                .font(.bodyRegular)
                .foregroundColor(.primaryGreen)
        }
        .padding(.top, Spacing.spacing2)
    }
    
    // MARK: - Mode Toggle
    
    private var modeToggle: some View {
        HStack(spacing: Spacing.spacing1) {
            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)
            
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    print("🔄 [PasswordEntryView] Switching mode to: \(isSignUp ? "Sign In" : "Sign Up")")
                    // Clear fields when switching
                    password = ""
                    confirmPassword = ""
                    isPasswordValid = false
                    passwordsMatch = true
                    termsAccepted = false
                    isSignUp.toggle()
                }
            } label: {
                Text(isSignUp ? "Sign In" : "Sign Up")
                    .font(.bodyEmphasized)
                    .foregroundColor(.primaryGreen)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.top, Spacing.spacing4)
    }
    
    // MARK: - Computed Properties
    
    /// Whether form can be submitted
    private var canContinue: Bool {
        guard isPasswordValid else { return false }
        
        if isSignUp {
            return passwordsMatch && !confirmPassword.isEmpty && termsAccepted
        }
        return !password.isEmpty
    }
    
    // MARK: - Methods
    
    private func validatePassword(_ value: String) {
        isPasswordValid = value.count >= 6
        print("🔐 [PasswordEntryView] Password validation: \(isPasswordValid ? "✓ valid" : "✗ invalid") (length: \(value.count))")
    }
    
    private func checkPasswordsMatch() {
        if isSignUp {
            passwordsMatch = password == confirmPassword || confirmPassword.isEmpty
        }
    }
    
    private func performAuthAction() {
        guard canContinue else { return }
        
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
}

// MARK: - Requirement Item Component

/// Visual indicator for password requirements
struct RequirementItem: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: Spacing.spacing2) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundColor(isMet ? .successGreen : .textTertiary)
            
            Text(text)
                .font(.captionRegular)
                .foregroundColor(isMet ? .textSecondary : .textTertiary)
        }
    }
}

// MARK: - Preview

#Preview("Password Entry - Sign In Light") {
    PasswordEntryViewPreview(isSignUp: false)
        .preferredColorScheme(.light)
}

#Preview("Password Entry - Sign In Dark") {
    PasswordEntryViewPreview(isSignUp: false)
        .preferredColorScheme(.dark)
}

#Preview("Password Entry - Sign Up Light") {
    PasswordEntryViewPreview(isSignUp: true)
        .preferredColorScheme(.light)
}

#Preview("Password Entry - Sign Up Dark") {
    PasswordEntryViewPreview(isSignUp: true)
        .preferredColorScheme(.dark)
}

/// Preview helper
private struct PasswordEntryViewPreview: View {
    var isSignUp: Bool
    
    var body: some View {
        let mockRepo = MockPasswordAuthRepository()
        let viewModel = AuthViewModel(authRepository: mockRepo)
        
        return PasswordEntryView(
            viewModel: viewModel,
            email: "user@example.com",
            isSignUp: isSignUp
        )
    }
}

/// Mock repository for preview
private struct MockPasswordAuthRepository: AuthRepository {
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

