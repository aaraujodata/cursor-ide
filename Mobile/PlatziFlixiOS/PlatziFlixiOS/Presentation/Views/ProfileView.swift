//
//  ProfileView.swift
//  PlatziFlixiOS
//
//  Simple profile view with logout functionality
//  Allows testing sign-in/sign-up flows during development
//

import SwiftUI

/// User profile view - Shows user info and logout option
/// Follows Apple HIG and design system guidelines
struct ProfileView: View {

    // MARK: - Properties

    /// Auth ViewModel to manage logout
    @ObservedObject var viewModel: AuthViewModel

    /// Dismiss action to close sheet
    @Environment(\.dismiss) var dismiss

    /// Show logout confirmation
    @State private var showLogoutConfirmation = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.spacing8) {

                        // User Avatar
                        avatarSection

                        // User Info
                        userInfoSection

                        // Account Section
                        accountSection

                        // Logout Button
                        logoutButton

                        // App Info
                        appInfoSection

                        Spacer()
                    }
                    .padding(.horizontal, Spacing.spacing6)
                    .padding(.top, Spacing.spacing4)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    Task {
                        await handleLogout()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll need to sign in again to access your courses.")
            }
        }
    }

    // MARK: - Components

    /// User avatar section
    private var avatarSection: some View {
        VStack(spacing: Spacing.spacing4) {
            // Avatar circle with initials
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.primaryGreen, .primaryGreen.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Text(userInitials)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            .shadow(color: .primaryGreen.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .padding(.top, Spacing.spacing8)
        .padding(.bottom, Spacing.spacing4)
    }

    /// User information section
    private var userInfoSection: some View {
        VStack(spacing: Spacing.spacing2) {
            // User name or email
            Text(userName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.neutralWhite)

            // Email
            Text(userEmail)
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)

            // User ID (for debugging)
            if let userId = viewModel.currentUser?.id {
                Text("ID: \(userId)")
                    .font(.captionRegular)
                    .foregroundColor(.textSecondary)
                    .padding(.top, Spacing.spacing1)
            }
        }
        .padding(.bottom, Spacing.spacing4)
    }

    /// Account section with user details
    private var accountSection: some View {
        VStack(spacing: Spacing.spacing4) {
            // Section title
            HStack {
                Text("Account")
                    .font(.bodyEmphasized)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.spacing4)

            VStack(spacing: 0) {
                // Email row
                ProfileRowView(
                    icon: "envelope.fill",
                    title: "Email",
                    value: userEmail,
                    iconColor: .primaryGreen
                )

                Divider()
                    .background(Color.textSecondary.opacity(0.3))
                    .padding(.leading, 56)

                // Provider row
                ProfileRowView(
                    icon: "person.badge.shield.checkmark.fill",
                    title: "Auth Provider",
                    value: authProvider,
                    iconColor: .primaryGreen
                )

                Divider()
                    .background(Color.textSecondary.opacity(0.3))
                    .padding(.leading, 56)

                // Status row
                ProfileRowView(
                    icon: "checkmark.circle.fill",
                    title: "Status",
                    value: "Authenticated",
                    iconColor: .green
                )
            }
            .background(Color.backgroundSecondary)
            .cornerRadius(Radius.radiusMedium)
        }
    }

    /// Logout button
    private var logoutButton: some View {
        Button {
            print("🔐 [Profile] Logout button tapped")
            showLogoutConfirmation = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.body)
                Text("Log Out")
                    .font(.buttonMedium)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.spacing4)
            .background(Color.backgroundSecondary)
            .cornerRadius(Radius.radiusMedium)
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1.0)
        .padding(.top, Spacing.spacing4)
    }

    /// App info section
    private var appInfoSection: some View {
        VStack(spacing: Spacing.spacing2) {
            Text("PlatziFlixiOS")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)

            Text("Version 1.0.0")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)

            Text("© 2025 Platzi")
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
        }
        .padding(.top, Spacing.spacing8)
        .padding(.bottom, Spacing.spacing4)
    }

    // MARK: - Computed Properties

    /// User initials for avatar
    private var userInitials: String {
        if let user = viewModel.currentUser {
            // Try to get initials from full name
            if let fullName = user.fullName {
                let components = fullName.split(separator: " ")
                if components.count >= 2 {
                    let first = components[0].prefix(1).uppercased()
                    let last = components[1].prefix(1).uppercased()
                    return "\(first)\(last)"
                } else if let first = components.first {
                    return String(first.prefix(2).uppercased())
                }
            }

            // Fallback to email initials
            if let email = user.email {
                let initial = email.prefix(1).uppercased()
                return initial
            }
        }

        return "U"
    }

    /// User display name
    private var userName: String {
        if let fullName = viewModel.currentUser?.fullName, !fullName.isEmpty {
            return fullName
        }
        if let email = viewModel.currentUser?.email {
            // Use email username part
            return email.components(separatedBy: "@").first ?? "User"
        }
        return "User"
    }

    /// User email
    private var userEmail: String {
        viewModel.currentUser?.email ?? "No email"
    }

    /// Authentication provider
    private var authProvider: String {
        // Could be enhanced to detect actual provider
        if viewModel.currentUser?.email?.contains("@") == true {
            return "Email"
        }
        return "Unknown"
    }

    // MARK: - Actions

    /// Handle logout action
    private func handleLogout() async {
        print("🔐 [Profile] ==================")
        print("🔐 [Profile] Starting logout...")

        await viewModel.signOut()
        print("✅ [Profile] Logout successful")
        print("🔐 [Profile] ==================")

        // Dismiss the profile view
        dismiss()
    }
}

// MARK: - Supporting Views

/// Profile row component for displaying info
private struct ProfileRowView: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: Spacing.spacing4) {
            // Icon
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            // Title and Value
            VStack(alignment: .leading, spacing: Spacing.spacing1) {
                Text(title)
                    .font(.captionRegular)
                    .foregroundColor(.textSecondary)

                Text(value)
                    .font(.bodyRegular)
                    .foregroundColor(.textPrimary)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.spacing4)
        .padding(.vertical, Spacing.spacing3)
    }
}

// MARK: - Preview

#Preview {
    // Create mock data for preview
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

    // Set mock user data
    viewModel.currentUser = User(
        id: "123456",
        email: "john.doe@example.com",
        fullName: "John Doe",
        avatarURL: nil
    )
    viewModel.isAuthenticated = true

    return ProfileView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

