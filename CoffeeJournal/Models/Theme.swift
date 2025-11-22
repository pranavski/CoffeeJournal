import SwiftUI

// MARK: - Color Extensions for Coffee Theme
extension Color {
    // Primary Colors
    static let coffeeBrown = Color(hex: "8B6F47")
    static let matchaGreen = Color(hex: "7CB342")
    static let warmAccent = Color(hex: "D4A574")

    // Background Colors
    static let creamBackground = Color(hex: "F5F1ED")
    static let cardBackground = Color.white

    // Text Colors
    static let primaryText = Color(hex: "2C2C2C")
    static let secondaryText = Color(hex: "666666")

    // Rating
    static let ratingGold = Color(hex: "FFB800")

    // Success
    static let successGreen = Color(hex: "4CAF50")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Liquid Glass Effect Modifier
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.8

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, opacity: Double = 0.8) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - Gradient Definitions
struct AppGradients {
    static let coffeePrimary = LinearGradient(
        colors: [Color.coffeeBrown, Color(hex: "A0826D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let matchaPrimary = LinearGradient(
        colors: [Color.matchaGreen, Color(hex: "8BC34A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [Color.warmAccent, Color.coffeeBrown],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
