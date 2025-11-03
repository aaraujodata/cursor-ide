import SwiftUI

/// Secure AsyncImage that uses NetworkManager's certificate trust configuration
/// This ensures that images from corporate CA-protected domains load correctly
/// Replaces AsyncImage to handle corporate SSL inspection proxies (e.g., NortonLifeLock)
struct SecureAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasError = false

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else if hasError {
                placeholder()
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }

    /// Loads the image using NetworkManager's configured URLSession
    /// This ensures certificate trust is handled correctly
    private func loadImage() async {
        guard let url = url else {
            await MainActor.run {
                self.isLoading = false
                self.hasError = true
            }
            return
        }

        await MainActor.run {
            self.isLoading = true
            self.hasError = false
        }

        do {
            // Use NetworkManager's shared URLSession with certificate trust
            let (data, response) = try await NetworkManager.sharedURLSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                print("⚠️  [Image] Failed to load: Invalid response from \(url)")
                await MainActor.run {
                    self.hasError = true
                    self.isLoading = false
                }
                return
            }

            guard let uiImage = UIImage(data: data) else {
                print("⚠️  [Image] Failed to decode image data from \(url)")
                await MainActor.run {
                    self.hasError = true
                    self.isLoading = false
                }
                return
            }

            // Successfully loaded image
            print("✅ [Image] Loaded successfully: \(uiImage.size.width)x\(uiImage.size.height) from \(url.lastPathComponent)")

            await MainActor.run {
                self.image = uiImage
                self.isLoading = false
                self.hasError = false
            }
        } catch {
            print("❌ [Image] Error loading from \(url): \(error.localizedDescription)")
            await MainActor.run {
                self.hasError = true
                self.isLoading = false
            }
        }
    }
}

// Note: The convenience initializer was removed as it doesn't match AsyncImage's generic API
// Use the main initializer with explicit content and placeholder closures instead

