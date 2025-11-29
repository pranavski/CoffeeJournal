import SwiftUI

// MARK: - Color Extensions for Coffee Theme
extension Color {
    // Primary Colors
    static let coffeeBrown = Color(hex: "8B6F47")
    static let matchaGreen = Color(hex: "7CB342")
    static let warmAccent = Color(hex: "D4A574")

    // Background Colors - Updated for iOS 26 Liquid Glass
    static let creamBackground = Color(hex: "FAF8F5")
    static let cardBackground = Color.white.opacity(0.7)

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

// MARK: - iOS 26 Liquid Glass Modifier
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .glassEffect(.regular.tint(Color.coffeeBrown.opacity(0.1)), in: .rect(cornerRadius: cornerRadius))
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 20) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }

    func liquidGlassCard() -> some View {
        self
            .glassEffect(.regular.tint(Color.white.opacity(0.3)), in: .rect(cornerRadius: 16))
    }

    func liquidGlassCapsule() -> some View {
        self
            .glassEffect(.regular.tint(Color.coffeeBrown.opacity(0.1)), in: .capsule)
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

    // New iOS 26 mesh gradients for backgrounds
    static let meshBackground = MeshGradient(
        width: 3,
        height: 3,
        points: [
            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
        ],
        colors: [
            Color(hex: "FAF8F5"), Color(hex: "F5EFE6"), Color(hex: "FAF8F5"),
            Color(hex: "F5EFE6"), Color(hex: "EDE4D9"), Color(hex: "F5EFE6"),
            Color(hex: "FAF8F5"), Color(hex: "F5EFE6"), Color(hex: "FAF8F5")
        ]
    )
}

// MARK: - Custom Button Style with Glass Effect
struct GlassButtonStyle: ButtonStyle {
    var isSelected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}
