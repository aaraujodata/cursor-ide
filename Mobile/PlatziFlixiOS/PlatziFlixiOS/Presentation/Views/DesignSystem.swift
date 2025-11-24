//
//  DesignSystem.swift
//  PlatziFlixiOS
//
//  Design System for PlatziFlixiOS
//  Following: promp_swit_ui_interfaces.md guidelines
//

import SwiftUI

// MARK: - Color Extensions

extension Color {
    
    // MARK: - Primary Brand Colors
    
    /// Primary green accent color - used for CTAs, links, and brand elements
    static let primaryGreen = Color(hex: "A8E063")  // Lime green like Arimo reference
    
    /// Primary blue for informational elements
    static let primaryBlue = Color(hex: "007AFF")
    
    /// Primary red for destructive actions
    static let primaryRed = Color(hex: "FF3B30")
    
    // MARK: - Adaptive Text Colors (Light/Dark mode aware)
    
    /// Primary text - adapts to light/dark mode automatically
    static let textPrimary = Color.primary
    
    /// Secondary text - slightly dimmed, adapts automatically
    static let textSecondary = Color.secondary
    
    /// Tertiary text - most dimmed, adapts automatically
    static let textTertiary = Color(.tertiaryLabel)
    
    /// Inverted text - for use on colored backgrounds
    static let textOnPrimary = Color(.systemBackground)
    
    // MARK: - Adaptive Background Colors
    
    /// Main background - adapts to light/dark mode
    static let backgroundPrimary = Color(.systemBackground)
    
    /// Secondary background - cards, sections
    static let backgroundSecondary = Color(.secondarySystemBackground)
    
    /// Tertiary background - nested content
    static let backgroundTertiary = Color(.tertiarySystemBackground)
    
    /// Grouped background - for grouped table views
    static let groupedBackground = Color(.systemGroupedBackground)
    
    // MARK: - Card & Surface Colors
    
    /// Card background - adapts for light/dark
    static let cardBackground = Color(.secondarySystemBackground)
    
    /// Surface background - main content areas
    static let surfaceBackground = Color(.systemBackground)
    
    // MARK: - Neutral Grays (Adaptive)
    
    /// Darkest gray - adapts
    static let neutralGray900 = Color(.systemGray)
    
    /// Dark gray - adapts
    static let neutralGray800 = Color(.systemGray2)
    
    /// Medium gray - adapts
    static let neutralGray600 = Color(.systemGray3)
    
    /// Light gray - adapts
    static let neutralGray400 = Color(.systemGray4)
    
    /// Lightest gray - adapts
    static let neutralGray200 = Color(.systemGray6)
    
    /// Pure white
    static let neutralWhite = Color.white
    
    /// Pure black
    static let neutralBlack = Color.black
    
    // MARK: - Semantic Colors
    
    /// Success state color
    static let successGreen = Color(hex: "30D158")
    
    /// Warning state color
    static let warningOrange = Color(hex: "FF9500")
    
    /// Error state color
    static let errorRed = Color(hex: "FF453A")
    
    /// Info state color
    static let infoBlue = Color(hex: "64D2FF")
    
    // MARK: - Input Field Colors
    
    /// Input field background - adapts for light/dark
    static var inputBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    /// Input field border - adapts
    static var inputBorder: Color {
        Color(.separator)
    }
    
    /// Input placeholder text
    static var inputPlaceholder: Color {
        Color(.placeholderText)
    }
    
    // MARK: - Social Login Provider Colors
    
    /// Google brand red
    static let googleRed = Color(hex: "DB4437")
    
    /// Facebook brand blue
    static let facebookBlue = Color(hex: "1877F2")
    
    /// Apple - uses label color for adaptivity
    static let appleDark = Color(.label)
    
    // MARK: - Hex Color Initializer
    
    /// Creates a Color from a hex string
    /// - Parameter hex: Hex color string (with or without #)
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Spacing System

/// Consistent spacing values based on 8pt grid system
struct Spacing {
    static let spacing1: CGFloat = 4.0   // 0.5x base
    static let spacing2: CGFloat = 8.0   // 1x base
    static let spacing3: CGFloat = 12.0  // 1.5x base
    static let spacing4: CGFloat = 16.0  // 2x base
    static let spacing5: CGFloat = 20.0  // 2.5x base
    static let spacing6: CGFloat = 24.0  // 3x base
    static let spacing8: CGFloat = 32.0  // 4x base
    static let spacing10: CGFloat = 40.0 // 5x base
    static let spacing12: CGFloat = 48.0 // 6x base
    static let spacing16: CGFloat = 64.0 // 8x base
}

// MARK: - Border Radius

/// Consistent corner radius values
struct Radius {
    static let radiusSmall: CGFloat = 4.0
    static let radiusMedium: CGFloat = 8.0
    static let radiusLarge: CGFloat = 12.0
    static let radiusXLarge: CGFloat = 16.0
    static let radiusXXLarge: CGFloat = 24.0
    static let radiusFull: CGFloat = 1000.0
}

// MARK: - Typography Extensions

extension Font {
    // Headings
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.medium)
    
