//
//  ContentView.swift
//  PlatziFlixiOS
//
//  Created by Santiago Moreno on 10/06/25.
//

import SwiftUI

struct ContentView: View {
    /// Auth ViewModel - single source of truth for authentication
    @StateObject private var authViewModel: AuthViewModel

    /// Initializes ContentView with authentication
    init() {
        // Create ONE auth repository and ONE view model
        let authRepository = AuthServiceFactory.createAuthRepository()
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authRepository: authRepository))
        print("📱 [ContentView] Initialized")
    }

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // User is authenticated - show main app with tab navigation
                // MainTabView contains Home and Profile tabs
                MainTabView(authViewModel: authViewModel)
            } else {
                // User is NOT authenticated - show login/signup
                // PASS the ViewModel so AuthView uses the SAME one
                AuthView(viewModel: authViewModel)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
        .task {
            // Check for existing session on app launch
            await authViewModel.checkCurrentSession()
        }
    }
}

#Preview {
    ContentView()
}
