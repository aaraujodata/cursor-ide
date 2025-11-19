//
//  SupabaseConfiguration.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import Foundation

/// Configuration for Supabase client
/// Provides a centralized way to configure Supabase connection
struct SupabaseConfiguration {
    
    /// Supabase project URL
    /// TODO: Replace with your actual Supabase project URL
    static let supabaseURL: String = {
        // Check for environment variable first (for CI/CD)
        if let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] {
            print("🔐 [Supabase] Using URL from environment: \(url)")
            return url
        }
        
        // Default to placeholder - MUST be configured
        // Format: https://<project-id>.supabase.co
        let defaultURL = "https://lszvsnpptqscsuorhmec.supabase.co"
        print("⚠️ [Supabase] Using default URL. Please configure SUPABASE_URL")
        print("⚠️ [Supabase] Set SUPABASE_URL environment variable or update SupabaseConfiguration.swift")
        return defaultURL
    }()
    
    /// Supabase anonymous/public key (anon key)
    /// TODO: Replace with your actual Supabase anon key
    static let supabaseAnonKey: String = {
        // Check for environment variable first (for CI/CD)
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] {
            print("🔐 [Supabase] Using anon key from environment")
            return key
        }
        
        // Default to placeholder - MUST be configured
        let defaultKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxzenZzbnBwdHFzY3N1b3JobWVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxMzAzMTIsImV4cCI6MjA3ODcwNjMxMn0.f8faLwuisuPZV26VThTPOVjMWDlOhFS-yKT5wYt3Uu8"
        print("⚠️ [Supabase] Using default anon key. Please configure SUPABASE_ANON_KEY")
        print("⚠️ [Supabase] Set SUPABASE_ANON_KEY environment variable or update SupabaseConfiguration.swift")
        return defaultKey
    }()
    
    /// Validates that Supabase configuration is properly set
    /// - Returns: True if configuration appears valid, false otherwise
    static func isValid() -> Bool {
        let urlValid = !supabaseURL.contains("your-project-id")
        let keyValid = !supabaseAnonKey.contains("your-anon-key")
        
        if !urlValid || !keyValid {
            print("❌ [Supabase] Configuration incomplete:")
            if !urlValid {
                print("   - SUPABASE_URL needs to be configured")
            }
            if !keyValid {
                print("   - SUPABASE_ANON_KEY needs to be configured")
            }
        }
        
        return urlValid && keyValid
    }
    
    /// Prints current configuration (for debugging)
    static func printConfiguration() {
        print("🔐 [Supabase Config] ==================")
        print("🔐 [Supabase Config] URL: \(supabaseURL)")
        print("🔐 [Supabase Config] Anon Key: \(supabaseAnonKey.prefix(20))...")
        print("🔐 [Supabase Config] Valid: \(isValid())")
        print("🔐 [Supabase Config] ==================")
    }
}

