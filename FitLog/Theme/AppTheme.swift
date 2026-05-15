
import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let primary = Color.purple
        static let primaryDim = Color.purple.opacity(0.15)
        static let primaryGlow = Color.purple.opacity(0.3)
        static let background = Color.black
        static let surface = Color.white.opacity(0.05)
        static let surfaceBorder = Color.white.opacity(0.08)
        static let textPrimary = Color.white
        static let textSecondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red

        static let muscleColors: [String: Color] = [
            "Peito": .purple,
            "Costas": .blue,
            "Pernas": .green,
            "Ombro": .orange,
            "Bíceps": .pink,
            "Tríceps": .yellow,
            "Abdômen": .red
        ]
    }

    // MARK: - Corner Radius
    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }

    // MARK: - Spacing
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
}
