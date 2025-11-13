//
//  YouTubeThumbnailExtractor.swift
//  PlatziFlixiOS
//
//  Created by AI Assistant
//

import Foundation

/// Utility to extract YouTube thumbnail URLs from video URLs
/// Supports multiple YouTube URL formats
struct YouTubeThumbnailExtractor {

    /// Extracts YouTube video ID from various URL formats
    /// Supports:
    /// - https://www.youtube.com/watch?v=VIDEO_ID
    /// - https://youtu.be/VIDEO_ID
    /// - https://www.youtube.com/embed/VIDEO_ID
    /// - VIDEO_ID (direct ID)
    /// - Parameter urlString: YouTube URL or video ID
    /// - Returns: YouTube video ID if found, nil otherwise
    static func extractVideoID(from urlString: String?) -> String? {
        guard let urlString = urlString, !urlString.isEmpty else { return nil }

        // If it's already just an ID (no URL), return it
        if !urlString.contains("://") && !urlString.contains("/") && !urlString.contains("?") {
            return urlString
        }

        // Try to parse as URL first
        guard let url = URL(string: urlString) else {
            // If URL parsing fails, try manual extraction
            return extractVideoIDManually(from: urlString)
        }

        // Handle youtube.com/watch?v=VIDEO_ID
        if url.host?.contains("youtube.com") == true {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let videoID = queryItems.first(where: { $0.name == "v" })?.value {
                return videoID
            }
        }

        // Handle youtu.be/VIDEO_ID
        if url.host == "youtu.be" {
            let pathComponents = url.pathComponents.filter { $0 != "/" }
            if let videoID = pathComponents.first {
                return videoID
            }
        }

        // Handle youtube.com/embed/VIDEO_ID
        if url.host?.contains("youtube.com") == true && url.pathComponents.contains("embed") {
            if let embedIndex = url.pathComponents.firstIndex(of: "embed"),
               embedIndex < url.pathComponents.count - 1 {
                return url.pathComponents[embedIndex + 1]
            }
        }

        // Fallback to manual extraction
        return extractVideoIDManually(from: urlString)
    }

    /// Manual extraction fallback using string operations
    /// - Parameter urlString: YouTube URL string
    /// - Returns: Video ID if found, nil otherwise
    private static func extractVideoIDManually(from urlString: String) -> String? {
        // Pattern for youtube.com/watch?v=VIDEO_ID
        if let vIndex = urlString.range(of: "?v=") ?? urlString.range(of: "&v=") {
            let startIndex = urlString.index(vIndex.upperBound, offsetBy: 0)
            let remaining = String(urlString[startIndex...])
            if let endIndex = remaining.firstIndex(of: "&") {
                return String(remaining[..<endIndex])
            }
            return remaining
        }

        // Pattern for youtu.be/VIDEO_ID
        if let beIndex = urlString.range(of: "youtu.be/") {
            let startIndex = urlString.index(beIndex.upperBound, offsetBy: 0)
            let remaining = String(urlString[startIndex...])
            if let endIndex = remaining.firstIndex(of: "?") ?? remaining.firstIndex(of: "&") {
                return String(remaining[..<endIndex])
            }
            return remaining
        }

        // Pattern for youtube.com/embed/VIDEO_ID
        if let embedIndex = urlString.range(of: "/embed/") {
            let startIndex = urlString.index(embedIndex.upperBound, offsetBy: 0)
            let remaining = String(urlString[startIndex...])
            if let endIndex = remaining.firstIndex(of: "?") ?? remaining.firstIndex(of: "&") {
                return String(remaining[..<endIndex])
            }
            return remaining
        }

        return nil
    }

    /// Generates YouTube thumbnail URL from video ID
    /// - Parameters:
    ///   - videoID: YouTube video ID
    ///   - quality: Thumbnail quality (default, medium, high, maxres)
    /// - Returns: Thumbnail URL string
    static func thumbnailURL(videoID: String, quality: ThumbnailQuality = .high) -> String {
        let qualityString: String
        switch quality {
        case .default:
            qualityString = "default"
        case .medium:
            qualityString = "mqdefault"
        case .high:
            qualityString = "hqdefault"
        case .maxres:
            qualityString = "maxresdefault"
        }

        return "https://img.youtube.com/vi/\(videoID)/\(qualityString).jpg"
    }

    /// Extracts thumbnail URL directly from YouTube video URL
    /// - Parameters:
    ///   - urlString: YouTube video URL
    ///   - quality: Thumbnail quality (default: high)
    /// - Returns: Thumbnail URL if video ID found, nil otherwise
    static func extractThumbnailURL(from urlString: String?, quality: ThumbnailQuality = .high) -> String? {
        guard let videoID = extractVideoID(from: urlString) else { return nil }
        return thumbnailURL(videoID: videoID, quality: quality)
    }

    /// Thumbnail quality options
    enum ThumbnailQuality {
        case `default`  // 120x90
        case medium     // 320x180
        case high       // 480x360
        case maxres     // 1280x720 (may not always be available)
    }
}

// MARK: - Class Extension
extension Class {
    /// Computed property to get YouTube thumbnail URL from video URL
    /// Returns nil if video URL is not a YouTube URL or if videoUrl is nil
    var youtubeThumbnailURL: String? {
        guard let videoUrl = videoUrl else { return nil }
        return YouTubeThumbnailExtractor.extractThumbnailURL(from: videoUrl, quality: .high)
    }
}

