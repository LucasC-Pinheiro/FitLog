import SwiftUI
import UIKit
// MARK: - App Theme
/// Sistema de design premium para o FitLog
/// Inclui cores, gradientes, tipografia, espaçamentos e animações consistentes
enum AppTheme {

    // MARK: - Colors
    enum Colors {
        // Primary palette
        static let primary = Color(hex: "8B5CF6")       // Vibrant purple
        static let primaryLight = Color(hex: "A78BFA")  // Light purple
        static let primaryDark = Color(hex: "7C3AED")   // Deep purple
        static let primaryDim = Color(hex: "8B5CF6").opacity(0.15)
        static let primaryGlow = Color(hex: "8B5CF6").opacity(0.4)

        // Accent colors
        static let accent = Color(hex: "06B6D4")        // Cyan accent
        static let accentGlow = Color(hex: "06B6D4").opacity(0.3)

        // Background system
        static let background = Color(hex: "0A0A0F")    // Deep dark
        static let backgroundElevated = Color(hex: "12121A")
        static let backgroundCard = Color(hex: "1A1A24")

        // Surface & Glass
        static let surface = Color.white.opacity(0.05)
        static let surfaceElevated = Color.white.opacity(0.08)
        static let surfaceBorder = Color.white.opacity(0.1)
        static let glassBorder = Color.white.opacity(0.15)

        // Text hierarchy
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "9CA3AF")  // Gray-400
        static let textTertiary = Color(hex: "6B7280")   // Gray-500
        static let textMuted = Color(hex: "4B5563")      // Gray-600

        // Semantic colors
        static let success = Color(hex: "10B981")        // Emerald
        static let successDim = Color(hex: "10B981").opacity(0.15)
        static let warning = Color(hex: "F59E0B")        // Amber
        static let warningDim = Color(hex: "F59E0B").opacity(0.15)
        static let danger = Color(hex: "EF4444")         // Red
        static let dangerDim = Color(hex: "EF4444").opacity(0.15)

        // Streak & Energy
        static let streak = Color(hex: "F97316")         // Orange
        static let streakGlow = Color(hex: "F97316").opacity(0.4)

