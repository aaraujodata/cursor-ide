//
//  PlatziFlixiOSApp.swift
//  PlatziFlixiOS
//
//  Created by Santiago Moreno on 10/06/25.
//

import SwiftUI
import GoogleSignIn

@main
struct PlatziFlixiOSApp: App {

    init() {
        // Print API configuration at app launch
        print("🚀 [App] PlatziFlixiOS Launching...")
        APIConfiguration.printConfiguration()

        // Initialize NetworkManager to trigger configuration
        _ = NetworkManager.shared

        print("🚀 [App] Configuration complete")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Handle URL callbacks for Google Sign-In and deep links
                .onOpenURL { url in
                    print("🔗 [App] Received URL: \(url)")

                    // Handle Google Sign-In callback
                    if GIDSignIn.sharedInstance.handle(url) {
                        print("🔵 [App] URL handled by Google Sign-In")
                        return
                    }

                    // Handle other deep links here if needed
                    print("⚠️ [App] URL not handled: \(url)")
                }
        }
    }
}
