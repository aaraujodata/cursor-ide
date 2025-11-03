//
//  PlatziFlixiOSApp.swift
//  PlatziFlixiOS
//
//  Created by Santiago Moreno on 10/06/25.
//

import SwiftUI

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
        }
    }
}
