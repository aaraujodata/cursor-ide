//
//  MainTabView.swift
//  PlatziFlixiOS
//
//  Main tab navigation view with Home and Profile tabs
//  Follows SwiftUI 5.0 navigation patterns and design system guidelines
//

import SwiftUI
import UIKit

/// Main tab view container for authenticated app experience
/// Implements bottom tab bar navigation with Home and Profile tabs
/// Follows Apple HIG and SwiftUI 5.0 best practices
struct MainTabView: View {

    // MARK: - Properties

    /// Auth ViewModel for profile/logout functionality
    @ObservedObject var authViewModel: AuthViewModel

    /// Selected tab index (0 = Home, 1 = Profile)
    @State private var selectedTab: Int = 0

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Course List
            CourseListView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                .accessibilityLabel("Home tab")
                .accessibilityHint("View available courses")

            // Profile Tab
            ProfileView(viewModel: authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
                .accessibilityLabel("Profile tab")
                .accessibilityHint("View your profile and account settings")
        }
        .accentColor(.primaryGreen) // Tab bar accent color
        .onAppear {
            // Configure tab bar appearance for iOS 15+
            configureTabBarAppearance()
            print("📱 [MainTabView] Tab view appeared")
        }
    }

    // MARK: - Private Helpers

    /// Configures tab bar appearance to match design system
    /// Uses iOS 15+ UITabBarAppearance API
    private func configureTabBarAppearance() {
        // Configure tab bar appearance for better visual consistency
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Set background color based on color scheme
        appearance.backgroundColor = UIColor.systemBackground

        // Configure selected and unselected item colors
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryGreen)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryGreen)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]

        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Preview

#Preview {
    // Create mock auth repository and view model for preview
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

    // Set mock user for preview
    viewModel.currentUser = User(
        id: "123456",
        email: "john.doe@example.com",
        fullName: "John Doe",
        avatarURL: nil
    )
    viewModel.isAuthenticated = true

    return MainTabView(authViewModel: viewModel)
        .preferredColorScheme(.dark)
}