    // Body Text
    static let bodyRegular = Font.body.weight(.regular)
    static let bodyEmphasized = Font.body.weight(.medium)
    static let captionRegular = Font.caption.weight(.regular)
    static let caption2Regular = Font.caption2.weight(.regular)
    
    // Interactive
    static let buttonLarge = Font.headline.weight(.semibold)
    static let buttonMedium = Font.body.weight(.medium)
    static let buttonSmall = Font.caption.weight(.medium)
}

// MARK: - Card Style ViewModifier

/// Applies card styling to any view
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(Radius.radiusXXLarge)
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.3)
                    : Color.black.opacity(0.08),
                radius: colorScheme == .dark ? 8 : 12,
                x: 0,
                y: 4
            )
    }
}

extension View {
    /// Applies consistent card styling
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}

// MARK: - Primary Button Style

/// Modern primary button style with green accent
struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonMedium)
            .foregroundColor(isEnabled ? .neutralBlack : .textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.spacing4)
            .background(
                isEnabled
                    ? Color.primaryGreen
                    : Color.neutralGray400
            )
            .cornerRadius(Radius.radiusFull)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

/// Outlined secondary button style
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonMedium)
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.spacing4)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.radiusFull)
                    .stroke(Color.inputBorder, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Modern Text Field Style

/// Clean, modern text field style with floating label support
struct ModernTextFieldStyle: ViewModifier {
    let label: String
    let text: String
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing1) {
            // Floating label
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            // Text field
            content
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
                .padding(.vertical, Spacing.spacing3)
                .padding(.horizontal, Spacing.spacing4)
                .background(Color.inputBackground)
                .cornerRadius(Radius.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.radiusMedium)
                        .stroke(Color.inputBorder.opacity(0.5), lineWidth: 1)
                )
        }
    }
}

extension View {
    /// Applies modern text field styling with label
    func modernTextField(label: String, text: String) -> some View {
        self.modifier(ModernTextFieldStyle(label: label, text: text))
    }
}

// MARK: - Divider with Text

/// Horizontal divider with centered text (e.g., "Or")
struct DividerWithText: View {
    let text: String
    
    var body: some View {
        HStack(spacing: Spacing.spacing4) {
            Rectangle()
                .fill(Color.inputBorder.opacity(0.5))
                .frame(height: 1)
            
            Text(text)
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
            
            Rectangle()
                .fill(Color.inputBorder.opacity(0.5))
                .frame(height: 1)
        }
    }
}

// MARK: - Loading Button Modifier

/// Adds loading state to buttons
struct LoadingButtonModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(isLoading ? 0 : 1)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .neutralBlack))
            }
        }
    }
}

extension View {
    /// Adds loading state overlay
    func loadingState(_ isLoading: Bool) -> some View {
        self.modifier(LoadingButtonModifier(isLoading: isLoading))
    }
}

// MARK: - Wave Header Shape

/// Custom wave shape for header backgrounds (inspired by Arimo design)
struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from top-left
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        
        // Right edge down
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.75))
        
        // Wave curve at bottom
        path.addCurve(
            to: CGPoint(x: 0, y: rect.maxY),
            control1: CGPoint(x: rect.maxX * 0.6, y: rect.maxY * 0.6),
            control2: CGPoint(x: rect.maxX * 0.3, y: rect.maxY * 1.1)
        )
        
        // Left edge back to start
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Preview Helpers

#Preview("Design System Colors") {
    ScrollView {
        VStack(spacing: Spacing.spacing6) {
            // Primary Colors
            Group {
                Text("Primary Colors")
                    .font(.title2)
                HStack(spacing: Spacing.spacing4) {
                    ColorSwatch(color: .primaryGreen, name: "Primary Green")
                    ColorSwatch(color: .primaryBlue, name: "Primary Blue")
                    ColorSwatch(color: .primaryRed, name: "Primary Red")
                }
            }
            
            // Text Colors
            Group {
                Text("Text Colors")
                    .font(.title2)
                VStack(alignment: .leading, spacing: Spacing.spacing2) {
                    Text("Primary Text").foregroundColor(.textPrimary)
                    Text("Secondary Text").foregroundColor(.textSecondary)
                    Text("Tertiary Text").foregroundColor(.textTertiary)
                }
            }
            
            // Buttons
            Group {
                Text("Button Styles")
                    .font(.title2)
                Button("Primary Button") {}
                    .buttonStyle(PrimaryButtonStyle())
                Button("Secondary Button") {}
                    .buttonStyle(SecondaryButtonStyle())
            }
            
            // Divider
            DividerWithText(text: "Or")
        }
        .padding()
    }
}

/// Helper view for color preview
private struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: Radius.radiusMedium)
                .fill(color)
                .frame(width: 60, height: 60)
            Text(name)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
    }
}