        // Muscle group colors (fitness identity)
        static let muscleColors: [String: Color] = [
            "Peito": Color(hex: "8B5CF6"),      // Purple
            "Costas": Color(hex: "3B82F6"),     // Blue
            "Pernas": Color(hex: "10B981"),     // Green
            "Ombro": Color(hex: "F97316"),      // Orange
            "Bíceps": Color(hex: "EC4899"),     // Pink
            "Tríceps": Color(hex: "EAB308"),    // Yellow
            "Abdômen": Color(hex: "EF4444"),    // Red
            "Glúteos": Color(hex: "14B8A6"),    // Teal
            "Antebraço": Color(hex: "6366F1")   // Indigo
        ]
    }

    // MARK: - Gradients
    enum Gradients {
        static let primary = LinearGradient(
            colors: [Colors.primary, Colors.primaryDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let primaryGlow = LinearGradient(
            colors: [Colors.primary.opacity(0.8), Colors.primaryDark.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )

        static let streakCard = LinearGradient(
            colors: [
                Colors.streak.opacity(0.3),
                Colors.primary.opacity(0.2),
                Colors.background.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let cardBackground = LinearGradient(
            colors: [
                Color.white.opacity(0.08),
                Color.white.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let glassBackground = LinearGradient(
            colors: [
                Color.white.opacity(0.12),
                Color.white.opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let heroBackground = LinearGradient(
            colors: [
                Colors.primary.opacity(0.15),
                Colors.accent.opacity(0.05),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let onboardingBackground = LinearGradient(
            colors: [
                Colors.primary.opacity(0.2),
                Colors.background,
                Colors.background
            ],
            startPoint: .top,
            endPoint: .bottom
        )

        static let successGradient = LinearGradient(
            colors: [Colors.success, Colors.success.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Corner Radius
    enum Radius {
        static let xs: CGFloat = 6
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let xxl: CGFloat = 24
        static let pill: CGFloat = 100
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 6
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Typography
    enum Typography {
        // Display - Hero text
        static func displayLarge() -> Font {
            .system(size: 56, weight: .bold, design: .rounded)
        }

        static func displayMedium() -> Font {
            .system(size: 44, weight: .bold, design: .rounded)
        }

        // Headlines
        static func headline() -> Font {
            .system(size: 28, weight: .bold, design: .rounded)
        }

        static func headlineSmall() -> Font {
            .system(size: 22, weight: .bold, design: .rounded)
        }

        // Titles
        static func titleLarge() -> Font {
            .system(size: 20, weight: .semibold)
        }

        static func titleMedium() -> Font {
            .system(size: 17, weight: .semibold)
        }

        static func titleSmall() -> Font {
            .system(size: 15, weight: .semibold)
        }

        // Body
        static func bodyLarge() -> Font {
            .system(size: 17, weight: .regular)
        }

        static func bodyMedium() -> Font {
            .system(size: 15, weight: .regular)
        }

        static func bodySmall() -> Font {
            .system(size: 13, weight: .regular)
        }

        // Labels & Captions
        static func labelLarge() -> Font {
            .system(size: 14, weight: .medium)
        }

        static func labelMedium() -> Font {
            .system(size: 12, weight: .medium)
        }

        static func labelSmall() -> Font {
            .system(size: 11, weight: .medium)
        }

        static func caption() -> Font {
            .system(size: 11, weight: .regular)
        }

        // Numbers - Stats display
        static func statLarge() -> Font {
            .system(size: 42, weight: .bold, design: .rounded)
        }

        static func statMedium() -> Font {
            .system(size: 32, weight: .bold, design: .rounded)
        }

        static func statSmall() -> Font {
            .system(size: 24, weight: .bold, design: .rounded)
        }
    }

    // MARK: - Shadows
    enum Shadows {
        static let small = ShadowStyle(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let medium = ShadowStyle(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        static let large = ShadowStyle(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)

        static let glow = ShadowStyle(color: Colors.primary.opacity(0.4), radius: 12, x: 0, y: 0)
        static let glowStrong = ShadowStyle(color: Colors.primary.opacity(0.6), radius: 20, x: 0, y: 0)
        static let streakGlow = ShadowStyle(color: Colors.streak.opacity(0.5), radius: 16, x: 0, y: 0)
        static let successGlow = ShadowStyle(color: Colors.success.opacity(0.5), radius: 12, x: 0, y: 0)
    }

    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
        static let springGentle = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)

        // Stagger delay for list items
        static func staggerDelay(index: Int, baseDelay: Double = 0.05) -> Double {
            Double(index) * baseDelay
        }
    }

    // MARK: - Haptics
    enum Haptics {
        static func light() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        static func medium() {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        static func heavy() {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }

        static func success() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        static func warning() {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }

        static func error() {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

        static func selection() {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

// MARK: - Shadow Style Helper
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - View Extensions
extension View {
    /// Apply glass morphism effect
    func glassCard(cornerRadius: CGFloat = AppTheme.Radius.large) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.Gradients.glassBackground)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial.opacity(0.5))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 1)
            )
    }

    /// Apply standard card style
    func cardStyle(cornerRadius: CGFloat = AppTheme.Radius.large) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.Gradients.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.Colors.surfaceBorder, lineWidth: 1)
            )
    }

    /// Apply shadow style
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    /// Stagger animation for list items
    func staggeredAppear(index: Int, isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(
                AppTheme.Animation.spring.delay(AppTheme.Animation.staggerDelay(index: index)),
                value: isVisible
            )
    }

    /// Shimmer loading effect
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }

    /// Press effect for buttons
    func pressEffect(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.96 : 1)
            .opacity(isPressed ? 0.9 : 1)
            .animation(AppTheme.Animation.quick, value: isPressed)
    }
}

// MARK: - Shimmer Modifier
struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isActive {
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                        .onAppear {
                            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                phase = 1
                            }
                        }
                    }
                }
                .mask(content)
            )
    }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
    let value: Int
    let font: Font
    let color: Color

    @State private var displayValue: Int = 0

    var body: some View {
        Text("\(displayValue)")
            .font(font)
            .foregroundColor(color)
            .contentTransition(.numericText())
            .onAppear {
                withAnimation(AppTheme.Animation.smooth) {
                    displayValue = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(AppTheme.Animation.smooth) {
                    displayValue = newValue
                }
            }
    }
}
